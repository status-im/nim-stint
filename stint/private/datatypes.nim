# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Status lib
  stew/bitops2

when sizeof(int) == 8 and not defined(Stint32):
  type Word* = uint64
else:
  type Word* = uint32

const WordBitWidth* = sizeof(Word) * 8

func wordsRequired*(bits: int): int {.compileTime.} =
  ## Compute the number of limbs required
  ## for the **announced** bit length
  (bits + WordBitWidth - 1) div WordBitWidth

type
  Limbs*[N: static int] = array[N, Word]
    ## Limbs type

  StUint*[bits: static[int]] = object
    ## Stack-based integer
    ## Unsigned
    limbs*: array[bits.wordsRequired, Word]
      # Limbs-Endianess is little-endian

  StInt*[bits: static[int]] {.borrow: `.`.} = distinct StUint[bits]
    ## Stack-based integer
    ## Signed

  Carry* = uint8  # distinct range[0'u8 .. 1]
  Borrow* = uint8 # distinct range[0'u8 .. 1]

  SomeBigInteger*[bits: static[int]] = Stuint[bits]|Stint[bits]

const GCC_Compatible* = defined(gcc) or defined(clang) or defined(llvm_gcc)
const X86* = defined(amd64) or defined(i386)

when sizeof(int) == 8 and GCC_Compatible:
  type
    uint128*{.importc: "unsigned __int128".} = object

# Bithacks
# --------------------------------------------------------

{.push raises: [], inline, noInit, gcsafe.}

template clearExtraBitsOverMSB*(a: var StUint) =
  ## A Stuint is stored in an array of 32 of 64-bit word
  ## If we do bit manipulation at the word level,
  ## for example a 8-bit stuint stored in a 64-bit word
  ## we need to clear the upper 56-bit
  when a.bits != a.limbs.len * WordBitWidth:
    const posExtraBits = a.bits - (a.limbs.len-1) * WordBitWidth
    const mask = (Word(1) shl posExtraBits) - 1
    a[^1] = a[^1] and mask

func usedBitsAndWords*(a: openArray[Word]): tuple[bits, words: int] =
  ## Returns the number of used words and bits in a bigInt
  ## Returns (0, 0) for all-zeros array (even if technically you need 1 bit and 1 word to encode zero)
  var clz = 0
  # Count Leading Zeros
  for i in countdown(a.len-1, 0):
    let count = log2trunc(a[i])
    # debugEcho "count: ", count, ", a[", i, "]: ", a[i].toBin(64)
    if count == -1:
      clz += WordBitWidth
    else:
      clz += WordBitWidth - count - 1
      return (a.len*WordBitWidth - clz, i+1)
  return (0, 0)

{.pop.}

# Accessors
# --------------------------------------------------------

template `[]`*(a: SomeBigInteger, i: SomeInteger or BackwardsIndex): Word =
  a.limbs[i]

template `[]=`*(a: var SomeBigInteger, i: SomeInteger or BackwardsIndex, val: Word) =
  a.limbs[i] = val

# Iterations
# --------------------------------------------------------

import std/macros

proc replaceNodes(ast: NimNode, what: NimNode, by: NimNode): NimNode =
  # Replace "what" ident node by "by"
  proc inspect(node: NimNode): NimNode =
    case node.kind:
    of {nnkIdent, nnkSym}:
      if node.eqIdent(what):
        return by
      return node
    of nnkEmpty:
      return node
    of nnkLiterals:
      return node
    else:
      var rTree = node.kind.newTree()
      for child in node:
        rTree.add inspect(child)
      return rTree
  result = inspect(ast)

macro staticFor*(idx: untyped{nkIdent}, start, stopEx: static int, body: untyped): untyped =
  ## staticFor [min inclusive, max exclusive)
  result = newStmtList()
  for i in start ..< stopEx:
    result.add nnkBlockStmt.newTree(
      ident("unrolledIter_" & $idx & $i),
      body.replaceNodes(idx, newLit i)
    )

# Copy
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func copyWords*(
       a: var openArray[Word], startA: int,
       b: openArray[Word], startB: int,
       numWords: int) =
  ## Copy a slice of B into A. This properly deals
  ## with overlaps when A and B are slices of the same buffer
  for i in countdown(numWords-1, 0):
    a[startA+i] = b[startB+i]

{.pop.}
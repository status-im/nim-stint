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
  ## from the **announced** bit length
  (bits + WordBitWidth - 1) div WordBitWidth

type
  Limbs*[N: static int] = array[N, Word]

  StUint*[bits: static[int]] = object
    ## Stack-based integer
    ## Unsigned
    limbs*: Limbs[bits.wordsRequired]

  StInt*[bits: static[int]] = object
    ## Stack-based integer
    ## Signed
    limbs*: Limbs[bits.wordsRequired]

  Carry* = uint8  # distinct range[0'u8 .. 1]
  Borrow* = uint8 # distinct range[0'u8 .. 1]

  SomeBigInteger*[bits: static[int]] = Stuint[bits]|Stint[bits]

const GCC_Compatible* = defined(gcc) or defined(clang) or defined(llvm_gcc)
const X86* = defined(amd64) or defined(i386)

when sizeof(int) == 8 and GCC_Compatible:
  type
    uint128*{.importc: "unsigned __int128".} = object

# Accessors
# --------------------------------------------------------

template leastSignificantWord*(num: SomeInteger): auto =
  num

func leastSignificantWord*(a: SomeBigInteger): auto {.inline.} =
  when cpuEndian == littleEndian:
    a.limbs[0]
  else:
    a.limbs[^1]

func mostSignificantWord*(a: SomeBigInteger): auto {.inline.} =
  when cpuEndian == littleEndian:
    a.limbs[^1]
  else:
    a.limbs[0]

# Iterations
# --------------------------------------------------------

iterator leastToMostSig*(a: SomeBigInteger): Word =
  ## Iterate from least to most significant word
  when cpuEndian == littleEndian:
    for i in 0 ..< a.limbs.len:
      yield a.limbs[i]
  else:
    for i in countdown(a.limbs.len-1, 0):
      yield a.limbs[i]

iterator leastToMostSig*(a: var SomeBigInteger): var Word =
  ## Iterate from least to most significant word
  when cpuEndian == littleEndian:
    for i in 0 ..< a.limbs.len:
      yield a.limbs[i]
  else:
    for i in countdown(a.limbs.len-1, 0):
      yield a.limbs[i]

iterator leastToMostSig*(a, b: SomeBigInteger): (Word, Word) =
  ## Iterate from least to most significant word
  when cpuEndian == littleEndian:
    for i in 0 ..< a.limbs.len:
      yield (a.limbs[i], b.limbs[i])
  else:
    for i in countdown(a.limbs.len-1, 0):
      yield (a.limbs[i], b.limbs[i])

iterator leastToMostSig*[aBits, bBits](a: var SomeBigInteger[aBits], b: SomeBigInteger[bBits]): (var Word, Word) =
  ## Iterate from least to most significant word
  when cpuEndian == littleEndian:
    for i in 0 ..< min(a.limbs.len, b.limbs.len):
      yield (a.limbs[i], b.limbs[i])
  else:
    for i in countdown(min(aLimbs.len, b.limbs.len)-1, 0):
      yield (a.limbs[i], b.limbs[i])

iterator leastToMostSig*(c: var SomeBigInteger, a, b: SomeBigInteger): (var Word, Word, Word) =
  ## Iterate from least to most significant word
  when cpuEndian == littleEndian:
    for i in 0 ..< a.limbs.len:
      yield (c.limbs[i], a.limbs[i], b.limbs[i])
  else:
    for i in countdown(a.limbs.len-1, 0):
      yield (c.limbs[i], a.limbs[i], b.limbs[i])

iterator mostToLeastSig*(a: SomeBigInteger): Word =
  ## Iterate from most to least significant word
  when cpuEndian == bigEndian:
    for i in 0 ..< a.limbs.len:
      yield a.limbs[i]
  else:
    for i in countdown(a.limbs.len-1, 0):
      yield a.limbs[i]

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

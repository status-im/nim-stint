# Stint
# Copyright 2018-Present Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Internal
  ./private/datatypes,
  ./private/uint_bitwise,
  ./private/uint_shift,
  ./private/uint_addsub,
  ./private/primitives/addcarry_subborrow

export StUint

# Initialization
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func setZero*(a: var StUint) =
  ## Set ``a`` to 0
  for i in 0 ..< a.limbs.len:
    a[i] = 0

func setSmallInt(a: var StUint, k: Word) =
  ## Set ``a`` to k
  when cpuEndian == littleEndian:
    a.limbs[0] = k
    for i in 1 ..< a.limbs.len:
      a.limbs[i] = 0
  else:
    a.limbs[^1] = k
    for i in 0 ..< a.limb.len - 1:
      a.limbs[i] = 0

func setOne*(a: var StUint) =
  setSmallInt(a, 1)

func zero*[bits: static[int]](T: typedesc[Stuint[bits]]): T {.inline.} =
  ## Returns the zero of the input type
  discard

func one*[bits: static[int]](T: typedesc[Stuint[bits]]): T {.inline.} =
  ## Returns the one of the input type
  result.setOne()

func high*[bits](_: typedesc[Stuint[bits]]): Stuint[bits] {.inline.} =
  for wr in leastToMostSig(result):
    wr = high(Word)
func low*[bits](_: typedesc[Stuint[bits]]): Stuint[bits] {.inline.} =
  discard

{.pop.}
# Comparisons
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func isZero*(a: Stuint): bool =
  for word in leastToMostSig(a):
    if word != 0:
      return false
  return true

func `==`*(a, b: Stuint): bool {.inline.} =
  ## Unsigned `equal` comparison
  for wa, wb in leastToMostSig(a, b):
    if wa != wb:
      return false
  return true

func `<`*(a, b: Stuint): bool {.inline.} =
  ## Unsigned `less than` comparison
  var diff: Word
  var borrow: Borrow
  for wa, wb in leastToMostSig(a, b):
    subB(borrow, diff, wa, wb, borrow)
  return bool(borrow)

func `<=`*(a, b: Stuint): bool {.inline.} =
  ## Unsigned `less or equal` comparison
  not(b < a)

func isOdd*(a: Stuint): bool {.inline.} =
  ## Returns true if input is off
  ## false otherwise
  bool(a.leastSignificantWord and 1)

func isEven*(a: Stuint): bool {.inline.} =
  ## Returns true if input is zero
  ## false otherwise
  not a.isOdd

{.pop.}
# Bitwise operations
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func `not`*(a: Stuint): Stuint =
  ## Bitwise complement of unsigned integer a
  ## i.e. flips all bits of the input
  result.bitnot(a)

func `or`*(a, b: Stuint): Stuint =
  ## `Bitwise or` of numbers a and b
  result.bitor(a, b)

func `and`*(a, b: Stuint): Stuint =
  ## `Bitwise and` of numbers a and b
  result.bitand(a, b)

func `xor`*(a, b: Stuint): Stuint =
  ## `Bitwise xor` of numbers x and y
  result.bitxor(a, b)

{.pop.} # End noInit

export
  countOnes,
  parity,
  leadingZeros,
  trailingZeros,
  firstOne

{.push raises: [], inline, gcsafe.}

func `shr`*(a: Stuint, k: SomeInteger): Stuint =
  ## Shift right by k bits
  result.shiftRight(a, k)

func `shl`*(a: Stuint, k: SomeInteger): Stuint =
  ## Shift left by k bits
  result.shiftLeft(a, k)

{.pop.}

# Addsub
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func `+`*(a, b: Stuint): Stuint =
  ## Addition for multi-precision unsigned int
  result.sum(a, b)

export `+=`

func `-`*(a, b: Stuint): Stuint =
  ## Substraction for multi-precision unsigned int
  result.diff(a, b)

export `-=`

export inc

func `+`*(a: Stuint, b: SomeUnsignedInt): Stuint =
  ## Addition for multi-precision unsigned int
  ## with an unsigned integer
  result.sum(a, Word(b))

export `+=`

{.pop.}

# Multiplication
# --------------------------------------------------------
# Multiplication is implemented in a separate file at the limb-level
# - It's too big to be inlined (especially with unrolled loops)
# - It's implemented at the limb-level so that
#   in the future Stuint[254] and Stuint256] share a common codepath

import ./private/uint_mul
{.push raises: [], inline, noInit, gcsafe.}

func `*`*(a, b: Stuint): Stuint =
  ## Integer multiplication
  result.limbs.prod(a.limbs, b.limbs)
  result.clearExtraBits()

{.pop.}

# Exponentiation
# --------------------------------------------------------

{.push raises: [], noInit, gcsafe.}

func pow*(a: Stuint, e: Natural): Stuint =
  ## Compute ``a`` to the power of ``e``,
  ## ``e`` must be non-negative

  # Implementation uses exponentiation by squaring
  # See Nim math module: https://github.com/nim-lang/Nim/blob/4ed24aa3eb78ba4ff55aac3008ec3c2427776e50/lib/pure/math.nim#L429
  # And Eli Bendersky's blog: https://eli.thegreenplace.net/2009/03/21/efficient-integer-exponentiation-algorithms

  var (a, e) = (a, e)
  result.setOne()

  while true:
    if bool(e and 1): # if y is odd
      result = result * a
    e = e shr 1
    if e == 0:
      break
    a = a * a

func pow*[aBits, eBits](a: Stuint[aBits], e: Stuint[eBits]): Stuint[aBits] =
  ## Compute ``x`` to the power of ``y``,
  ## ``x`` must be non-negative
  # Implementation uses exponentiation by squaring
  # See Nim math module: https://github.com/nim-lang/Nim/blob/4ed24aa3eb78ba4ff55aac3008ec3c2427776e50/lib/pure/math.nim#L429
  # And Eli Bendersky's blog: https://eli.thegreenplace.net/2009/03/21/efficient-integer-exponentiation-algorithms

  var (a, e) = (a, e)
  result.setOne()

  while true:
    if e.isOdd:
      result = result * a
    e = e shr 1
    if e.isZero:
      break
    a = a * a

{.pop.}

# Division & Modulo
# --------------------------------------------------------

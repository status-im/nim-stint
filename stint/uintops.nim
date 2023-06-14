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
  ./private/uint_mul,
  ./private/uint_div,
  ./private/primitives/addcarry_subborrow,
  stew/bitops2

export StUint

# Initialization
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func setZero*(a: var StUint) =
  ## Set ``a`` to 0
  for i in 0 ..< a.limbs.len:
    a.limbs[i] = 0

func setSmallInt(a: var StUint, k: Word) =
  ## Set ``a`` to k
  a.limbs[0] = k
  for i in 1 ..< a.limbs.len:
    a.limbs[i] = 0

func setOne*(a: var StUint) =
  setSmallInt(a, 1)

func zero*[bits: static[int]](T: typedesc[StUint[bits]]): T {.inline.} =
  ## Returns the zero of the input type
  discard

func one*[bits: static[int]](T: typedesc[StUint[bits]]): T {.inline.} =
  ## Returns the one of the input type
  result.setOne()

func high*[bits](_: typedesc[StUint[bits]]): StUint[bits] {.inline.} =
  for i in 0 ..< result.limbs.len:
    result[i] = high(Word)

func low*[bits](_: typedesc[StUint[bits]]): StUint[bits] {.inline.} =
  discard

{.pop.}
# Comparisons
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func isZero*(a: StUint): bool =
  for i in 0 ..< a.limbs.len:
    if a[i] != 0:
      return false
  return true

func `==`*(a, b: StUint): bool {.inline.} =
  ## Unsigned `equal` comparison
  for i in 0 ..< a.limbs.len:
    if a[i] != b[i]:
      return false
  return true

func `<`*(a, b: StUint): bool {.inline.} =
  ## Unsigned `less than` comparison
  var diff: Word
  var borrow: Borrow
  for i in 0 ..< a.limbs.len:
    subB(borrow, diff, a[i], b[i], borrow)
  return bool(borrow)

func `<=`*(a, b: StUint): bool {.inline.} =
  ## Unsigned `less or equal` comparison
  not(b < a)

func isOdd*(a: StUint): bool {.inline.} =
  ## Returns true if input is off
  ## false otherwise
  bool(a[0] and 1)

func isEven*(a: StUint): bool {.inline.} =
  ## Returns true if input is zero
  ## false otherwise
  not a.isOdd()

{.pop.}
# Bitwise operations
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func `not`*(a: StUint): StUint =
  ## Bitwise complement of unsigned integer a
  ## i.e. flips all bits of the input
  result.bitnot(a)

func `or`*(a, b: StUint): StUint =
  ## `Bitwise or` of numbers a and b
  result.bitor(a, b)

func `and`*(a, b: StUint): StUint =
  ## `Bitwise and` of numbers a and b
  result.bitand(a, b)

func `xor`*(a, b: StUint): StUint =
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

func `shr`*(a: StUint, k: Natural): StUint =
  ## Shift right by k bits
  result.shiftRight(a, k)

func `shl`*(a: StUint, k: Natural): StUint =
  ## Shift left by k bits
  result.shiftLeft(a, k)

func setBit*(a: var StUint, k: Natural) =
  let limbIndex = k div WordBitWidth
  let bitIndex = k mod WordBitWidth
  setBit(a.limbs[limbIndex], bitIndex)

func clearBit*(a: var StUint, k: Natural) =
  let limbIndex = k div WordBitWidth
  let bitIndex = k mod WordBitWidth
  clearBit(a.limbs[limbIndex], bitIndex)

func getBit*(a: StUint, k: Natural): bool =
  let limbIndex = k div WordBitWidth
  let bitIndex = k mod WordBitWidth
  getBit(a.limbs[limbIndex], bitIndex)

{.pop.}

# Addsub
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func `+`*(a, b: StUint): StUint =
  ## Addition for multi-precision unsigned int
  result.sum(a, b)

export `+=`

func `-`*(a, b: StUint): StUint =
  ## Substraction for multi-precision unsigned int
  result.diff(a, b)

export `-=`

export inc

func `+`*(a: StUint, b: SomeUnsignedInt): StUint =
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

{.push raises: [], inline, noinit, gcsafe.}

func `*`*(a, b: StUint): StUint =
  ## Integer multiplication
  result.limbs.prod(a.limbs, b.limbs)
  result.clearExtraBitsOverMSB()

{.pop.}

# Exponentiation
# --------------------------------------------------------

{.push raises: [], noinit, gcsafe.}

func pow*(a: StUint, e: Natural): StUint =
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

func pow*[aBits, eBits](a: StUint[aBits], e: StUint[eBits]): StUint[aBits] =
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
{.push raises: [], inline, noinit, gcsafe.}

func `div`*(x, y: StUint): StUint =
  ## Division operation for multi-precision unsigned uint
  var tmp{.noinit.}: StUint
  divRem(result.limbs, tmp.limbs, x.limbs, y.limbs)

func `mod`*(x, y: StUint): StUint =
  ## Remainder operation for multi-precision unsigned uint
  var tmp{.noinit.}: StUint
  divRem(tmp.limbs, result.limbs, x.limbs, y.limbs)

func divmod*(x, y: StUint): tuple[quot, rem: StUint] =
  ## Division and remainder operations for multi-precision unsigned uint
  divRem(result.quot.limbs, result.rem.limbs, x.limbs, y.limbs)

{.pop.}
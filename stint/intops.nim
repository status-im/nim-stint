# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ./private/datatypes,
  ./private/uint_bitwise,
  ./private/uint_shift,
  ./private/uint_addsub,
  ./uintops

export StInt

const
  signMask = 1.Word shl (WordBitWidth - 1)
  clearSignMask = not signMask

# Signedness
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func sign*(a: StInt): int =
  ## get the sign of `a`
  ## either -1, 0, or 1
  if a.imp.isZero: return 0
  if a.limbs[^1] < signMask: 1
  else: -1

func isNegative*(a: StInt): bool =
  a.limbs[^1] >= signMask

func clearMSB(a: var StInt) =
  a.limbs[^1] = a.limbs[^1] and clearSignMask

func setMSB(a: var StInt) =
  a.limbs[^1] = a.limbs[^1] or signMask

func negate*(a: var StInt) =
  ## two complement negation
  a.imp.bitnot(a.imp)
  a.imp.inc

func neg*(a: StInt): StInt =
  ## two complement negation
  result.imp.bitnot(a.imp)
  result.imp.inc

func abs*(a: StInt): StInt =
  if a.isNegative:
    a.neg
  else:
    a

func `-`*(a: StInt): StInt =
  ## two complement negation
  a.neg

{.pop.}

# Initialization
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func setZero*(a: var StInt) =
  ## Set ``a`` to 0
  a.imp.setZero

func setOne*(a: var StInt) =
  ## Set ``a`` to 1
  a.imp.setOne

func zero*[bits: static[int]](T: typedesc[StInt[bits]]): T =
  ## Returns the zero of the input type
  result.setZero

func one*[bits: static[int]](T: typedesc[StInt[bits]]): T =
  ## Returns the one of the input type
  result.setOne

func high*[bits](_: typedesc[StInt[bits]]): StInt[bits] =
  # The highest signed int has representation
  # 0b0111_1111_1111_1111 ....
  # so we only have to unset the most significant bit.
  for i in 0 ..< result.limbs.len:
    result[i] = high(Word)
  result.clearMSB

func low*[bits](_: typedesc[StInt[bits]]): StInt[bits] =
  # The lowest signed int has representation
  # 0b1000_0000_0000_0000 ....
  # so we only have to set the most significant bit.
  result.setZero
  result.setMSB

{.pop.}

# Comparisons
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func isZero*(a: StInt): bool =
  a.imp.isZero

func `==`*(a, b: StInt): bool =
  ## Unsigned `equal` comparison
  a.imp == b.imp

func `<`*(a, b: StInt): bool =
  ## Unsigned `less than` comparison
  let
    aNeg = a.isNegative
    bNeg = b.isNegative

  if aNeg xor bNeg:
    return aNeg

  a.imp < b.imp

func `<=`*(a, b: StInt): bool =
  ## Unsigned `less or equal` comparison
  not(b < a)

func isOdd*(a: StInt): bool =
  ## Returns true if input is off
  ## false otherwise
  bool(a[0] and 1)

func isEven*(a: StInt): bool =
  ## Returns true if input is zero
  ## false otherwise
  not a.isOdd()

{.pop.}

# Bitwise operations
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func `not`*(a: StInt): StInt =
  ## Bitwise complement of unsigned integer a
  ## i.e. flips all bits of the input
  result.imp.bitnot(a.imp)

func `or`*(a, b: StInt): StInt =
  ## `Bitwise or` of numbers a and b
  result.imp.bitor(a.imp, b.imp)

func `and`*(a, b: StInt): StInt =
  ## `Bitwise and` of numbers a and b
  result.imp.bitand(a.imp, b.imp)

func `xor`*(a, b: StInt): StInt =
  ## `Bitwise xor` of numbers x and y
  result.imp.bitxor(a.imp, b.imp)

{.pop.} # End noInit

{.push raises: [], inline, gcsafe.}

func `shr`*(a: StInt, k: SomeInteger): StInt =
  ## Shift right by k bits, arithmetically
  ## value < 0 ? ~(~value >> amount) : value >> amount
  if a.isNegative:
    var tmp: type a
    result.imp.bitnot(a.imp)
    tmp.imp.shiftRight(result.imp, k)
    result.imp.bitnot(tmp.imp)
  else:
    result.imp.shiftRight(a.imp, k)

func `shl`*(a: StInt, k: SomeInteger): StInt =
  ## Shift left by k bits
  result.imp.shiftLeft(a.imp, k)

func setBit*(a: var StInt, k: Natural) =
  ## set bit at position `k`
  ## k = 0..a.bits-1
  a.imp.setBit(k)

func clearBit*(a: var StInt, k: Natural) =
  ## set bit at position `k`
  ## k = 0..a.bits-1
  a.imp.clearBit(k)

func getBit*(a: StInt, k: Natural): bool =
  ## set bit at position `k`
  ## k = 0..a.bits-1
  a.imp.getBit(k)

{.pop.}

# Addsub
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func `+`*(a, b: StInt): StInt =
  ## Addition for multi-precision unsigned int
  result.imp.sum(a.imp, b.imp)

func `+=`*(a: var StInt, b: StInt) =
  ## In-place addition for multi-precision unsigned int
  a.imp.sum(a.imp, b.imp)

func `-`*(a, b: StInt): StInt =
  ## Substraction for multi-precision unsigned int
  result.imp.diff(a.imp, b.imp)

func `-=`*(a: var StInt, b: StInt) =
  ## In-place substraction for multi-precision unsigned int
  a.imp.diff(a.imp, b.imp)

func inc*(a: var StInt, w: Word = 1) =
  a.imp.inc(w)

func `+`*(a: StInt, b: SomeUnsignedInt): StInt =
  ## Addition for multi-precision unsigned int
  ## with an unsigned integer
  result.imp.sum(a.imp, Word(b))

func `+=`*(a: var StInt, b: SomeUnsignedInt) =
  ## In-place addition for multi-precision unsigned int
  ## with an unsigned integer
  a.imp.inc(Word(b))

{.pop.}

# Exponentiation
# --------------------------------------------------------

{.push raises: [], noinit, gcsafe.}

func isOdd(x: Natural): bool =
  bool(x and 1)

func pow*(a: StInt, e: Natural): StInt =
  ## Compute ``a`` to the power of ``e``,
  ## ``e`` must be non-negative
  if a.isNegative:
    let base = a.neg
    result.imp = base.imp.pow(e)
    if e.isOdd:
      result.negate
  else:
    result.imp = a.imp.pow(e)

func pow*[aBits, eBits](a: StInt[aBits], e: StInt[eBits]): StInt[aBits] =
  ## Compute ``x`` to the power of ``y``,
  ## ``x`` must be non-negative
  doAssert e.isNegative.not, "exponent must be non-negative"

  if a.isNegative:
    let base = a.neg
    result.imp = base.imp.pow(e.imp)
    if e.isOdd:
      result.negate
  else:
    result.imp = a.imp.pow(e.imp)

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
  ./private/uint_div,
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
  if a.impl.isZero: return 0
  if a.limbs[^1] < signMask: 1
  else: -1

func isNegative*(a: StInt): bool =
  a.limbs[^1] >= signMask

func isPositive*(a: StInt): bool =
  a.limbs[^1] < signMask

func clearMSB(a: var StInt) =
  a.limbs[^1] = a.limbs[^1] and clearSignMask

func setMSB(a: var StInt) =
  a.limbs[^1] = a.limbs[^1] or signMask

func negate*(a: var StInt) =
  ## two complement negation
  a.impl.bitnot(a.impl)
  a.impl.inc

func neg*(a: StInt): StInt =
  ## two complement negation
  result.impl.bitnot(a.impl)
  result.impl.inc

func abs*(a: StInt): StInt =
  ## Returns the positive value of Stint
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
  a.impl.setZero

func setOne*(a: var StInt) =
  ## Set ``a`` to 1
  a.impl.setOne

func zero*[bits: static[int]](T: typedesc[StInt[bits]]): T =
  ## Returns the zero of the input type
  result.setZero

func one*[bits: static[int]](T: typedesc[StInt[bits]]): T =
  ## Returns the one of the input type
  result.setOne

func high*[bits](_: typedesc[StInt[bits]]): StInt[bits] =
  ## Returns the highest value of Stint
  # The highest signed int has representation
  # 0b0111_1111_1111_1111 ....
  # so we only have to unset the most significant bit.
  for i in 0 ..< result.limbs.len:
    result[i] = high(Word)
  result.clearMSB

func low*[bits](_: typedesc[StInt[bits]]): StInt[bits] =
  ## Returns the lowest value of Stint
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
  a.impl.isZero

func isOne*(a: StInt): bool =
  a.impl.isOne

func `==`*(a, b: StInt): bool =
  ## Signed int `equal` comparison
  a.impl == b.impl

func `<`*(a, b: StInt): bool =
  ## Signed int `less than` comparison
  let
    aNeg = a.isNegative
    bNeg = b.isNegative

  if aNeg xor bNeg:
    return aNeg

  a.impl < b.impl

func `<=`*(a, b: StInt): bool =
  ## Signed int `less or equal` comparison
  not(b < a)

func isOdd*(a: StInt): bool =
  ## Returns true if input is odd
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
  ## Bitwise complement of signed integer a
  ## i.e. flips all bits of the input
  result.impl.bitnot(a.impl)

func `or`*(a, b: StInt): StInt =
  ## `Bitwise or` of numbers a and b
  result.impl.bitor(a.impl, b.impl)

func `and`*(a, b: StInt): StInt =
  ## `Bitwise and` of numbers a and b
  result.impl.bitand(a.impl, b.impl)

func `xor`*(a, b: StInt): StInt =
  ## `Bitwise xor` of numbers x and y
  result.impl.bitxor(a.impl, b.impl)

{.pop.} # End noInit

{.push raises: [], inline, gcsafe.}

func `shr`*(a: StInt, k: SomeInteger): StInt =
  ## Shift right by k bits, arithmetically
  ## value < 0 ? ~(~value >> amount) : value >> amount
  if a.isNegative:
    var tmp: type a
    result.impl.bitnot(a.impl)
    tmp.impl.shiftRight(result.impl, k)
    result.impl.bitnot(tmp.impl)
  else:
    result.impl.shiftRight(a.impl, k)

func `shl`*(a: StInt, k: SomeInteger): StInt =
  ## Shift left by k bits
  result.impl.shiftLeft(a.impl, k)

func setBit*(a: var StInt, k: Natural) =
  ## set bit at position `k`
  ## k = 0..a.bits-1
  a.impl.setBit(k)

func clearBit*(a: var StInt, k: Natural) =
  ## set bit at position `k`
  ## k = 0..a.bits-1
  a.impl.clearBit(k)

func getBit*(a: StInt, k: Natural): bool =
  ## set bit at position `k`
  ## k = 0..a.bits-1
  a.impl.getBit(k)

{.pop.}

# Addsub
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func `+`*(a, b: StInt): StInt =
  ## Addition for multi-precision signed int
  result.impl.sum(a.impl, b.impl)

func `+=`*(a: var StInt, b: StInt) =
  ## In-place addition for multi-precision signed int
  a.impl.sum(a.impl, b.impl)

func `-`*(a, b: StInt): StInt =
  ## Substraction for multi-precision signed int
  result.impl.diff(a.impl, b.impl)

func `-=`*(a: var StInt, b: StInt) =
  ## In-place substraction for multi-precision signed int
  a.impl.diff(a.impl, b.impl)

func inc*(a: var StInt, w: Word = 1) =
  a.impl.inc(w)

func `+`*(a: StInt, b: SomeUnsignedInt): StInt =
  ## Addition for multi-precision signed int
  ## with an unsigned integer
  result.impl.sum(a.impl, Word(b))

func `+=`*(a: var StInt, b: SomeUnsignedInt) =
  ## In-place addition for multi-precision signed int
  ## with an unsigned integer
  a.impl.inc(Word(b))

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
    result.impl = base.impl.pow(e)
    if e.isOdd:
      result.negate
  else:
    result.impl = a.impl.pow(e)

func pow*[aBits, eBits](a: StInt[aBits], e: StInt[eBits]): StInt[aBits] =
  ## Compute ``x`` to the power of ``y``,
  ## ``x`` must be non-negative
  doAssert e.isNegative.not, "exponent must be non-negative"

  if a.isNegative:
    let base = a.neg
    result.impl = base.impl.pow(e.impl)
    if e.isOdd:
      result.negate
  else:
    result.impl = a.impl.pow(e.impl)

{.pop.}

# Division & Modulo
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func `div`*(n, d: StInt): StInt =
  ## Division operation for multi-precision signed uint
  var tmp{.noinit.}: StInt

  if n.isPositive:
    if d.isPositive:
      # pos / pos
      result.impl = n.impl div d.impl
      return
    else:
      # pos / neg
      tmp = d.neg
      result.impl = n.impl div tmp.impl
      result.negate
      return

  let nneg = n.neg
  if d.isNegative:
    # neg / neg
    tmp = d.neg
    result.impl = nneg.impl div tmp.impl
    return

  # neg / pos
  result.impl = nneg.impl div d.impl
  result.negate

func `mod`*(x, y: StInt): StInt =
  ## Remainder operation for multi-precision signed uint
  ## The behavior is similar to Nim's `mod` operator
  ## The sign of the remainder will follow the sign of left operand
  let
    xIn = x.abs
    yIn = y.abs

  result.impl = xIn.impl mod yIn.impl
  if x.isNegative:
    result.negate

func divmodI(x, y: StInt): tuple[quot, rem: StInt] =
  ## Division and remainder operations for multi-precision uint
  ## with StInt operands
  divRem(result.quot.limbs, result.rem.limbs, x.limbs, y.limbs)

func divmod*(n, d: StInt): tuple[quot, rem: StInt] =
  ## Division and remainder operations for multi-precision signed uint
  ## The sign of the remainder will follow the sign of left operand
  var tmp{.noinit.}: StInt

  if n.isPositive:
    if d.isPositive:
      # pos / pos
      return divmodI(n, d)
    else:
      # pos / neg
      tmp = d.neg
      result = divmodI(n, tmp)
      result.quot.negate
      return

  let nneg = n.neg
  if d.isNegative:
    # neg / neg
    tmp = d.neg
    result = divmodI(nneg, tmp)
    result.rem.negate
    return

  # neg / pos
  result = divmodI(nneg, d)
  result.quot.negate
  result.rem.negate

{.pop.}

# Multiplication
# --------------------------------------------------------

{.push raises: [], inline, noinit, gcsafe.}

func `*`*(a, b: StInt): StInt =
  ## Signed integer multiplication
  let
    av = a.abs
    bv = b.abs

  result.impl = av.impl * bv.impl
  if a.isNegative xor b.isNegative:
    result.negate

{.pop.}

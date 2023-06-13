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
  signMask = 1.Word shl WordBitWidth
  clearSignMask = not signMask

# Signedness
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func sign*(a: StInt): int =
  if a.imp.isZero: return 0
  if a.limbs[^1] < signMask: 1
  else: -1

func isNegative*(a: StInt): bool =
  a.sign < 0

func clearSign(a: var StInt) =
  a.limbs[^1] = a.limbs[^1] and clearSignMask

func setSign(a: var StInt) =
  a.limbs[^1] = a.limbs[^1] or signMask

func negate*(a: var StInt) =
  a.imp.bitnot(a.imp)
  a.imp.inc

func neg*(a: StInt): StInt =
  result.imp.bitnot(a.imp)
  result.imp.inc

func abs*(a: StInt): StInt =
  if a.isNegative:
    a.neg
  else:
    a

func `-`*(a: StInt): StInt =
  a.neg

{.pop.}

# Initialization
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func setZero*(a: var StInt) =
  ## Set ``a`` to 0
  a.imp.setZero

func setOne*(a: var StInt) =
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
  result.clearSign

func low*[bits](_: typedesc[StInt[bits]]): StInt[bits] =
  # The lowest signed int has representation
  # 0b1000_0000_0000_0000 ....
  # so we only have to set the most significant bit.
  result.setZero
  result.setSign

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
    aSign = a.Sign
    bSign = b.Sign

  if aSign >= 0:
    if bSign < 0:
      return false
  elif bSign >= 0:
    return true

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
  ## ~(~a >> k)
  var tmp: type a
  result.imp.bitnot(a.imp)
  tmp.imp.shiftRight(result.imp, k)
  result.imp.bitnot(tmp.imp)

func `shl`*(a: StInt, k: SomeInteger): StInt =
  ## Shift left by k bits
  result.imp.shiftLeft(a.imp, k)

{.pop.}

# Addsub
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

#[
func `+`*(a, b: StInt): StInt =
  ## Addition for multi-precision unsigned int
  result.sum(a, b)

func `+=`*(a: var StInt, b: StInt) =
  ## In-place addition for multi-precision unsigned int
  a.sum(a, b)

func `-`*(a, b: StInt): StInt =
  ## Substraction for multi-precision unsigned int
  result.diff(a, b)

func `-=`*(a: var StInt, b: StInt) =
  ## In-place substraction for multi-precision unsigned int
  a.diff(a, b)

func inc*(a: var StInt, w: Word = 1) =

func `+`*(a: StInt, b: SomeUnsignedInt): StInt =
  ## Addition for multi-precision unsigned int
  ## with an unsigned integer
  result.sum(a, Word(b))

func `+=`*(a: var StInt, b: SomeUnsignedInt) =
  ## In-place addition for multi-precision unsigned int
  ## with an unsigned integer
  a.inc(Word(b))
]#

{.pop.}
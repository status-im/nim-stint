# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, ./uint_bitwise_ops

func `not`*(x: IntImpl): IntImpl {.inline.}=
  ## Bitwise complement of unsigned integer x
  applyHiLo(x, `not`)

func `or`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise or` of numbers x and y
  applyHiLo(x, y, `or`)

func `and`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise and` of numbers x and y
  applyHiLo(x, y, `and`)

func `xor`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise xor` of numbers x and y
  applyHiLo(x, y, `xor`)

func `shr`*(x: IntImpl, y: SomeInteger): IntImpl {.inline.}
  # Forward declaration

func convertImpl[T: SomeUnsignedInt](x: SomeSignedInt): T =
  cast[T](x)

func convertImpl[T: SomeSignedInt](x: SomeUnsignedInt): T =
  cast[T](x)

func convertImpl[T: UintImpl](x: IntImpl): T =
  result.hi = convertImpl[type(result.lo)](x.hi)
  result.lo = x.lo

func convertImpl[T: IntImpl](x: UintImpl): T =
  result.hi = convertImpl[type(result.hi)](x.hi)
  result.lo = x.lo

template convert[T](x: UintImpl|IntImpl|SomeInteger): T =
  when nimvm:
    # this is a workaround Nim VM inability to cast
    # something non integer
    convertImpl[T](x)
  else:
    cast[T](x)

func `shl`*(x: IntImpl, y: SomeInteger): IntImpl {.inline.}=
  ## Compute the `shift left` operation of x and y
  # Note: inlining this poses codegen/aliasing issue when doing `x = x shl 1`

  # TODO: would it be better to reimplement this with words iteration?
  const halfSize: type(y) = bitsof(x) div 2
  type HiType = type(result.hi)

  if y == 0:
    return x
  elif y == halfSize:
    result.hi = convert[HiType](x.lo)
  elif y < halfSize:
    result.hi = (x.hi shl y) or convert[HiType](x.lo shr (halfSize - y))
    result.lo = x.lo shl y
  else:
    result.hi = convert[HiType](x.lo shl (y - halfSize))

func `shr`*(x: IntImpl, y: SomeInteger): IntImpl {.inline.}=
  ## Compute the `shift right` operation of x and y
  ## Similar to C standard, result is undefined if y is bigger
  ## than the number of bits in x.
  const halfSize: type(y) = bitsof(x) div 2
  type LoType = type(result.lo)

  if y == 0:
    return x
  elif y == halfSize:
    result.lo = convert[LoType](x.hi)
  elif y < halfSize:
    result.lo = (x.lo shr y) or convert[LoType](x.hi shl (halfSize - y))
    result.hi = x.hi shr y
  else:
    result.lo = convert[LoType](x.hi shr (y - halfSize))

func ashr*(x: IntImpl, y: SomeInteger): IntImpl {.inline.}=
  ## Compute the `arithmetic shift right` operation of x and y
  ## Similar to C standard, result is undefined if y is bigger
  ## than the number of bits in x.
  const halfSize: type(y) = bitsof(x) div 2
  type LoType = type(result.lo)
  if y == 0:
    return x
  elif y == halfSize:
    result.lo = convert[LoType](x.hi)
    result.hi = ashr(x.hi, halfSize-1)
  elif y < halfSize:
    result.lo = (x.lo shr y) or convert[LoType](x.hi shl (halfSize - y))
    result.hi = ashr(x.hi, y)
  else:
    result.lo = convert[LoType](ashr(x.hi, (y - halfSize)))
    result.hi = ashr(x.hi, halfSize-1)

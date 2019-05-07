# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes

func toSubtype*[T: SomeInteger](b: bool, _: typedesc[T]): T {.inline.}=
  b.T

func toSubtype*[T: UintImpl | IntImpl](b: bool, _: typedesc[T]): T {.inline.}=
  type SubTy = type result.lo
  result.lo = toSubtype(b, SubTy)

func toUint*(n: UintImpl or IntImpl or SomeSignedInt): auto {.inline.}=
  ## Casts an unsigned integer to an uint of the same size
  # TODO: uint128 support
  when n.sizeof > 8:
    {.fatal: "Unreachable. You are trying to cast a StUint with more than 64-bit of precision" .}
  elif n.sizeof == 8:
    cast[uint64](n)
  elif n.sizeof == 4:
    cast[uint32](n)
  elif n.sizeof == 2:
    cast[uint16](n)
  else:
    cast[uint8](n)

func toUint*(n: SomeUnsignedInt): SomeUnsignedInt {.inline.}=
  ## No-op overload of multi-precision int casting
  n

func asDoubleUint*(n: UintImpl | SomeUnsignedInt): auto {.inline.} =
  ## Convert an integer or StUint to an uint with double the size
  type Double = (
    when n.sizeof == 4: uint64
    elif n.sizeof == 2: uint32
    else: uint16
  )

  n.toUint.Double

func toInt*(n: UintImpl or IntImpl or SomeInteger): auto {.inline.}=
  ## Casts an unsigned integer to an uint of the same size
  # TODO: uint128 support
  when n.sizeof > 8:
    {.fatal: "Unreachable. You are trying to cast a StUint with more than 64-bit of precision" .}
  elif n.sizeof == 8:
    cast[int64](n)
  elif n.sizeof == 4:
    cast[int32](n)
  elif n.sizeof == 2:
    cast[int16](n)
  else:
    cast[int8](n)

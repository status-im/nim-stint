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

func toSubtype*[T: UintImpl](b: bool, _: typedesc[T]): T {.inline.}=
  type SubTy = type result.lo
  result.lo = toSubtype(b, SubTy)

func toUint*(n: UintImpl): auto {.inline.}=
  ## Casts a multiprecision integer to an uint of the same size

  # TODO: uint128 support
  when n.sizeof > 8:
    raise newException("Unreachable. You are trying to cast a StUint with more than 64-bit of precision")
  elif n.sizeof == 8:
    cast[uint64](n)
  elif n.sizeof == 4:
    cast[uint32](n)
  elif n.sizeof == 2:
    cast[uint16](n)
  else:
    raise newException("Unreachable. StUint must be 16-bit minimum and a power of 2")

func toUint*(n: SomeUnsignedInt): SomeUnsignedInt {.inline.}=
  ## No-op overload of multi-precision int casting
  n

func asDoubleUint*(n: BaseUint): auto {.inline.} =
  ## Convert an integer or StUint to an uint with double the size

  type Double = (
    when n.sizeof == 4: uint64
    elif n.sizeof == 2: uint32
    else: uint16
  )

  n.toUint.Double


func toUintImpl*(n: uint16|uint32|uint64): auto {.inline.} =
  ## Cast an integer to the corresponding size UintImpl
  # Sometimes direct casting doesn't work and we must cast through a pointer

  when n is uint64:
    return (cast[ptr [UintImpl[uint32]]](unsafeAddr n))[]
  elif n is uint32:
    return (cast[ptr [UintImpl[uint16]]](unsafeAddr n))[]
  elif n is uint16:
    return (cast[ptr [UintImpl[uint8]]](unsafeAddr n))[]

func toUintImpl*(n: UintImpl): UintImpl {.inline.} =
  ## No op
  n

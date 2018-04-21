# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./uint_type,
        macros

proc initMpUintImpl*[InType, OutType](x: InType, _: typedesc[OutType]): OutType {.noSideEffect.} =

  const
    size_in = getSize(x)
    size_out = getSize(result)

  static:
    assert size_out >= size_in, "The result type size should be equal or bigger than the input type size"

  when OutType is SomeUnsignedInt:
    result = x.OutType
  elif size_in == size_out:
    result = cast[type result](x)
  else:
    result.lo = initMpUintImpl(x, type result.lo)

proc toSubtype*[T: SomeInteger](b: bool, _: typedesc[T]): T {.noSideEffect, inline.}=
  b.T

proc toSubtype*[T: MpUintImpl](b: bool, _: typedesc[T]): T {.noSideEffect, inline.}=
  type SubTy = type result.lo
  result.lo = toSubtype(b, SubTy)

proc zero*[T: BaseUint](_: typedesc[T]): T {.noSideEffect, inline.}=
  discard

proc one*[T: BaseUint](_: typedesc[T]): T {.noSideEffect, inline.}=
  when T is SomeUnsignedInt:
    result = T(1)
  else:
    result.lo = one(type result.lo)

proc toUint*(n: MpUIntImpl): auto {.noSideEffect, inline.}=
  ## Casts a multiprecision integer to an uint of the same size

  # TODO: uint128 support
  when n.sizeof > 8:
    raise newException("Unreachable. You are trying to cast a MpUint with more than 64-bit of precision")
  elif n.sizeof == 8:
    cast[uint64](n)
  elif n.sizeof == 4:
    cast[uint32](n)
  elif n.sizeof == 2:
    cast[uint16](n)
  else:
    raise newException("Unreachable. MpUInt must be 16-bit minimum and a power of 2")

proc toUint*(n: SomeUnsignedInt): SomeUnsignedInt {.noSideEffect, inline.}=
  ## No-op overload of multi-precision int casting
  n

proc asDoubleUint*(n: BaseUint): auto {.noSideEffect, inline.} =
  ## Convert an integer or MpUint to an uint with double the size

  type Double = (
    when n.sizeof == 4: uint64
    elif n.sizeof == 2: uint32
    else: uint16
  )

  n.toUint.Double


proc toMpUintImpl*(n: uint16|uint32|uint64): auto {.noSideEffect, inline.} =
  ## Cast an integer to the corresponding size MpUintImpl
  # Sometimes direct casting doesn't work and we must cast through a pointer

  when n is uint64:
    return (cast[ptr [MpUintImpl[uint32]]](unsafeAddr n))[]
  elif n is uint32:
    return (cast[ptr [MpUintImpl[uint16]]](unsafeAddr n))[]
  elif n is uint16:
    return (cast[ptr [MpUintImpl[uint8]]](unsafeAddr n))[]

proc toMpUintImpl*(n: MpUintImpl): MpUintImpl {.noSideEffect, inline.} =
  ## No op
  n

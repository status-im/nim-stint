# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ../uint_type,
        macros

template convBool(typ: typedesc): untyped =
  # needed for carry conversion
  converter boolMpUint*(b: bool): MpUint[typ] {.noSideEffect, inline.}=
    result.lo = b.typ

convBool(uint8)
convBool(uint16)
convBool(uint32)
convBool(uint64)

proc zero*(typ: typedesc[BaseUint]): typ {.compileTime.} =
  typ()

proc one*[T: BaseUint](typ: typedesc[T]): T {.noSideEffect, inline.}=
  when T is SomeUnsignedInt:
    T(1)
  else:
    result.lo = 1

proc asUint*[T: MpUInt](n: T): auto {.noSideEffect, inline.}=
  ## Casts a multiprecision integer to an uint of the same size

  when T.sizeof > 8:
    raise newException("Unreachable. You are trying to cast a MpUint with more than 64-bit of precision")
  elif T.sizeof == 8:
    cast[uint64](n)
  elif T.sizeof == 4:
    cast[uint32](n)
  elif T.sizeof == 2:
    cast[uint16](n)
  else:
    raise newException("Unreachable. MpUInt must be 16-bit minimum and a power of 2")

proc asUint*[T: SomeUnsignedInt](n: T): T {.noSideEffect, inline.}=
  ## No-op overload of multi-precision int casting
  n

proc asDoubleUint*[T: BaseUint](n: T): auto {.noSideEffect, inline.} =
  ## Convert an integer or MpUint to an uint with double the size

  type Double = (
    when T.sizeof == 4: uint64
    elif T.sizeof == 2: uint32
    else: uint16
  )

  n.asUint.Double


proc toMpUint*[T: SomeInteger](n: T): auto {.noSideEffect, inline.} =
  ## Cast an integer to the corresponding size MpUint
  # Sometimes direct casting doesn't work and we must cast through a pointer

  when T is uint64:
    return (cast[ptr [MpUint[uint32]]](unsafeAddr n))[]
  elif T is uint32:
    return (cast[ptr [MpUint[uint16]]](unsafeAddr n))[]
  elif T is uint16:
    return (cast[ptr [MpUint[uint8]]](unsafeddr n))[]
  else:
    raise newException(ValueError, "You can only cast uint16, uint32 or uint64 to multiprecision integers")

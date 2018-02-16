# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).


type
  MpUint*{.packed.}[BaseUint] = object
    when system.cpuEndian == littleEndian:
      lo*, hi*: BaseUint
    else:
      hi*, lo*: BaseUint

  BaseUint* = SomeUnsignedInt or MpUint


  UInt128* = MpUint[uint64]
  UInt256* = MpUint[UInt128]


template convBool(typ: typedesc): untyped =
  converter boolMpUint*(b: bool): MpUint[typ] {.noSideEffect, inline.}=
    result.lo = b.typ

convBool(uint8)
convBool(uint16)
convBool(uint32)
convBool(uint64)
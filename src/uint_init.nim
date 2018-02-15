# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import  typetraits

import  private/utils,
        uint_type

proc initMpUint*[T: BaseUint; U: BaseUInt](n: T, base_type: typedesc[U]): MpUint[U] {.noSideEffect.} =
  let len = n.bit_length
  const sizeU_bits = sizeof(U) * 8

  when not (T is type result):
    if len >= 2 * sizeU_bits:
      # Todo print n
      raise newException(ValueError, "Input cannot be stored in a multi-precision integer of base " & $T.name &
                                        "\nIt requires at least " & $len & " bits of precision")
    elif len < sizeU_bits:
      result.lo = n.U # TODO: converter for MpInts
    else:
      raise newException(ValueError, "Unsupported at the moment: are you trying to build MpUint[uint32] from an uint64?")
  else:
    n

proc u128*[T: BaseUInt](n: T): UInt128 {.noSideEffect, inline.}=
  initMpUint(n, uint64)

proc u256*[T: BaseUInt](n: T): UInt256 {.noSideEffect, inline.}=
  initMpUint(n, UInt256)
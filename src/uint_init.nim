# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  typetraits

import  ./private/[bithacks, conversion],
        ./uint_type

proc initMpUint*[T: BaseUint; U: BaseUInt](n: T, base_type: typedesc[U]): MpUint[U] {.noSideEffect.} =
  when not (T is type result):
    let len = n.bit_length
    const size = sizeof(U) * 8
    if len >= 2 * size:
      # Todo print n
      raise newException(ValueError, "Input cannot be stored in a multi-precision integer of base " & $T.name &
                                        "\nIt requires at least " & $len & " bits of precision")
    elif len < size:
      result.lo = n.U # TODO: converter for MpInts
    else: # Both have the same size and memory representation
      assert len == size
      n.toMpUint
  else:
    n

proc u128*[T: BaseUInt](n: T): UInt128 {.noSideEffect, inline.}=
  initMpUint(n, uint64)

proc u256*[T: BaseUInt](n: T): UInt256 {.noSideEffect, inline.}=
  initMpUint(n, UInt256)

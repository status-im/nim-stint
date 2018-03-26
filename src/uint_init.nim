# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  typetraits

import  ./private/bithacks, ./private/conversion,
        ./private/uint_type

import typetraits

proc initMpUint*(n: SomeUnsignedInt, bits: static[int]): MpUint[bits] {.noSideEffect.} =

  when result.data is MpuintImpl:
    type SubTy = type result.data.lo

    let len = n.bit_length
    if len > bits:
      # Todo print n
      raise newException(ValueError, "Input cannot be stored in a multi-precision " & $bits & "-bit integer." &
                                    "\nIt requires at least " & $len & " bits of precision")
    elif len < bits div 2:
      result.data.lo = SubTy(n)
    else: # Both have the same size and memory representation
      when bits == 16:
        # TODO: If n is int it's not properly converted at the input
        result.data = toMpUintImpl n.uint16
      elif bits == 32:
        result.data = toMpUintImpl n.uint32
      elif bits == 64:
        result.data = toMpUintImpl n.uint64
      else:
        {.fatal, "unreachable".}
  else:
    result.data = (type result.data)(n)

proc u128*(n: SomeUnsignedInt): MpUint[128] {.noSideEffect, inline, noInit.}=
  initMpUint[128](n)

proc u256*(n: SomeUnsignedInt): MpUint[256] {.noSideEffect, inline, noInit.}=
  initMpUint[256](n)

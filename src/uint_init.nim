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

proc initMpUint*[T: SomeInteger](n: T, bits: static[int]): MpUint[bits] {.noSideEffect.} =
  assert n >= 0.T
  when result.data is MpuintImpl:
    static: echo result.data.type.name
    let len = n.bit_length
    if len > bits:
      raise newException(ValueError, "Input " & $n & " cannot be stored in a multi-precision " &
                                    $bits & "-bit integer." &
                                    "\nIt requires at least " & $len & " bits of precision")
    elif len < bits div 2:
      result.data.lo = initMpUintImpl(n, type result.data.lo)
    else: # Both have the same size and memory representation
      when bits == 16:
        # TODO: If n is int it's not properly converted at the input
        result.data = toMpUintImpl n.uint16
      elif bits == 32:
        result.data = toMpUintImpl n.uint32
      elif bits == 64:
        result.data = toMpUintImpl n.uint64
      else:
        raise newException(ValueError, "Fatal")
  else:
    result.data = (type result.data)(n)

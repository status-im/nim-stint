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

  when result.isMpUintImpl: # SomeUnsignedInt doesn't work here ...
    type SubTy = subtype(result)

    let len = n.bit_length
    if len > bits:
      # Todo print n
      raise newException(ValueError, "Input cannot be stored in a multi-precision " & $bits & "-bit integer." &
                                    "\nIt requires at least " & $len & " bits of precision")
    elif len < bits div 2:
      var result_impl = cast[ptr getMpUintImpl(bits)](addr result)

      result_impl.lo = SubTy(n) # TODO: converter for MpInts
    else: # Both have the same size and memory representation
      result = (type result)(n.toMpUintImpl)
  else:
    result = (type result)(n)

proc u128*(n: SomeUnsignedInt): MpUint[128] {.noSideEffect, inline, noInit.}=
  initMpUint[128](n)

proc u256*(n: SomeUnsignedInt): MpUint[256] {.noSideEffect, inline, noInit.}=
  initMpUint[256](n)

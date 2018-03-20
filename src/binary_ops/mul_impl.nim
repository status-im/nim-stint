# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../uint_type, ../uint_init
import ./addsub_impl

import typetraits

proc `*`*(x, y: MpUint): MpUint {.noSideEffect.}=
  ## Multiplication for multi-precision unsigned uint

  mixin naiveMul

  result = naiveMul(x.lo, y.lo)
  result.hi += (naiveMul(x.hi, y.lo) + naiveMul(x.lo, y.hi)).lo

  debugEcho "Within `*` result: " & $result
  debugEcho "Within `*` result: " & $result.type.name

# Comment the following to remove the memory corruption
proc naiveMul*(x, y: uint8): MpUint[16] {.noSideEffect.}=
  result = toMpuint(x.uint16 * y.uint16)

proc naiveMul*(x, y: uint16): MpUint[32] {.noSideEffect.}=
  result = toMpuint(x.uint32 * y.uint32)
  debugEcho "naiveMul cast16:" & $result

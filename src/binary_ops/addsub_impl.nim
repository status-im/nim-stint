# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../uint_type

proc `+=`*(x: var MpUint, y: MpUint) {.noSideEffect.}=
  ## In-place addition for multi-precision unsigned int
  #
  # Optimized assembly should contain adc instruction (add with carry)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type SubT = type x.lo
  let tmp = x.lo

  x.lo += y.lo
  x.hi += SubT(x.lo < tmp) + y.hi

proc `+`*(x, y: MpUint): MpUint {.noSideEffect, noInit, inline.}=
  # Addition for multi-precision unsigned int
  result = x
  result += y

  debugEcho "+: " & $result

proc `-=`*(x: var MpUint, y: MpUint) {.noSideEffect.}=
  ## In-place substraction for multi-precision unsigned int
  #
  # Optimized assembly should contain sbb instruction (substract with borrow)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type SubT = type x.lo
  let tmp = x.lo

  x.lo -= y.lo
  x.hi -= SubT(x.lo > tmp) + y.hi

proc `-`*(x, y: MpUint): MpUint {.noSideEffect, noInit, inline.}=
  # Substraction for multi-precision unsigned int
  result = x
  result -= y


# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./bithacks, ./conversion,
        ./uint_type,
        ./uint_comparison,
        ./uint_bitwise_ops

# ############ Addition & Substraction ############ #

proc `+=`*(x: var UintImpl, y: UintImpl) {.noSideEffect, inline.}=
  ## In-place addition for multi-precision unsigned int

  type SubTy = type x.lo
  x.lo += y.lo
  x.hi += (x.lo < y.lo).toSubtype(SubTy) + y.hi

proc `+`*(x, y: UintImpl): UintImpl {.noSideEffect, noInit, inline.}=
  # Addition for multi-precision unsigned int
  result = x
  result += y

proc `-`*(x, y: UintImpl): UintImpl {.noSideEffect, noInit, inline.}=
  # Substraction for multi-precision unsigned int

  type SubTy = type x.lo
  result.lo = x.lo - y.lo
  result.hi = x.hi - y.hi - (x.lo < y.lo).toSubtype(SubTy)

proc `-=`*(x: var UintImpl, y: UintImpl) {.noSideEffect, inline.}=
  ## In-place substraction for multi-precision unsigned int
  x = x - y

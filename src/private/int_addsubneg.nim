# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./datatypes, ./int_bitwise_ops, ./initialization

func `+=`*(x: var IntImpl, y: IntImpl) {.inline.}=
  ## In-place addition for multi-precision signed int

  type SubTy = type x.lo
  x.lo += y.lo
  x.hi += (x.lo < y.lo).toSubtype(SubTy) + y.hi

func `+`*(x, y: UintImpl): UintImpl {.noInit, inline.}=
  # Addition for multi-precision signed int
  result = x
  result += y

func `-`*[T: IntImpl](x: T): T {.noInit, inline.}=
  result = not x
  result += one(T)

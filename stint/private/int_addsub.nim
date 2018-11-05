# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ./datatypes, ./conversion, ./int_comparison,
  ./uint_addsub, ./uint_comparison

func `+`*(x, y: IntImpl): IntImpl {.inline.}=
  # Addition for multi-precision signed int.
  type SubTy = type x.hi
  result.lo = x.lo + y.lo
  result.hi = (result.lo < y.lo).toSubtype(SubTy) + x.hi + y.hi

  when compileOption("boundChecks"):
    if unlikely(
      not(result.isNegative xor x.isNegative) or
      not(result.isNegative xor y.isNegative)
    ):
      return
    raise newException(OverflowError, "Addition overflow")

func `+=`*(x: var IntImpl, y: IntImpl) {.inline.}=
  ## In-place addition for multi-precision signed int.
  x = x + y

func `-`*(x, y: IntImpl): IntImpl {.inline.}=
  # Substraction for multi-precision signed int.

  type SubTy = type x.hi
  result.lo = x.lo - y.lo
  result.hi = x.hi - y.hi - (x.lo < y.lo).toSubtype(SubTy)

  when compileOption("boundChecks"):
    if unlikely(
      not(result.isNegative xor x.isNegative) or
      not(result.isNegative xor y.isNegative.not)
    ):
      return
    raise newException(OverflowError, "Substraction underflow")

func `-=`*(x: var IntImpl, y: IntImpl) {.inline.}=
  ## In-place substraction for multi-precision signed int.
  x = x - y

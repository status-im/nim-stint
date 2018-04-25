# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, ./int_bitwise_ops, ./conversion,
        ./initialization, ./as_signed_words, ./int_highlow

func `+`*(x, y: IntImpl): IntImpl {.noInit, inline.}=
  # Addition for multi-precision signed int.
  type SubTy = type x.lo
  result.lo = x.lo + y.lo
  result.hi = (x.lo < y.lo).toSubtype(SubTy) + x.hi + y.hi

  when compileOption("boundChecks"):
    if unlikely(
      ((result.most_significant_word xor x.most_significant_word) >= 0) or
      ((result.most_significant_word xor y.most_significant_word) >= 0)
    ):
      return
    raise newException(OverflowError, "Addition overflow")

func `+=`*(x: var IntImpl, y: IntImpl) {.inline.}=
  ## In-place addition for multi-precision signed int.
  x = x + y

func `-`*[T: IntImpl](x: T): T {.noInit, inline.}=
  # Negate a multi-precision signed int.

  when compileOption("boundChecks"):
    if unlikely(x == low(T)):
      raise newException(OverflowError, "The lowest negative number cannot be negated")

  result = not x
  result += one(T)

func `-`*(x, y: IntImpl): IntImpl {.noInit, inline.}=
  # Substraction for multi-precision signed int.

  type SubTy = type x.lo
  result.lo = x.lo - y.lo
  result.hi = x.hi - y.hi - (x.lo < y.lo).toSubtype(SubTy)

  when compileOption("boundChecks"):
    if unlikely(
      ((result.most_significant_word xor x.most_significant_word) >= 0) or
      ((result.most_significant_word xor (not y).most_significant_word) >= 0)
    ):
      return
    raise newException(OverflowError, "Substraction underflow")

func `-=`*(x: var IntImpl, y: IntImpl) {.inline.}=
  ## In-place substraction for multi-precision signed int.
  x = x - y

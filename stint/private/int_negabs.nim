# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ./datatypes,
  ./initialization, ./int_highlow,
  ./int_addsub, ./int_comparison, ./int_bitwise_ops

func `-`*(x: IntImpl): IntImpl {.inline.}=
  # Negate a multi-precision signed int.

  when compileOption("boundChecks"):
    if unlikely(x == low(type x)):
      raise newException(OverflowError, "The lowest negative number cannot be negated")

  result = not x
  result += one(type x)

func abs*[T: IntImpl](x: T): T {.inline.}=
  ## Returns the absolute value of a signed int.

  result =  if x.isNegative: -x
            else: x

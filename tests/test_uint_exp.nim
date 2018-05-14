# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/stint, unittest, math

suite "Testing unsigned exponentiation":
  test "Simple exponentiation 5^3":

    let
      a = 5'u64
      b = 3
      u = a.stuint(64)

    check: cast[uint64](u ^ b) == a ^ b

  test "12 ^ 34 == 4922235242952026704037113243122008064":
    # https://www.wolframalpha.com/input/?i=12+%5E+34
    let
      a = 12.stuint(256)
      b = 34

    check: a^b == "4922235242952026704037113243122008064".u256

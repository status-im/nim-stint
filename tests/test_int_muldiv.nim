# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/stint, unittest

suite "Testing signed int multiplication implementation":
  test "Multiplication with result fitting in low half":

    let a = 10000.stint(64)
    let b = 10000.stint(64)

    check: cast[int64](a*b) == 100_000_000'i64 # need 27-bits

  test "Multiplication with result overflowing low half":

    let a = 1_000_000.stint(64)
    let b = 1_000_000.stint(64)

    check: cast[int64](a*b) == 1_000_000_000_000'i64 # need 40 bits

  test "Multiplication with result fitting in low half - opposite signs":

    let a = -10000.stint(64)
    let b = 10000.stint(64)

    check:
      cast[int64](a*b) == -100_000_000'i64 # need 27-bits
      cast[int64](b*a) == -100_000_000'i64


  test "Multiplication with result overflowing low half - opposite signs":

    let a = -1_000_000.stint(64)
    let b = 1_000_000.stint(64)

    check:
      cast[int64](a*b) == -1_000_000_000_000'i64 # need 40 bits
      cast[int64](b*a) == -1_000_000_000_000'i64

  test "Multiplication with result fitting in low half - both negative":

    let a = -10000.stint(64)
    let b = -10000.stint(64)

    check: cast[int64](a*b) == 100_000_000'i64 # need 27-bits

  test "Multiplication with result overflowing low half - both negative":

    let a = -1_000_000.stint(64)
    let b = -1_000_000.stint(64)

    check: cast[int64](a*b) == 1_000_000_000_000'i64 # need 40 bits

# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest

suite "Signed int - Testing comparison operators":
  let
    a = 10'i16.stint(16)
    b = 15'i16.stint(16)
    c = 150'i16.stint(16)

  test "< operator":
    check:
      a < b
      not (a + b < b)
      not (a + a + a < b + b)
      -c < c
      -c < a
      -b < -a
      not(-b < -b)

  test "<= operator":
    check:
      a <= b
      not (a + b <= b)
      a + a + a <= b + b
      -c <= c
      -c <= a
      -b <= -a
      -b <= -b

  test "> operator":
    check:
      b > a
      not (b > a + b)
      not (b + b > a + a + a)
      c > -c
      a > -c
      b > -c
      not(-b > -b)

  test ">= operator":
    check:
      b >= a
      not (b >= a + b)
      b + b >= a + a + a
      c >= -c
      a >= -c
      b >= -c
      -b >= -b

  test "isOdd/isEven":
    check:
      a.isEven
      not a.isOdd
      b.isOdd
      not b.isEven
      c.isEven
      not c.isOdd

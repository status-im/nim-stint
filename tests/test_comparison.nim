# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/mpint, unittest

suite "Testing comparison operators":
  let
    a = initMpUint(10, uint8)
    b = initMpUint(15, uint8)
    c = 150'u16

  test "< operator":
    check: a < b
    check: not (a + b < b)
    check: not (a + a + a < b + b)
    check: not (a * b < cast[Mpuint[uint8]](c))

  test "<= operator":
    check: a <= b
    check: not (a + b <= b)
    check: a + a + a <= b + b
    check: a * b <= cast[Mpuint[uint8]](c)

  test "> operator":
    check: b > a
    check: not (b > a + b)
    check: not (b + b > a + a + a)
    check: not (cast[Mpuint[uint8]](c) > a * b)

  test ">= operator":
    check: b >= a
    check: not (b >= a + b)
    check: b + b >= a + a + a
    check: cast[Mpuint[uint8]](c) >= a * b

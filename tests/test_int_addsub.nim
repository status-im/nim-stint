# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/stint, unittest

suite "Testing signed addition implementation":
  test "In-place addition gives expected result":

    var a = 20182018.stint(64)
    let b = 20172017.stint(64)

    a += b

    check: cast[int64](a) == 20182018'i64 + 20172017'i64

  test "Addition gives expected result":

    let a = 20182018.stint(64)
    let b = 20172017.stint(64)

    check: cast[int64](a+b) == 20182018'i64 + 20172017'i64

  test "When the low half overflows, it is properly carried":
    # uint8 (low half) overflow at 255
    let a = 100'i16.stint(16)
    let b = 100'i16.stint(16)

    check: cast[int16](a+b) == 200

suite "Testing signed substraction implementation":
  test "In-place substraction gives expected result":

    var a = 20182018.stint(64)
    let b = 20172017.stint(64)

    a -= b

    check: cast[int64](a) == 20182018'i64 - 20172017'i64

  test "Substraction gives expected result":

    let a = 20182018.stint(64)
    let b = 20172017.stint(64)

    check: cast[int64](a-b) == 20182018'i64 - 20172017'i64

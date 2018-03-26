# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/mpint, unittest

suite "Testing addition implementation":
  test "In-place addition gives expected result":

    var a = 20182018.initMpUint(64)
    let b = 20172017.initMpUint(64)

    a += b

    check: cast[uint64](a) == 20182018'u64 + 20172017'u64

  test "Addition gives expected result":

    let a = 20182018.initMpUint(64)
    let b = 20172017.initMpUint(64)

    check: cast[uint64](a+b) == 20182018'u64 + 20172017'u64

  test "When the low half overflows, it is properly carried":
    # uint8 (low half) overflow at 255
    let a = 100.initMpUint(16)
    let b = 100.initMpUint(16)

    check: cast[uint16](a+b) == 200

  test "Full overflow is handled like native unsigned types":
    # uint16 overflows after 65535
    let a = 100.initMpUint(16)
    var z = 0.initMpUint(16)
    let o = 36.initMpUint(16)

    for _ in 0 ..< 655:
      z += a

    check: cast[uint16](z) == 65500
    check: cast[uint16](z + o) == 0

    z += a
    check: cast[uint16](z) == 64

    z += a
    check: cast[uint16](z) == 164

suite "Testing substraction implementation":
  test "In-place substraction gives expected result":

    var a = 20182018.initMpUint(64)
    let b = 20172017.initMpUint(64)

    a -= b

    check: cast[uint64](a) == 20182018'u64 - 20172017'u64

  test "Substraction gives expected result":

    let a = 20182018.initMpUint(64)
    let b = 20172017.initMpUint(64)

    check: cast[uint64](a-b) == 20182018'u64 - 20172017'u64

  test "Full overflow is handled like native unsigned types":
    # uint16 overflows after 65535
    let a = 100.initMpUint(16)
    let b = 101.initMpUint(16)

    check: cast[uint16](a-b) == high(uint16)

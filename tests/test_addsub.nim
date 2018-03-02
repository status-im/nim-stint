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

    var a = initMpUint(20182018, uint32)
    let b = initMpUint(20172017, uint32)

    a += b

    check: cast[uint64](a) == 20182018'u64 + 20172017'u64

  test "Addition gives expected result":

    let a = initMpUint(20182018, uint32)
    let b = initMpUint(20172017, uint32)

    check: cast[uint64](a+b) == 20182018'u64 + 20172017'u64

  test "When the low half overflows, it is properly carried":
    # uint8 (low half) overflow at 255
    let a = initMpUint(100, uint8)
    let b = initMpUint(100, uint8)

    check: cast[uint16](a+b) == 200

  test "Full overflow is handled like native unsigned types":
    # uint16 overflows after 65535
    let a = initMpUint(100, uint8)
    var z = initMpUint(0, uint8)
    let o = initMpUint(36, uint8)

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

    var a = initMpUint(20182018, uint32)
    let b = initMpUint(20172017, uint32)

    a -= b

    check: cast[uint64](a) == 20182018'u64 - 20172017'u64

  test "Substraction gives expected result":

    let a = initMpUint(20182018, uint32)
    let b = initMpUint(20172017, uint32)

    check: cast[uint64](a-b) == 20182018'u64 - 20172017'u64

  test "Full overflow is handled like native unsigned types":
    # uint16 overflows after 65535
    let a = initMpUint(100, uint8)
    let b = initMpUint(101, uint8)

    check: cast[uint16](a-b) == high(uint16)

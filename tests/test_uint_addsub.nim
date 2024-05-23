# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template chkAddition(a, b, c, bits: untyped) =
  block:
    let x = stuint(a, bits)
    let y = stuint(b, bits)
    check x + y == stuint(c, bits)

template chkInplaceAddition(a, b, c, bits: untyped) =
  block:
    var x = stuint(a, bits)
    x += stuint(b, bits)
    check x == stuint(c, bits)

template chkSubstraction(a, b, c, bits: untyped) =
  block:
    let x = stuint(a, bits)
    let y = stuint(b, bits)
    check x - y == stuint(c, bits)

template chkInplaceSubstraction(a, b, c, bits: untyped) =
  block:
    var x = stuint(a, bits)
    x -= stuint(b, bits)
    check x == stuint(c, bits)

suite "Wider unsigned int addsub coverage":
  test "addition":
    #[chkAddition(0'u8, 0'u8, 0'u8, 8)
    chkAddition(high(uint8) - 17'u8, 17'u8, high(uint8), 8)
    chkAddition(low(uint8), 17'u8, low(uint8) + 17'u8, 8)

    chkAddition(0'u8, 0'u8, 0'u8, 16)
    chkAddition(high(uint8) - 17'u8, 17'u8, high(uint8), 16)
    chkAddition(low(uint8), 17'u8, low(uint8) + 17'u8, 16)
    chkAddition(high(uint16) - 17'u16, 17'u16, high(uint16), 16)
    chkAddition(low(uint16), 17'u16, low(uint16) + 17'u16, 16)

    chkAddition(0'u8, 0'u8, 0'u8, 32)
    chkAddition(high(uint8) - 17'u8, 17'u8, high(uint8), 32)
    chkAddition(low(uint8), 17'u8, low(uint8) + 17'u8, 32)
    chkAddition(high(uint16) - 17'u16, 17'u16, high(uint16), 32)
    chkAddition(low(uint16), 17'u16, low(uint16) + 17'u16, 32)
    chkAddition(high(uint32) - 17'u32, 17'u32, high(uint32), 32)
    chkAddition(low(uint32), 17'u32, low(uint32) + 17'u32, 32)

    chkAddition(0'u8, 0'u8, 0'u8, 64)
    chkAddition(high(uint8) - 17'u8, 17'u8, high(uint8), 64)
    chkAddition(low(uint8), 17'u8, low(uint8) + 17'u8, 64)
    chkAddition(high(uint16) - 17'u16, 17'u16, high(uint16), 64)
    chkAddition(low(uint16), 17'u16, low(uint16) + 17'u16, 64)
    chkAddition(high(uint32) - 17'u32, 17'u32, high(uint32), 64)
    chkAddition(low(uint32), 17'u32, low(uint32) + 17'u32, 64)
    chkAddition(high(uint64) - 17'u64, 17'u64, high(uint64), 64)
    chkAddition(low(uint64), 17'u64, low(uint64) + 17'u64, 64)]#

    chkAddition(0'u8, 0'u8, 0'u8, 128)
    chkAddition(high(uint8) - 17'u8, 17'u8, high(uint8), 128)
    chkAddition(low(uint8), 17'u8, low(uint8) + 17'u8, 128)
    chkAddition(high(uint16) - 17'u16, 17'u16, high(uint16), 128)
    chkAddition(low(uint16), 17'u16, low(uint16) + 17'u16, 128)
    chkAddition(high(uint32) - 17'u32, 17'u32, high(uint32), 128)
    chkAddition(low(uint32), 17'u32, low(uint32) + 17'u32, 128)
    chkAddition(high(uint64) - 17'u64, 17'u64, high(uint64), 128)
    chkAddition(low(uint64), 17'u64, low(uint64) + 17'u64, 128)

  test "inplace addition":
    #[chkInplaceAddition(0'u8, 0'u8, 0'u8, 8)
    chkInplaceAddition(high(uint8) - 17'u8, 17'u8, high(uint8), 8)
    chkInplaceAddition(low(uint8) + 17'u8, 17'u8, low(uint8) + 34'u8, 8)

    chkInplaceAddition(0'u8, 0'u8, 0'u8, 16)
    chkInplaceAddition(high(uint8) - 17'u8, 17'u8, high(uint8), 16)
    chkInplaceAddition(low(uint8) + 17'u8, 17'u8, low(uint8) + 34'u8, 16)
    chkInplaceAddition(high(uint16) - 17'u16, 17'u16, high(uint16), 16)
    chkInplaceAddition(low(uint16) + 17'u16, 17'u16, low(uint16) + 34'u16, 16)

    chkInplaceAddition(0'u8, 0'u8, 0'u8, 32)
    chkInplaceAddition(high(uint8) - 17'u8, 17'u8, high(uint8), 32)
    chkInplaceAddition(low(uint8) + 17'u8, 17'u8, low(uint8) + 34'u8, 32)
    chkInplaceAddition(high(uint16) - 17'u16, 17'u16, high(uint16), 32)
    chkInplaceAddition(low(uint16) + 17'u16, 17'u16, low(uint16) + 34'u16, 32)
    chkInplaceAddition(high(uint32) - 17'u32, 17'u32, high(uint32), 32)
    chkInplaceAddition(low(uint32) + 17'u32, 17'u32, low(uint32) + 34'u32, 32)

    chkInplaceAddition(0'u8, 0'u8, 0'u8, 64)
    chkInplaceAddition(high(uint8) - 17'u8, 17'u8, high(uint8), 64)
    chkInplaceAddition(low(uint8) + 17'u8, 17'u8, low(uint8) + 34'u8, 64)
    chkInplaceAddition(high(uint16) - 17'u16, 17'u16, high(uint16), 64)
    chkInplaceAddition(low(uint16) + 17'u16, 17'u16, low(uint16) + 34'u16, 64)
    chkInplaceAddition(high(uint32) - 17'u32, 17'u32, high(uint32), 64)
    chkInplaceAddition(low(uint32) + 17'u32, 17'u32, low(uint32) + 34'u32, 64)
    chkInplaceAddition(high(uint64) - 17'u64, 17'u64, high(uint64), 64)
    chkInplaceAddition(low(uint64) + 17'u64, 17'u64, low(uint64) + 34'u64, 64)]#

    chkInplaceAddition(0'u8, 0'u8, 0'u8, 128)
    chkInplaceAddition(high(uint8) - 17'u8, 17'u8, high(uint8), 128)
    chkInplaceAddition(low(uint8) + 17'u8, 17'u8, low(uint8) + 34'u8, 128)
    chkInplaceAddition(high(uint16) - 17'u16, 17'u16, high(uint16), 128)
    chkInplaceAddition(low(uint16) + 17'u16, 17'u16, low(uint16) + 34'u16, 128)
    chkInplaceAddition(high(uint32) - 17'u32, 17'u32, high(uint32), 128)
    chkInplaceAddition(low(uint32) + 17'u32, 17'u32, low(uint32) + 34'u32, 128)
    chkInplaceAddition(high(uint64) - 17'u64, 17'u64, high(uint64), 128)
    chkInplaceAddition(low(uint64) + 17'u64, 17'u64, low(uint64) + 34'u64, 128)

  test "substraction":
    #[chkSubstraction(0'u8, 0'u8, 0'u8, 8)
    chkSubstraction(high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 8)
    chkSubstraction(low(uint8) + 17'u8, 17'u8, low(uint8), 8)

    chkSubstraction(0'u8, 0'u8, 0'u8, 16)
    chkSubstraction(high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 16)
    chkSubstraction(low(uint8) + 17'u8, 17'u8, low(uint8), 16)
    chkSubstraction(high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 16)
    chkSubstraction(low(uint16) + 17'u16, 17'u16, low(uint16), 16)

    chkSubstraction(0'u8, 0'u8, 0'u8, 32)
    chkSubstraction(high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 32)
    chkSubstraction(low(uint8) + 17'u8, 17'u8, low(uint8), 32)
    chkSubstraction(high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 32)
    chkSubstraction(low(uint16) + 17'u16, 17'u16, low(uint16), 32)
    chkSubstraction(high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 32)
    chkSubstraction(low(uint32) + 17'u32, 17'u32, low(uint32), 32)

    chkSubstraction(0'u8, 0'u8, 0'u8, 64)
    chkSubstraction(high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 64)
    chkSubstraction(low(uint8) + 17'u8, 17'u8, low(uint8), 64)
    chkSubstraction(high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 64)
    chkSubstraction(low(uint16) + 17'u16, 17'u16, low(uint16), 64)
    chkSubstraction(high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 64)
    chkSubstraction(low(uint32) + 17'u32, 17'u32, low(uint32), 64)
    chkSubstraction(high(uint64) - 17'u64, 17'u64, high(uint64) - 34'u64, 64)
    chkSubstraction(low(uint64) + 17'u64, 17'u64, low(uint64), 64)]#

    chkSubstraction(0'u8, 0'u8, 0'u8, 128)
    chkSubstraction(high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 128)
    chkSubstraction(high(uint8), high(uint8), 0'u8, 128)
    chkSubstraction(high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 128)
    chkSubstraction(high(uint16), high(uint16), 0'u16, 128)
    chkSubstraction(high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 128)
    chkSubstraction(high(uint32), high(uint32), 0'u32, 128)
    chkSubstraction(high(uint64) - 17'u64, 17'u64, high(uint64) - 34'u64, 128)
    chkSubstraction(high(uint64), high(uint64), 0'u64, 128)

  test "inplace substraction":
    #[chkInplaceSubstraction(0'u8, 0'u8, 0'u8, 8)
    chkInplaceSubstraction(high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 8)
    chkInplaceSubstraction(low(uint8) + 17'u8, 17'u8, low(uint8), 8)

    chkInplaceSubstraction(0'u8, 0'u8, 0'u8, 16)
    chkInplaceSubstraction(high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 16)
    chkInplaceSubstraction(low(uint8) + 17'u8, 17'u8, low(uint8), 16)
    chkInplaceSubstraction(high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 16)
    chkInplaceSubstraction(low(uint16) + 17'u16, 17'u16, low(uint16), 16)

    chkInplaceSubstraction(0'u8, 0'u8, 0'u8, 32)
    chkInplaceSubstraction(high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 32)
    chkInplaceSubstraction(low(uint8) + 17'u8, 17'u8, low(uint8), 32)
    chkInplaceSubstraction(high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 32)
    chkInplaceSubstraction(low(uint16) + 17'u16, 17'u16, low(uint16), 32)
    chkInplaceSubstraction(high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 32)
    chkInplaceSubstraction(low(uint32) + 17'u32, 17'u32, low(uint32), 32)

    chkInplaceSubstraction(0'u8, 0'u8, 0'u8, 64)
    chkInplaceSubstraction(high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 64)
    chkInplaceSubstraction(low(uint8) + 17'u8, 17'u8, low(uint8), 64)
    chkInplaceSubstraction(high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 64)
    chkInplaceSubstraction(low(uint16) + 17'u16, 17'u16, low(uint16), 64)
    chkInplaceSubstraction(high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 64)
    chkInplaceSubstraction(low(uint32) + 17'u32, 17'u32, low(uint32), 64)
    chkInplaceSubstraction(high(uint64) - 17'u64, 17'u64, high(uint64) - 34'u64, 64)
    chkInplaceSubstraction(low(uint64) + 17'u64, 17'u64, low(uint64), 64)]#

    chkInplaceSubstraction(0'u8, 0'u8, 0'u8, 128)
    chkInplaceSubstraction(high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 128)
    chkInplaceSubstraction(high(uint8), high(uint8), 0'u8, 128)
    chkInplaceSubstraction(high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 128)
    chkInplaceSubstraction(high(uint16), high(uint16), 0'u16, 128)
    chkInplaceSubstraction(high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 128)
    chkInplaceSubstraction(high(uint32), high(uint32), 0'u32, 128)
    chkInplaceSubstraction(high(uint64) - 17'u64, 17'u64, high(uint64) - 34'u64, 128)
    chkInplaceSubstraction(high(uint64), high(uint64), 0'u64, 128)

#[
suite "Testing unsigned int addition implementation":
  test "In-place addition gives expected result":

    var a = 20182018.stuint(64)
    let b = 20172017.stuint(64)

    a += b

    check: cast[uint64](a) == 20182018'u64 + 20172017'u64

  test "Addition gives expected result":

    let a = 20182018.stuint(64)
    let b = 20172017.stuint(64)

    check: cast[uint64](a+b) == 20182018'u64 + 20172017'u64

  test "When the low half overflows, it is properly carried":
    # uint8 (low half) overflow at 255
    let a = 100'u16.stuint(16)
    let b = 100'u16.stuint(16)

    check: cast[uint16](a+b) == 200

  test "Full overflow is handled like native unsigned types":
    # uint16 overflows after 65535
    let a = 100'u16.stuint(16)
    var z = 0'u16.stuint(16)
    let o = 36'u16.stuint(16)

    for _ in 0 ..< 655:
      z += a

    check: cast[uint16](z) == 65500
    check: cast[uint16](z + o) == 0

    z += a
    check: cast[uint16](z) == 64

    z += a
    check: cast[uint16](z) == 164

suite "Testing unsigned int substraction implementation":
  test "In-place substraction gives expected result":

    var a = 20182018.stuint(64)
    let b = 20172017.stuint(64)

    a -= b

    check: cast[uint64](a) == 20182018'u64 - 20172017'u64

  test "Substraction gives expected result":

    let a = 20182018.stuint(64)
    let b = 20172017.stuint(64)

    check: cast[uint64](a-b) == 20182018'u64 - 20172017'u64

  test "Full overflow is handled like native unsigned types":
    # uint16 overflows after 65535
    let a = 100'u16.stuint(16)
    let b = 101'u16.stuint(16)

    check: cast[uint16](a-b) == high(uint16)
]#

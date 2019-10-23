# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, test_helpers

template chkAddition(chk, a, b, c, bits: untyped) =
  block:
    let x = stuint(a, bits)
    let y = stuint(b, bits)
    chk x + y == stuint(c, bits)

template chkInplaceAddition(chk, a, b, c, bits: untyped) =
  block:
    var x = stuint(a, bits)
    x += stuint(b, bits)
    chk x == stuint(c, bits)

template chkSubstraction(chk, a, b, c, bits: untyped) =
  block:
    let x = stuint(a, bits)
    let y = stuint(b, bits)
    chk x - y == stuint(c, bits)

template chkInplaceSubstraction(chk, a, b, c, bits: untyped) =
  block:
    var x = stuint(a, bits)
    x -= stuint(b, bits)
    chk x == stuint(c, bits)

template testAddSub(chk, tst: untyped) =
  tst "addition":
    chkAddition(chk, 0'u8, 0'u8, 0'u8, 8)
    chkAddition(chk, high(uint8) - 17'u8, 17'u8, high(uint8), 8)
    chkAddition(chk, low(uint8), 17'u8, low(uint8) + 17'u8, 8)

    chkAddition(chk, 0'u8, 0'u8, 0'u8, 16)
    chkAddition(chk, high(uint8) - 17'u8, 17'u8, high(uint8), 16)
    chkAddition(chk, low(uint8), 17'u8, low(uint8) + 17'u8, 16)
    chkAddition(chk, high(uint16) - 17'u16, 17'u16, high(uint16), 16)
    chkAddition(chk, low(uint16), 17'u16, low(uint16) + 17'u16, 16)

    chkAddition(chk, 0'u8, 0'u8, 0'u8, 32)
    chkAddition(chk, high(uint8) - 17'u8, 17'u8, high(uint8), 32)
    chkAddition(chk, low(uint8), 17'u8, low(uint8) + 17'u8, 32)
    chkAddition(chk, high(uint16) - 17'u16, 17'u16, high(uint16), 32)
    chkAddition(chk, low(uint16), 17'u16, low(uint16) + 17'u16, 32)
    chkAddition(chk, high(uint32) - 17'u32, 17'u32, high(uint32), 32)
    chkAddition(chk, low(uint32), 17'u32, low(uint32) + 17'u32, 32)

    chkAddition(chk, 0'u8, 0'u8, 0'u8, 64)
    chkAddition(chk, high(uint8) - 17'u8, 17'u8, high(uint8), 64)
    chkAddition(chk, low(uint8), 17'u8, low(uint8) + 17'u8, 64)
    chkAddition(chk, high(uint16) - 17'u16, 17'u16, high(uint16), 64)
    chkAddition(chk, low(uint16), 17'u16, low(uint16) + 17'u16, 64)
    chkAddition(chk, high(uint32) - 17'u32, 17'u32, high(uint32), 64)
    chkAddition(chk, low(uint32), 17'u32, low(uint32) + 17'u32, 64)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkAddition(chk, high(uint64) - 17'u64, 17'u64, high(uint64), 64)
      chkAddition(chk, low(uint64), 17'u64, low(uint64) + 17'u64, 64)

    chkAddition(chk, 0'u8, 0'u8, 0'u8, 128)
    chkAddition(chk, high(uint8) - 17'u8, 17'u8, high(uint8), 128)
    chkAddition(chk, low(uint8), 17'u8, low(uint8) + 17'u8, 128)
    chkAddition(chk, high(uint16) - 17'u16, 17'u16, high(uint16), 128)
    chkAddition(chk, low(uint16), 17'u16, low(uint16) + 17'u16, 128)
    chkAddition(chk, high(uint32) - 17'u32, 17'u32, high(uint32), 128)
    chkAddition(chk, low(uint32), 17'u32, low(uint32) + 17'u32, 128)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkAddition(chk, high(uint64) - 17'u64, 17'u64, high(uint64), 128)
      chkAddition(chk, low(uint64), 17'u64, low(uint64) + 17'u64, 128)

  tst "inplace addition":
    chkInplaceAddition(chk, 0'u8, 0'u8, 0'u8, 8)
    chkInplaceAddition(chk, high(uint8) - 17'u8, 17'u8, high(uint8), 8)
    chkInplaceAddition(chk, low(uint8) + 17'u8, 17'u8, low(uint8) + 34'u8, 8)

    chkInplaceAddition(chk, 0'u8, 0'u8, 0'u8, 16)
    chkInplaceAddition(chk, high(uint8) - 17'u8, 17'u8, high(uint8), 16)
    chkInplaceAddition(chk, low(uint8) + 17'u8, 17'u8, low(uint8) + 34'u8, 16)
    chkInplaceAddition(chk, high(uint16) - 17'u16, 17'u16, high(uint16), 16)
    chkInplaceAddition(chk, low(uint16) + 17'u16, 17'u16, low(uint16) + 34'u16, 16)

    chkInplaceAddition(chk, 0'u8, 0'u8, 0'u8, 32)
    chkInplaceAddition(chk, high(uint8) - 17'u8, 17'u8, high(uint8), 32)
    chkInplaceAddition(chk, low(uint8) + 17'u8, 17'u8, low(uint8) + 34'u8, 32)
    chkInplaceAddition(chk, high(uint16) - 17'u16, 17'u16, high(uint16), 32)
    chkInplaceAddition(chk, low(uint16) + 17'u16, 17'u16, low(uint16) + 34'u16, 32)
    chkInplaceAddition(chk, high(uint32) - 17'u32, 17'u32, high(uint32), 32)
    chkInplaceAddition(chk, low(uint32) + 17'u32, 17'u32, low(uint32) + 34'u32, 32)

    chkInplaceAddition(chk, 0'u8, 0'u8, 0'u8, 64)
    chkInplaceAddition(chk, high(uint8) - 17'u8, 17'u8, high(uint8), 64)
    chkInplaceAddition(chk, low(uint8) + 17'u8, 17'u8, low(uint8) + 34'u8, 64)
    chkInplaceAddition(chk, high(uint16) - 17'u16, 17'u16, high(uint16), 64)
    chkInplaceAddition(chk, low(uint16) + 17'u16, 17'u16, low(uint16) + 34'u16, 64)
    chkInplaceAddition(chk, high(uint32) - 17'u32, 17'u32, high(uint32), 64)
    chkInplaceAddition(chk, low(uint32) + 17'u32, 17'u32, low(uint32) + 34'u32, 64)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkInplaceAddition(chk, high(uint64) - 17'u64, 17'u64, high(uint64), 64)
      chkInplaceAddition(chk, low(uint64) + 17'u64, 17'u64, low(uint64) + 34'u64, 64)

    chkInplaceAddition(chk, 0'u8, 0'u8, 0'u8, 128)
    chkInplaceAddition(chk, high(uint8) - 17'u8, 17'u8, high(uint8), 128)
    chkInplaceAddition(chk, low(uint8) + 17'u8, 17'u8, low(uint8) + 34'u8, 128)
    chkInplaceAddition(chk, high(uint16) - 17'u16, 17'u16, high(uint16), 128)
    chkInplaceAddition(chk, low(uint16) + 17'u16, 17'u16, low(uint16) + 34'u16, 128)
    chkInplaceAddition(chk, high(uint32) - 17'u32, 17'u32, high(uint32), 128)
    chkInplaceAddition(chk, low(uint32) + 17'u32, 17'u32, low(uint32) + 34'u32, 128)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkInplaceAddition(chk, high(uint64) - 17'u64, 17'u64, high(uint64), 128)
      chkInplaceAddition(chk, low(uint64) + 17'u64, 17'u64, low(uint64) + 34'u64, 128)

  tst "substraction":
    chkSubstraction(chk, 0'u8, 0'u8, 0'u8, 8)
    chkSubstraction(chk, high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 8)
    chkSubstraction(chk, low(uint8) + 17'u8, 17'u8, low(uint8), 8)

    chkSubstraction(chk, 0'u8, 0'u8, 0'u8, 16)
    chkSubstraction(chk, high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 16)
    chkSubstraction(chk, low(uint8) + 17'u8, 17'u8, low(uint8), 16)
    chkSubstraction(chk, high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 16)
    chkSubstraction(chk, low(uint16) + 17'u16, 17'u16, low(uint16), 16)

    chkSubstraction(chk, 0'u8, 0'u8, 0'u8, 32)
    chkSubstraction(chk, high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 32)
    chkSubstraction(chk, low(uint8) + 17'u8, 17'u8, low(uint8), 32)
    chkSubstraction(chk, high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 32)
    chkSubstraction(chk, low(uint16) + 17'u16, 17'u16, low(uint16), 32)
    chkSubstraction(chk, high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 32)
    chkSubstraction(chk, low(uint32) + 17'u32, 17'u32, low(uint32), 32)

    chkSubstraction(chk, 0'u8, 0'u8, 0'u8, 64)
    chkSubstraction(chk, high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 64)
    chkSubstraction(chk, low(uint8) + 17'u8, 17'u8, low(uint8), 64)
    chkSubstraction(chk, high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 64)
    chkSubstraction(chk, low(uint16) + 17'u16, 17'u16, low(uint16), 64)
    chkSubstraction(chk, high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 64)
    chkSubstraction(chk, low(uint32) + 17'u32, 17'u32, low(uint32), 64)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkSubstraction(chk, high(uint64) - 17'u64, 17'u64, high(uint64) - 34'u64, 64)
      chkSubstraction(chk, low(uint64) + 17'u64, 17'u64, low(uint64), 64)

    chkSubstraction(chk, 0'u8, 0'u8, 0'u8, 128)
    chkSubstraction(chk, high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 128)
    chkSubstraction(chk, high(uint8), high(uint8), 0'u8, 128)
    chkSubstraction(chk, high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 128)
    chkSubstraction(chk, high(uint16), high(uint16), 0'u16, 128)
    chkSubstraction(chk, high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 128)
    chkSubstraction(chk, high(uint32), high(uint32), 0'u32, 128)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkSubstraction(chk, high(uint64) - 17'u64, 17'u64, high(uint64) - 34'u64, 128)
      chkSubstraction(chk, high(uint64), high(uint64), 0'u64, 128)

  tst "inplace substraction":
    chkInplaceSubstraction(chk, 0'u8, 0'u8, 0'u8, 8)
    chkInplaceSubstraction(chk, high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 8)
    chkInplaceSubstraction(chk, low(uint8) + 17'u8, 17'u8, low(uint8), 8)

    chkInplaceSubstraction(chk, 0'u8, 0'u8, 0'u8, 16)
    chkInplaceSubstraction(chk, high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 16)
    chkInplaceSubstraction(chk, low(uint8) + 17'u8, 17'u8, low(uint8), 16)
    chkInplaceSubstraction(chk, high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 16)
    chkInplaceSubstraction(chk, low(uint16) + 17'u16, 17'u16, low(uint16), 16)

    chkInplaceSubstraction(chk, 0'u8, 0'u8, 0'u8, 32)
    chkInplaceSubstraction(chk, high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 32)
    chkInplaceSubstraction(chk, low(uint8) + 17'u8, 17'u8, low(uint8), 32)
    chkInplaceSubstraction(chk, high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 32)
    chkInplaceSubstraction(chk, low(uint16) + 17'u16, 17'u16, low(uint16), 32)
    chkInplaceSubstraction(chk, high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 32)
    chkInplaceSubstraction(chk, low(uint32) + 17'u32, 17'u32, low(uint32), 32)

    chkInplaceSubstraction(chk, 0'u8, 0'u8, 0'u8, 64)
    chkInplaceSubstraction(chk, high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 64)
    chkInplaceSubstraction(chk, low(uint8) + 17'u8, 17'u8, low(uint8), 64)
    chkInplaceSubstraction(chk, high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 64)
    chkInplaceSubstraction(chk, low(uint16) + 17'u16, 17'u16, low(uint16), 64)
    chkInplaceSubstraction(chk, high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 64)
    chkInplaceSubstraction(chk, low(uint32) + 17'u32, 17'u32, low(uint32), 64)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkInplaceSubstraction(chk, high(uint64) - 17'u64, 17'u64, high(uint64) - 34'u64, 64)
      chkInplaceSubstraction(chk, low(uint64) + 17'u64, 17'u64, low(uint64), 64)

    chkInplaceSubstraction(chk, 0'u8, 0'u8, 0'u8, 128)
    chkInplaceSubstraction(chk, high(uint8) - 17'u8, 17'u8, high(uint8) - 34'u8, 128)
    chkInplaceSubstraction(chk, high(uint8), high(uint8), 0'u8, 128)
    chkInplaceSubstraction(chk, high(uint16) - 17'u16, 17'u16, high(uint16) - 34'u16, 128)
    chkInplaceSubstraction(chk, high(uint16), high(uint16), 0'u16, 128)
    chkInplaceSubstraction(chk, high(uint32) - 17'u32, 17'u32, high(uint32) - 34'u32, 128)
    chkInplaceSubstraction(chk, high(uint32), high(uint32), 0'u32, 128)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkInplaceSubstraction(chk, high(uint64) - 17'u64, 17'u64, high(uint64) - 34'u64, 128)
      chkInplaceSubstraction(chk, high(uint64), high(uint64), 0'u64, 128)

static:
  testAddSub(ctCheck, ctTest)

suite "Wider unsigned int addsub coverage":
  testAddSub(check, test)

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

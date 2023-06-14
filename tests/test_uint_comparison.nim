# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, test_helpers

template chkLT(chk: untyped, a, b: string, bits: int) =
  chk fromHex(StUint[bits], a) < fromHex(StUint[bits], b)

template chkNotLT(chk: untyped, a, b: string, bits: int) =
  chk (not(fromHex(StUint[bits], b) < fromHex(StUint[bits], a)))

template chkLTE(chk: untyped, a, b: string, bits: int) =
  chk fromHex(StUint[bits], a) <= fromHex(StUint[bits], b)

template chkNotLTE(chk: untyped, a, b: string, bits: int) =
  chk (not(fromHex(StUint[bits], b) <= fromHex(StUint[bits], a)))

template chkEQ(chk: untyped, a, b: string, bits: int) =
  chk fromHex(StUint[bits], a) == fromHex(StUint[bits], b)

template chkNotEQ(chk: untyped, a, b: string, bits: int) =
  chk (not(fromHex(StUint[bits], a) == fromHex(StUint[bits], b)))

template chkIsZero(chk: untyped, a: string, bits: int) =
  chk fromHex(StUint[bits], a).isZero()

template chkNotIsZero(chk: untyped, a: string, bits: int) =
  chk (not fromHex(StUint[bits], a).isZero())

template chkIsOdd(chk: untyped, a: string, bits: int) =
  chk fromHex(StUint[bits], a).isOdd()

template chkNotIsOdd(chk: untyped, a: string, bits: int) =
  chk (not fromHex(StUint[bits], a).isOdd())

template testComparison(chk, tst: untyped) =
  tst "operator `LT`":
    chkLT(chk, "0", "F", 64)
    chkLT(chk, "F", "FF", 64)
    chkLT(chk, "FF", "FFF", 64)
    chkLT(chk, "FFFF", "FFFFF", 64)
    chkLT(chk, "FFFFF", "FFFFFFFF", 64)

    chkLT(chk, "0", "F", 128)
    chkLT(chk, "F", "FF", 128)
    chkLT(chk, "FF", "FFF", 128)
    chkLT(chk, "FFFF", "FFFFF", 128)
    chkLT(chk, "FFFFF", "FFFFFFFF", 128)
    chkLT(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator not `LT`":
    chkNotLT(chk, "0", "F", 64)
    chkNotLT(chk, "F", "FF", 64)
    chkNotLT(chk, "FF", "FFF", 64)
    chkNotLT(chk, "FFFF", "FFFFF", 64)
    chkNotLT(chk, "FFFFF", "FFFFFFFF", 64)

    chkNotLT(chk, "0", "F", 128)
    chkNotLT(chk, "F", "FF", 128)
    chkNotLT(chk, "FF", "FFF", 128)
    chkNotLT(chk, "FFFF", "FFFFF", 128)
    chkNotLT(chk, "FFFFF", "FFFFFFFF", 128)
    chkNotLT(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `LTE`":
    chkLTE(chk, "0", "F", 64)
    chkLTE(chk, "F", "FF", 64)
    chkLTE(chk, "FF", "FFF", 64)
    chkLTE(chk, "FFFF", "FFFFF", 64)
    chkLTE(chk, "FFFFF", "FFFFFFFF", 64)
    chkLTE(chk, "FFFFFFFF", "FFFFFFFF", 64)

    chkLTE(chk, "0", "F", 128)
    chkLTE(chk, "F", "FF", 128)
    chkLTE(chk, "FF", "FFF", 128)
    chkLTE(chk, "FFFF", "FFFFF", 128)
    chkLTE(chk, "FFFFF", "FFFFFFFF", 128)
    chkLTE(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLTE(chk, "FFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator not `LTE`":
    chkNotLTE(chk, "0", "F", 64)
    chkNotLTE(chk, "F", "FF", 64)
    chkNotLTE(chk, "FF", "FFF", 64)
    chkNotLTE(chk, "FFFF", "FFFFF", 64)
    chkNotLTE(chk, "FFFFF", "FFFFFFFF", 64)

    chkNotLTE(chk, "0", "F", 128)
    chkNotLTE(chk, "F", "FF", 128)
    chkNotLTE(chk, "FF", "FFF", 128)
    chkNotLTE(chk, "FFFF", "FFFFF", 128)
    chkNotLTE(chk, "FFFFF", "FFFFFFFF", 128)
    chkNotLTE(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `EQ`":
    chkEQ(chk, "0", "0", 64)
    chkEQ(chk, "F", "F", 64)
    chkEQ(chk, "FF", "FF", 64)
    chkEQ(chk, "FFFF", "FFFF", 64)
    chkEQ(chk, "FFFFF", "FFFFF", 64)
    chkEQ(chk, "FFFFFFFF", "FFFFFFFF", 64)

    chkEQ(chk, "0", "0", 128)
    chkEQ(chk, "F", "F", 128)
    chkEQ(chk, "FF", "FF", 128)
    chkEQ(chk, "FFFF", "FFFF", 128)
    chkEQ(chk, "FFFFF", "FFFFF", 128)
    chkEQ(chk, "FFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator not `EQ`":
    chkNotEQ(chk, "0", "F", 64)
    chkNotEQ(chk, "F", "FF", 64)
    chkNotEQ(chk, "FF", "FFF", 64)
    chkNotEQ(chk, "FFFF", "FFFFF", 64)
    chkNotEQ(chk, "FFFFF", "FFFFFFFF", 64)

    chkNotEQ(chk, "0", "F", 128)
    chkNotEQ(chk, "F", "FF", 128)
    chkNotEQ(chk, "FF", "FFF", 128)
    chkNotEQ(chk, "FFFF", "FFFFF", 128)
    chkNotEQ(chk, "FFFFF", "FFFFFFFF", 128)
    chkNotEQ(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `isZero`":
    chkIsZero(chk, "0", 64)
    chkIsZero(chk, "0", 128)
    chkIsZero(chk, "0", 256)

  tst "operator not `isZero`":
    chkNotIsZero(chk, "4", 64)
    chkNotIsZero(chk, "5", 128)
    chkNotIsZero(chk, "6", 256)

  tst "operator `isOdd`":
    chkIsOdd(chk, "1", 64)
    chkIsOdd(chk, "1", 128)
    chkIsOdd(chk, "1", 256)

    chkIsOdd(chk, "FFFFFF", 64)
    chkIsOdd(chk, "FFFFFFFFFFFFFFF", 128)
    chkIsOdd(chk, "FFFFFFFFFFFFFFFFFF", 256)

  tst "operator not `isOdd`":
    chkNotIsOdd(chk, "0", 64)
    chkNotIsOdd(chk, "0", 128)
    chkNotIsOdd(chk, "0", 256)

    chkNotIsOdd(chk, "4", 64)
    chkNotIsOdd(chk, "4", 128)
    chkNotIsOdd(chk, "4", 256)

    chkNotIsOdd(chk, "FFFFFA", 64)
    chkNotIsOdd(chk, "FFFFFFFFFFFFFFA", 128)
    chkNotIsOdd(chk, "FFFFFFFFFFFFFFFFFA", 256)

  tst "operator `isEven`":
    chkNotIsOdd(chk, "0", 64)
    chkNotIsOdd(chk, "0", 128)
    chkNotIsOdd(chk, "0", 256)

    chkNotIsOdd(chk, "4", 64)
    chkNotIsOdd(chk, "4", 128)
    chkNotIsOdd(chk, "4", 256)

    chkNotIsOdd(chk, "FFFFFA", 64)
    chkNotIsOdd(chk, "FFFFFFFFFFFFFFA", 128)
    chkNotIsOdd(chk, "FFFFFFFFFFFFFFFFFA", 256)

  tst "operator not `isEven`":
    chkIsOdd(chk, "1", 64)
    chkIsOdd(chk, "1", 128)
    chkIsOdd(chk, "1", 256)

    chkIsOdd(chk, "FFFFFF", 64)
    chkIsOdd(chk, "FFFFFFFFFFFFFFF", 128)
    chkIsOdd(chk, "FFFFFFFFFFFFFFFFFF", 256)

static:
  testComparison(ctCheck, ctTest)

suite "Wider unsigned int comparison coverage":
  testComparison(check, test)

suite "Testing unsigned int comparison operators":
  let
    a = 10.stuint(64)
    b = 15.stuint(64)
    c = 150'u16
    d = 4.stuint(128) shl 64
    e = 4.stuint(128)
    f = 4.stuint(128) shl 65

  test "< operator":
    check:
      a < b
      not (a + b < b)
      not (a + a + a < b + b)
      not (a * b < cast[StUint[64]](c))
      e < d
      d < f

  test "<= operator":
    check:
      a <= b
      not (a + b <= b)
      a + a + a <= b + b
      a * b <= cast[StUint[64]](c)
      e <= d
      d <= f

  test "> operator":
    check:
      b > a
      not (b > a + b)
      not (b + b > a + a + a)
      not (cast[StUint[64]](c) > a * b)
      d > e
      f > d

  test ">= operator":
    check:
      b >= a
      not (b >= a + b)
      b + b >= a + a + a
      cast[StUint[64]](c) >= a * b
      d >= e
      f >= d

  test "isOdd/isEven":
    check:
      a.isEven
      not a.isOdd
      b.isOdd
      not b.isEven
      # c.isEven
      # not c.isOdd

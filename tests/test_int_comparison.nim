# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, test_helpers

template chkLT(chk: untyped, a, b: string, bits: int) =
  chk fromHex(StInt[bits], a) < fromHex(StInt[bits], b)

template chkNotLT(chk: untyped, a, b: string, bits: int) =
  chk (not(fromHex(StInt[bits], b) < fromHex(StInt[bits], a)))

template chkLTE(chk: untyped, a, b: string, bits: int) =
  chk fromHex(StInt[bits], a) <= fromHex(StInt[bits], b)

template chkNotLTE(chk: untyped, a, b: string, bits: int) =
  chk (not(fromHex(StInt[bits], b) <= fromHex(StInt[bits], a)))

template chkEQ(chk: untyped, a, b: string, bits: int) =
  chk fromHex(StInt[bits], a) == fromHex(StInt[bits], b)

template chkNotEQ(chk: untyped, a, b: string, bits: int) =
  chk (not(fromHex(StInt[bits], a) == fromHex(StInt[bits], b)))

template chkIsZero(chk: untyped, a: string, bits: int) =
  chk fromHex(StInt[bits], a).isZero()

template chkNotIsZero(chk: untyped, a: string, bits: int) =
  chk (not fromHex(StInt[bits], a).isZero())

template chkIsNegative(chk: untyped, a: string, bits: int) =
  chk fromHex(StInt[bits], a).isNegative()

template chkNotIsNegative(chk: untyped, a: string, bits: int) =
  chk (not fromHex(StInt[bits], a).isNegative())

template chkIsOdd(chk: untyped, a: string, bits: int) =
  chk fromHex(StInt[bits], a).isOdd()

template chkNotIsOdd(chk: untyped, a: string, bits: int) =
  chk (not fromHex(StInt[bits], a).isOdd())

template chkIsEven(chk: untyped, a: string, bits: int) =
  chk fromHex(StInt[bits], a).isEven()

template chkNotIsEven(chk: untyped, a: string, bits: int) =
  chk (not fromHex(StInt[bits], a).isEven())

template testComparison(chk, tst: untyped) =
  tst "operator `LT`":
    chk 0.i128 < 1.i128
    chk -1.i128 < 1.i128
    chk -1.i128 < 0.i128
    chk Int128.low < Int128.high
    chk -2.i128 < -1.i128
    chk 1.i128 < 2.i128
    chk 10000.i128 < Int128.high
    chk Int128.low < 10000.i128

    chk 0.i256 < 1.i256
    chk -1.i256 < 1.i256
    chk -1.i256 < 0.i256
    chk Int256.low < Int256.high
    chk -2.i256 < -1.i256
    chk 1.i256 < 2.i256

    chkLT(chk, "0", "F", 128)
    chkLT(chk, "F", "FF", 128)
    chkLT(chk, "FF", "FFF", 128)
    chkLT(chk, "FFFF", "FFFFF", 128)
    chkLT(chk, "FFFFF", "FFFFFFFF", 128)
    chkLT(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLT(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `GT`":
    chk 1.i128 > 0.i128
    chk 1.i128 > -1.i128
    chk 0.i128 > -1.i128
    chk Int128.high > Int128.low
    chk -1.i128 > -2.i128
    chk 2.i128 > 1.i128

    chk 1.i256 > 0.i256
    chk 1.i256 > -1.i256
    chk 0.i256 > -1.i256
    chk Int256.high > Int256.low
    chk -1.i256 > -2.i256
    chk 2.i256 > 1.i256

    chkNotLT(chk, "0", "F", 128)
    chkNotLT(chk, "F", "FF", 128)
    chkNotLT(chk, "FF", "FFF", 128)
    chkNotLT(chk, "FFFF", "FFFFF", 128)
    chkNotLT(chk, "FFFFF", "FFFFFFFF", 128)
    chkNotLT(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNotLT(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `LTE`":
    chk 0.i128 <= 1.i128
    chk -1.i128 <= 1.i128
    chk -1.i128 <= 0.i128
    chk Int128.low <= Int128.high
    chk -2.i128 <= -1.i128
    chk 1.i128 <= 2.i128
    chk 10000.i128 <= Int128.high
    chk Int128.low <= 10000.i128
    chk Int128.low <= Int128.low
    chk Int128.high <= Int128.high
    chk 10000.i128 <= 10000.i128

    chk 0.i256 <= 1.i256
    chk -1.i256 <= 1.i256
    chk -1.i256 <= 0.i256
    chk Int256.low <= Int256.high
    chk -2.i256 <= -1.i256
    chk 1.i256 <= 2.i256
    chk 10000.i256 <= Int256.high
    chk Int256.low <= 10000.i256
    chk Int256.low <= Int256.low
    chk Int256.high <= Int256.high
    chk 10000.i256 <= 10000.i256

    chkLTE(chk, "0", "F", 128)
    chkLTE(chk, "F", "FF", 128)
    chkLTE(chk, "FF", "FFF", 128)
    chkLTE(chk, "FFFF", "FFFFF", 128)
    chkLTE(chk, "FFFFF", "FFFFFFFF", 128)
    chkLTE(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLTE(chk, "FFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLTE(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `GTE`":
    chk 1.i128       >= 0.i128
    chk 1.i128       >= -1.i128
    chk 0.i128       >= -1.i128
    chk Int128.high  >= Int128.low
    chk -1.i128      >= -2.i128
    chk 2.i128       >= 1.i128
    chk Int128.high  >= 10000.i128
    chk 10000.i128   >= Int128.low
    chk Int128.low   >= Int128.low
    chk Int128.high  >= Int128.high
    chk 10000.i128   >= 10000.i128

    chk 1.i256       >= 0.i256
    chk 1.i256       >= -1.i256
    chk 0.i256       >= -1.i256
    chk Int256.high  >= Int256.low
    chk -1.i256      >= -2.i256
    chk 2.i256       >= 1.i256
    chk Int256.high  >= 10000.i256
    chk 10000.i256   >= Int256.low
    chk Int256.low   >= Int256.low
    chk Int256.high  >= Int256.high
    chk 10000.i256   >= 10000.i256

    chkNotLTE(chk, "0", "F", 128)
    chkNotLTE(chk, "F", "FF", 128)
    chkNotLTE(chk, "FF", "FFF", 128)
    chkNotLTE(chk, "FFFF", "FFFFF", 128)
    chkNotLTE(chk, "FFFFF", "FFFFFFFF", 128)
    chkNotLTE(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNotLTE(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `EQ`":
    chk 0.i128 == 0.i128
    chk 1.i128 == 1.i128
    chk -1.i128 == -1.i128
    chk Int128.high == Int128.high
    chk Int128.low == Int128.low

    chk 0.i256 == 0.i256
    chk 1.i256 == 1.i256
    chk -1.i256 == -1.i256
    chk Int256.high == Int256.high
    chk Int256.low == Int256.low

    chkEQ(chk, "0", "0", 128)
    chkEQ(chk, "F", "F", 128)
    chkEQ(chk, "FF", "FF", 128)
    chkEQ(chk, "FFFF", "FFFF", 128)
    chkEQ(chk, "FFFFF", "FFFFF", 128)
    chkEQ(chk, "FFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator not `EQ`":
    chk Int128.low != Int128.high
    chk Int128.high != Int128.low
    chk 0.i256 != 1.i256
    chk 1.i256 != 0.i256
    chk 1.i256 != -1.i256
    chk -1.i256 != 1.i256

    chkNotEQ(chk, "0", "F", 128)
    chkNotEQ(chk, "F", "FF", 128)
    chkNotEQ(chk, "FF", "FFF", 128)
    chkNotEQ(chk, "FFFF", "FFFFF", 128)
    chkNotEQ(chk, "FFFFF", "FFAFFFFF", 128)
    chkNotEQ(chk, "FFFFFFFFFFF", "AFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `isZero`":
    chkIsZero(chk, "0", 128)
    chkIsZero(chk, "0", 256)

  tst "operator not `isZero`":
    chkNotIsZero(chk, "5", 128)
    chkNotIsZero(chk, "6", 256)

    chkNotIsZero(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNotIsZero(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 256)

  tst "operator `isNegative`":
    chkIsNegative(chk, "F0000000000000000000000000000000", 128)
    chkIsNegative(chk, "F000000000000000000000000000000000000000000000000000000000000000", 256)

    chkIsNegative(chk, "A5000000000000000000000000000000", 128)
    chkIsNegative(chk, "A600000000000000000000000000000000000000000000000000000000000000", 256)

  tst "operator not `isNegative`":
    chkNotIsNegative(chk, "0", 128)
    chkNotIsNegative(chk, "0", 256)

    chkNotIsNegative(chk, "5", 128)
    chkNotIsNegative(chk, "6", 256)

    chkNotIsNegative(chk, "75000000000000000000000000000000", 128)
    chkNotIsNegative(chk, "7600000000000000000000000000000000000000000000000000000000000000", 256)

  tst "operator `isOdd`":
    chkIsOdd(chk, "1", 128)
    chkIsOdd(chk, "1", 256)

    chkIsOdd(chk, "FFFFFFFFFFFFFFF", 128)
    chkIsOdd(chk, "FFFFFFFFFFFFFFFFFF", 256)

  tst "operator not `isOdd`":
    chkNotIsOdd(chk, "0", 128)
    chkNotIsOdd(chk, "0", 256)

    chkNotIsOdd(chk, "4", 128)
    chkNotIsOdd(chk, "4", 256)

    chkNotIsOdd(chk, "FFFFFFFFFFFFFFA", 128)
    chkNotIsOdd(chk, "FFFFFFFFFFFFFFFFFA", 256)

  tst "operator `isEven`":
    chkIsEven(chk, "0", 128)
    chkIsEven(chk, "0", 256)

    chkIsEven(chk, "4", 128)
    chkIsEven(chk, "4", 256)

    chkIsEven(chk, "FFFFFFFFFFFFFFA", 128)
    chkIsEven(chk, "FFFFFFFFFFFFFFFFFA", 256)

  tst "operator not `isEven`":
    chkNotIsEven(chk, "1", 128)
    chkNotIsEven(chk, "1", 256)

    chkNotIsEven(chk, "FFFFFFFFFFFFFFF", 128)
    chkNotIsEven(chk, "FFFFFFFFFFFFFFFFFF", 256)

  tst "isOne":
    let x = 1.i128
    chk x.isOne

    let y = 1.i256
    chk y.isOne

static:
  testComparison(ctCheck, ctTest)

proc main() =
  # Nim GC protests we are using too much global variables
  # so put it in a proc

  suite "Wider signed int comparison coverage":
    testComparison(check, test)

  suite "Signed int - Testing comparison operators":
    let
      a = 10.i256
      b = 15.i256
      c = 150.i256

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

main()

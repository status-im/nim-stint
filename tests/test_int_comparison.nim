# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template chkLT(a, b: string, bits: int) =
  check fromHex(StInt[bits], a) < fromHex(StInt[bits], b)

template chkNotLT(a, b: string, bits: int) =
  check (not(fromHex(StInt[bits], b) < fromHex(StInt[bits], a)))

template chkLTE(a, b: string, bits: int) =
  check fromHex(StInt[bits], a) <= fromHex(StInt[bits], b)

template chkNotLTE(a, b: string, bits: int) =
  check (not(fromHex(StInt[bits], b) <= fromHex(StInt[bits], a)))

template chkEQ(a, b: string, bits: int) =
  check fromHex(StInt[bits], a) == fromHex(StInt[bits], b)

template chkNotEQ(a, b: string, bits: int) =
  check (not(fromHex(StInt[bits], a) == fromHex(StInt[bits], b)))

template chkIsZero(a: string, bits: int) =
  check fromHex(StInt[bits], a).isZero()

template chkNotIsZero(a: string, bits: int) =
  check (not fromHex(StInt[bits], a).isZero())

template chkIsNegative(a: string, bits: int) =
  check fromHex(StInt[bits], a).isNegative()

template chkNotIsNegative(a: string, bits: int) =
  check (not fromHex(StInt[bits], a).isNegative())

template chkIsOdd(a: string, bits: int) =
  check fromHex(StInt[bits], a).isOdd()

template chkNotIsOdd(a: string, bits: int) =
  check (not fromHex(StInt[bits], a).isOdd())

template chkIsEven(a: string, bits: int) =
  check fromHex(StInt[bits], a).isEven()

template chkNotIsEven(a: string, bits: int) =
  check (not fromHex(StInt[bits], a).isEven())

suite "Wider signed int comparison coverage":
  test "operator `LT`":
    check 0.i128 < 1.i128
    check -1.i128 < 1.i128
    check -1.i128 < 0.i128
    check Int128.low < Int128.high
    check -2.i128 < -1.i128
    check 1.i128 < 2.i128
    check 10000.i128 < Int128.high
    check Int128.low < 10000.i128

    check 0.i256 < 1.i256
    check -1.i256 < 1.i256
    check -1.i256 < 0.i256
    check Int256.low < Int256.high
    check -2.i256 < -1.i256
    check 1.i256 < 2.i256

    chkLT("0", "F", 128)
    chkLT("F", "FF", 128)
    chkLT("FF", "FFF", 128)
    chkLT("FFFF", "FFFFF", 128)
    chkLT("FFFFF", "FFFFFFFF", 128)
    chkLT("FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLT("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator `GT`":
    check 1.i128 > 0.i128
    check 1.i128 > -1.i128
    check 0.i128 > -1.i128
    check Int128.high > Int128.low
    check -1.i128 > -2.i128
    check 2.i128 > 1.i128

    check 1.i256 > 0.i256
    check 1.i256 > -1.i256
    check 0.i256 > -1.i256
    check Int256.high > Int256.low
    check -1.i256 > -2.i256
    check 2.i256 > 1.i256

    chkNotLT("0", "F", 128)
    chkNotLT("F", "FF", 128)
    chkNotLT("FF", "FFF", 128)
    chkNotLT("FFFF", "FFFFF", 128)
    chkNotLT("FFFFF", "FFFFFFFF", 128)
    chkNotLT("FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNotLT("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator `LTE`":
    check 0.i128 <= 1.i128
    check -1.i128 <= 1.i128
    check -1.i128 <= 0.i128
    check Int128.low <= Int128.high
    check -2.i128 <= -1.i128
    check 1.i128 <= 2.i128
    check 10000.i128 <= Int128.high
    check Int128.low <= 10000.i128
    check Int128.low <= Int128.low
    check Int128.high <= Int128.high
    check 10000.i128 <= 10000.i128

    check 0.i256 <= 1.i256
    check -1.i256 <= 1.i256
    check -1.i256 <= 0.i256
    check Int256.low <= Int256.high
    check -2.i256 <= -1.i256
    check 1.i256 <= 2.i256
    check 10000.i256 <= Int256.high
    check Int256.low <= 10000.i256
    check Int256.low <= Int256.low
    check Int256.high <= Int256.high
    check 10000.i256 <= 10000.i256

    chkLTE("0", "F", 128)
    chkLTE("F", "FF", 128)
    chkLTE("FF", "FFF", 128)
    chkLTE("FFFF", "FFFFF", 128)
    chkLTE("FFFFF", "FFFFFFFF", 128)
    chkLTE("FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLTE("FFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLTE("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator `GTE`":
    check 1.i128       >= 0.i128
    check 1.i128       >= -1.i128
    check 0.i128       >= -1.i128
    check Int128.high  >= Int128.low
    check -1.i128      >= -2.i128
    check 2.i128       >= 1.i128
    check Int128.high  >= 10000.i128
    check 10000.i128   >= Int128.low
    check Int128.low   >= Int128.low
    check Int128.high  >= Int128.high
    check 10000.i128   >= 10000.i128

    check 1.i256       >= 0.i256
    check 1.i256       >= -1.i256
    check 0.i256       >= -1.i256
    check Int256.high  >= Int256.low
    check -1.i256      >= -2.i256
    check 2.i256       >= 1.i256
    check Int256.high  >= 10000.i256
    check 10000.i256   >= Int256.low
    check Int256.low   >= Int256.low
    check Int256.high  >= Int256.high
    check 10000.i256   >= 10000.i256

    chkNotLTE("0", "F", 128)
    chkNotLTE("F", "FF", 128)
    chkNotLTE("FF", "FFF", 128)
    chkNotLTE("FFFF", "FFFFF", 128)
    chkNotLTE("FFFFF", "FFFFFFFF", 128)
    chkNotLTE("FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNotLTE("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator `EQ`":
    check 0.i128 == 0.i128
    check 1.i128 == 1.i128
    check -1.i128 == -1.i128
    check Int128.high == Int128.high
    check Int128.low == Int128.low

    check 0.i256 == 0.i256
    check 1.i256 == 1.i256
    check -1.i256 == -1.i256
    check Int256.high == Int256.high
    check Int256.low == Int256.low

    chkEQ("0", "0", 128)
    chkEQ("F", "F", 128)
    chkEQ("FF", "FF", 128)
    chkEQ("FFFF", "FFFF", 128)
    chkEQ("FFFFF", "FFFFF", 128)
    chkEQ("FFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator not `EQ`":
    check Int128.low != Int128.high
    check Int128.high != Int128.low
    check 0.i256 != 1.i256
    check 1.i256 != 0.i256
    check 1.i256 != -1.i256
    check -1.i256 != 1.i256

    chkNotEQ("0", "F", 128)
    chkNotEQ("F", "FF", 128)
    chkNotEQ("FF", "FFF", 128)
    chkNotEQ("FFFF", "FFFFF", 128)
    chkNotEQ("FFFFF", "FFAFFFFF", 128)
    chkNotEQ("FFFFFFFFFFF", "AFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator `isZero`":
    chkIsZero("0", 128)
    chkIsZero("0", 256)

  test "operator not `isZero`":
    chkNotIsZero("5", 128)
    chkNotIsZero("6", 256)

    chkNotIsZero("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNotIsZero("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 256)

  test "operator `isNegative`":
    chkIsNegative("F0000000000000000000000000000000", 128)
    chkIsNegative("F000000000000000000000000000000000000000000000000000000000000000", 256)

    chkIsNegative("A5000000000000000000000000000000", 128)
    chkIsNegative("A600000000000000000000000000000000000000000000000000000000000000", 256)

  test "operator not `isNegative`":
    chkNotIsNegative("0", 128)
    chkNotIsNegative("0", 256)

    chkNotIsNegative("5", 128)
    chkNotIsNegative("6", 256)

    chkNotIsNegative("75000000000000000000000000000000", 128)
    chkNotIsNegative("7600000000000000000000000000000000000000000000000000000000000000", 256)

  test "operator `isOdd`":
    chkIsOdd("1", 128)
    chkIsOdd("1", 256)

    chkIsOdd("FFFFFFFFFFFFFFF", 128)
    chkIsOdd("FFFFFFFFFFFFFFFFFF", 256)

  test "operator not `isOdd`":
    chkNotIsOdd("0", 128)
    chkNotIsOdd("0", 256)

    chkNotIsOdd("4", 128)
    chkNotIsOdd("4", 256)

    chkNotIsOdd("FFFFFFFFFFFFFFA", 128)
    chkNotIsOdd("FFFFFFFFFFFFFFFFFA", 256)

  test "operator `isEven`":
    chkIsEven("0", 128)
    chkIsEven("0", 256)

    chkIsEven("4", 128)
    chkIsEven("4", 256)

    chkIsEven("FFFFFFFFFFFFFFA", 128)
    chkIsEven("FFFFFFFFFFFFFFFFFA", 256)

  test "operator not `isEven`":
    chkNotIsEven("1", 128)
    chkNotIsEven("1", 256)

    chkNotIsEven("FFFFFFFFFFFFFFF", 128)
    chkNotIsEven("FFFFFFFFFFFFFFFFFF", 256)

  test "isOne":
    let x = 1.i128
    check x.isOne

    let y = 1.i256
    check y.isOne

suite "Signed int - Testing comparison operators":
  const
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

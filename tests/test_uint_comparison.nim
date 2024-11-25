# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template chkLT(a, b: string, bits: int) =
  check fromHex(StUint[bits], a) < fromHex(StUint[bits], b)

template chkNotLT(a, b: string, bits: int) =
  check (not(fromHex(StUint[bits], b) < fromHex(StUint[bits], a)))

template chkLTE(a, b: string, bits: int) =
  check fromHex(StUint[bits], a) <= fromHex(StUint[bits], b)

template chkNotLTE(a, b: string, bits: int) =
  check (not(fromHex(StUint[bits], b) <= fromHex(StUint[bits], a)))

template chkEQ(a, b: string, bits: int) =
  check fromHex(StUint[bits], a) == fromHex(StUint[bits], b)

template chkNotEQ(a, b: string, bits: int) =
  check (not(fromHex(StUint[bits], a) == fromHex(StUint[bits], b)))

template chkIsZero(a: string, bits: int) =
  check fromHex(StUint[bits], a).isZero()

template chkNotIsZero(a: string, bits: int) =
  check (not fromHex(StUint[bits], a).isZero())

template chkIsOdd(a: string, bits: int) =
  check fromHex(StUint[bits], a).isOdd()

template chkNotIsOdd(a: string, bits: int) =
  check (not fromHex(StUint[bits], a).isOdd())

suite "Wider unsigned int comparison coverage":
  test "operator `LT`":
    chkLT("0", "F", 64)
    chkLT("F", "FF", 64)
    chkLT("FF", "FFF", 64)
    chkLT("FFFF", "FFFFF", 64)
    chkLT("FFFFF", "FFFFFFFF", 64)

    chkLT("0", "F", 128)
    chkLT("F", "FF", 128)
    chkLT("FF", "FFF", 128)
    chkLT("FFFF", "FFFFF", 128)
    chkLT("FFFFF", "FFFFFFFF", 128)
    chkLT("FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator not `LT`":
    chkNotLT("0", "F", 64)
    chkNotLT("F", "FF", 64)
    chkNotLT("FF", "FFF", 64)
    chkNotLT("FFFF", "FFFFF", 64)
    chkNotLT("FFFFF", "FFFFFFFF", 64)

    chkNotLT("0", "F", 128)
    chkNotLT("F", "FF", 128)
    chkNotLT("FF", "FFF", 128)
    chkNotLT("FFFF", "FFFFF", 128)
    chkNotLT("FFFFF", "FFFFFFFF", 128)
    chkNotLT("FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator `LTE`":
    chkLTE("0", "F", 64)
    chkLTE("F", "FF", 64)
    chkLTE("FF", "FFF", 64)
    chkLTE("FFFF", "FFFFF", 64)
    chkLTE("FFFFF", "FFFFFFFF", 64)
    chkLTE("FFFFFFFF", "FFFFFFFF", 64)

    chkLTE("0", "F", 128)
    chkLTE("F", "FF", 128)
    chkLTE("FF", "FFF", 128)
    chkLTE("FFFF", "FFFFF", 128)
    chkLTE("FFFFF", "FFFFFFFF", 128)
    chkLTE("FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLTE("FFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator not `LTE`":
    chkNotLTE("0", "F", 64)
    chkNotLTE("F", "FF", 64)
    chkNotLTE("FF", "FFF", 64)
    chkNotLTE("FFFF", "FFFFF", 64)
    chkNotLTE("FFFFF", "FFFFFFFF", 64)

    chkNotLTE("0", "F", 128)
    chkNotLTE("F", "FF", 128)
    chkNotLTE("FF", "FFF", 128)
    chkNotLTE("FFFF", "FFFFF", 128)
    chkNotLTE("FFFFF", "FFFFFFFF", 128)
    chkNotLTE("FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator `EQ`":
    chkEQ("0", "0", 64)
    chkEQ("F", "F", 64)
    chkEQ("FF", "FF", 64)
    chkEQ("FFFF", "FFFF", 64)
    chkEQ("FFFFF", "FFFFF", 64)
    chkEQ("FFFFFFFF", "FFFFFFFF", 64)

    chkEQ("0", "0", 128)
    chkEQ("F", "F", 128)
    chkEQ("FF", "FF", 128)
    chkEQ("FFFF", "FFFF", 128)
    chkEQ("FFFFF", "FFFFF", 128)
    chkEQ("FFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator not `EQ`":
    chkNotEQ("0", "F", 64)
    chkNotEQ("F", "FF", 64)
    chkNotEQ("FF", "FFF", 64)
    chkNotEQ("FFFF", "FFFFF", 64)
    chkNotEQ("FFFFF", "FFFFFFFF", 64)

    chkNotEQ("0", "F", 128)
    chkNotEQ("F", "FF", 128)
    chkNotEQ("FF", "FFF", 128)
    chkNotEQ("FFFF", "FFFFF", 128)
    chkNotEQ("FFFFF", "FFFFFFFF", 128)
    chkNotEQ("FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  test "operator `isZero`":
    chkIsZero("0", 64)
    chkIsZero("0", 128)
    chkIsZero("0", 256)

  test "operator not `isZero`":
    chkNotIsZero("4", 64)
    chkNotIsZero("5", 128)
    chkNotIsZero("6", 256)

  test "operator `isOdd`":
    chkIsOdd("1", 64)
    chkIsOdd("1", 128)
    chkIsOdd("1", 256)

    chkIsOdd("FFFFFF", 64)
    chkIsOdd("FFFFFFFFFFFFFFF", 128)
    chkIsOdd("FFFFFFFFFFFFFFFFFF", 256)

  test "operator not `isOdd`":
    chkNotIsOdd("0", 64)
    chkNotIsOdd("0", 128)
    chkNotIsOdd("0", 256)

    chkNotIsOdd("4", 64)
    chkNotIsOdd("4", 128)
    chkNotIsOdd("4", 256)

    chkNotIsOdd("FFFFFA", 64)
    chkNotIsOdd("FFFFFFFFFFFFFFA", 128)
    chkNotIsOdd("FFFFFFFFFFFFFFFFFA", 256)

  test "operator `isEven`":
    chkNotIsOdd("0", 64)
    chkNotIsOdd("0", 128)
    chkNotIsOdd("0", 256)

    chkNotIsOdd("4", 64)
    chkNotIsOdd("4", 128)
    chkNotIsOdd("4", 256)

    chkNotIsOdd("FFFFFA", 64)
    chkNotIsOdd("FFFFFFFFFFFFFFA", 128)
    chkNotIsOdd("FFFFFFFFFFFFFFFFFA", 256)

  test "operator not `isEven`":
    chkIsOdd("1", 64)
    chkIsOdd("1", 128)
    chkIsOdd("1", 256)

    chkIsOdd("FFFFFF", 64)
    chkIsOdd("FFFFFFFFFFFFFFF", 128)
    chkIsOdd("FFFFFFFFFFFFFFFFFF", 256)

suite "Testing unsigned int comparison operators":
  const
    a = 10.stuint(64)
    b = 15.stuint(64)
    c = 150'u64
    d = 4.stuint(128) shl 64
    e = 4.stuint(128)
    f = 4.stuint(128) shl 65

  test "< operator":
    check:
      a < b
      not (a + b < b)
      not (a + a + a < b + b)
      not (a * b < c.stuint(64))
      e < d
      d < f

  test "<= operator":
    check:
      a <= b
      not (a + b <= b)
      a + a + a <= b + b
      a * b <= c.stuint(64)
      e <= d
      d <= f

  test "> operator":
    check:
      b > a
      not (b > a + b)
      not (b + b > a + a + a)
      not (c.stuint(64) > a * b)
      d > e
      f > d

  test ">= operator":
    check:
      b >= a
      not (b >= a + b)
      b + b >= a + a + a
      c.stuint(64) >= a * b
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

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
    chkLT(chk, "0", "F", 8)
    chkLT(chk, "F", "7F", 8)
    chkLT(chk, "FF", "7F", 8)

    chkLT(chk, "0", "F", 16)
    chkLT(chk, "F", "FF", 16)
    chkLT(chk, "FF", "FFF", 16)
    chkLT(chk, "FFFF", "FFF", 16)

    chkLT(chk, "0", "F", 32)
    chkLT(chk, "F", "FF", 32)
    chkLT(chk, "FF", "FFF", 32)
    chkLT(chk, "FFFF", "FFFFF", 32)
    chkLT(chk, "FFFFFFFF", "FFFFF", 32)

    chkLT(chk, "0", "F", 64)
    chkLT(chk, "F", "FF", 64)
    chkLT(chk, "FF", "FFF", 64)
    chkLT(chk, "FFFF", "FFFFF", 64)
    chkLT(chk, "FFFFF", "FFFFFFFF", 64)
    chkLT(chk, "FFFFFFFFFFFFFFFF", "FFFFFFFF", 64)

    chkLT(chk, "0", "F", 128)
    chkLT(chk, "F", "FF", 128)
    chkLT(chk, "FF", "FFF", 128)
    chkLT(chk, "FFFF", "FFFFF", 128)
    chkLT(chk, "FFFFF", "FFFFFFFF", 128)
    chkLT(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLT(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator not `LT`":
    chkNotLT(chk, "0", "F", 8)
    chkNotLT(chk, "F", "7F", 8)
    chkNotLT(chk, "FF", "7F", 8)

    chkNotLT(chk, "0", "F", 16)
    chkNotLT(chk, "F", "FF", 16)
    chkNotLT(chk, "FF", "FFF", 16)
    chkNotLT(chk, "FFFF", "FFF", 16)

    chkNotLT(chk, "0", "F", 32)
    chkNotLT(chk, "F", "FF", 32)
    chkNotLT(chk, "FF", "FFF", 32)
    chkNotLT(chk, "FFFF", "FFFFF", 32)
    chkNotLT(chk, "FFFFFFFF", "FFFFF", 32)

    chkNotLT(chk, "0", "F", 64)
    chkNotLT(chk, "F", "FF", 64)
    chkNotLT(chk, "FF", "FFF", 64)
    chkNotLT(chk, "FFFF", "FFFFF", 64)
    chkNotLT(chk, "FFFFF", "FFFFFFFF", 64)
    chkNotLT(chk, "FFFFFFFFFFFFFFFF", "FFFFFFFF", 64)

    chkNotLT(chk, "0", "F", 128)
    chkNotLT(chk, "F", "FF", 128)
    chkNotLT(chk, "FF", "FFF", 128)
    chkNotLT(chk, "FFFF", "FFFFF", 128)
    chkNotLT(chk, "FFFFF", "FFFFFFFF", 128)
    chkNotLT(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNotLT(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `LTE`":
    chkLTE(chk, "0", "F", 8)
    chkLTE(chk, "F", "7F", 8)
    chkLTE(chk, "F", "F", 8)
    chkLTE(chk, "FF", "7F", 8)

    chkLTE(chk, "0", "F", 16)
    chkLTE(chk, "F", "FF", 16)
    chkLTE(chk, "FF", "FFF", 16)
    chkLTE(chk, "FFF", "FFF", 16)
    chkLTE(chk, "FFFF", "FFF", 16)

    chkLTE(chk, "0", "F", 32)
    chkLTE(chk, "F", "FF", 32)
    chkLTE(chk, "FF", "FFF", 32)
    chkLTE(chk, "FFFF", "FFFFF", 32)
    chkLTE(chk, "FFFFF", "FFFFF", 32)
    chkLTE(chk, "FFFFFFFF", "FFFFF", 32)

    chkLTE(chk, "0", "F", 64)
    chkLTE(chk, "F", "FF", 64)
    chkLTE(chk, "FF", "FFF", 64)
    chkLTE(chk, "FFFF", "FFFFF", 64)
    chkLTE(chk, "FFFFF", "FFFFFFFF", 64)
    chkLTE(chk, "FFFFFFFF", "FFFFFFFF", 64)
    chkLTE(chk, "FFFFFFFFFFFFFFFF", "FFFFFFFF", 64)

    chkLTE(chk, "0", "F", 128)
    chkLTE(chk, "F", "FF", 128)
    chkLTE(chk, "FF", "FFF", 128)
    chkLTE(chk, "FFFF", "FFFFF", 128)
    chkLTE(chk, "FFFFF", "FFFFFFFF", 128)
    chkLTE(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLTE(chk, "FFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkLTE(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator not `LTE`":
    chkNotLTE(chk, "0", "F", 8)
    chkNotLTE(chk, "F", "7F", 8)
    chkNotLTE(chk, "FF", "7F", 8)

    chkNotLTE(chk, "0", "F", 16)
    chkNotLTE(chk, "F", "FF", 16)
    chkNotLTE(chk, "FF", "FFF", 16)
    chkNotLTE(chk, "FFFF", "FFF", 16)

    chkNotLTE(chk, "0", "F", 32)
    chkNotLTE(chk, "F", "FF", 32)
    chkNotLTE(chk, "FF", "FFF", 32)
    chkNotLTE(chk, "FFFF", "FFFFF", 32)
    chkNotLTE(chk, "FFFFFFFF", "FFFFF", 32)

    chkNotLTE(chk, "0", "F", 64)
    chkNotLTE(chk, "F", "FF", 64)
    chkNotLTE(chk, "FF", "FFF", 64)
    chkNotLTE(chk, "FFFF", "FFFFF", 64)
    chkNotLTE(chk, "FFFFF", "FFFFFFFF", 64)
    chkNotLTE(chk, "FFFFFFFFFFFFFFFF", "FFFFFFFF", 64)

    chkNotLTE(chk, "0", "F", 128)
    chkNotLTE(chk, "F", "FF", 128)
    chkNotLTE(chk, "FF", "FFF", 128)
    chkNotLTE(chk, "FFFF", "FFFFF", 128)
    chkNotLTE(chk, "FFFFF", "FFFFFFFF", 128)
    chkNotLTE(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNotLTE(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `EQ`":
    chkEQ(chk, "0", "0", 8)
    chkEQ(chk, "FF", "FF", 8)
    chkEQ(chk, "F", "F", 8)

    chkEQ(chk, "0", "0", 16)
    chkEQ(chk, "F", "F", 16)
    chkEQ(chk, "FF", "FF", 16)
    chkEQ(chk, "FFF", "FFF", 16)
    chkEQ(chk, "FFFF", "FFFF", 16)

    chkEQ(chk, "0", "0", 32)
    chkEQ(chk, "F", "F", 32)
    chkEQ(chk, "FF", "FF", 32)
    chkEQ(chk, "FFFF", "FFFF", 32)
    chkEQ(chk, "FFFFF", "FFFFF", 32)

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
    chkNotEQ(chk, "0", "F", 8)
    chkNotEQ(chk, "F", "FF", 8)

    chkNotEQ(chk, "0", "F", 16)
    chkNotEQ(chk, "F", "FF", 16)
    chkNotEQ(chk, "FF", "FFA", 16)

    chkNotEQ(chk, "0", "F", 32)
    chkNotEQ(chk, "F", "FF", 32)
    chkNotEQ(chk, "FF", "FFF", 32)
    chkNotEQ(chk, "FFFF", "FAFFF", 32)

    chkNotEQ(chk, "0", "F", 64)
    chkNotEQ(chk, "F", "FF", 64)
    chkNotEQ(chk, "FF", "FFF", 64)
    chkNotEQ(chk, "FFFF", "FFFFF", 64)
    chkNotEQ(chk, "FFFFF", "FAFFFFFFF", 64)

    chkNotEQ(chk, "0", "F", 128)
    chkNotEQ(chk, "F", "FF", 128)
    chkNotEQ(chk, "FF", "FFF", 128)
    chkNotEQ(chk, "FFFF", "FFFFF", 128)
    chkNotEQ(chk, "FFFFF", "FFAFFFFF", 128)
    chkNotEQ(chk, "FFFFFFFFFFF", "AFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `isZero`":
    chkIsZero(chk, "0", 8)
    chkIsZero(chk, "0", 16)
    chkIsZero(chk, "0", 32)
    chkIsZero(chk, "0", 64)
    chkIsZero(chk, "0", 128)
    chkIsZero(chk, "0", 256)

  tst "operator not `isZero`":
    chkNotIsZero(chk, "1", 8)
    chkNotIsZero(chk, "2", 16)
    chkNotIsZero(chk, "3", 32)
    chkNotIsZero(chk, "4", 64)
    chkNotIsZero(chk, "5", 128)
    chkNotIsZero(chk, "6", 256)

    chkNotIsZero(chk, "FF", 8)
    chkNotIsZero(chk, "FFFF", 16)
    chkNotIsZero(chk, "FFFFFFFF", 32)
    chkNotIsZero(chk, "FFFFFFFFFFFFFFFF", 64)
    chkNotIsZero(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNotIsZero(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 256)

  tst "operator `isNegative`":
    chkIsNegative(chk, "F0", 8)
    chkIsNegative(chk, "F000", 16)
    chkIsNegative(chk, "F0000000", 32)
    chkIsNegative(chk, "F000000000000000", 64)
    chkIsNegative(chk, "F0000000000000000000000000000000", 128)
    chkIsNegative(chk, "F000000000000000000000000000000000000000000000000000000000000000", 256)

    chkIsNegative(chk, "A1", 8)
    chkIsNegative(chk, "A200", 16)
    chkIsNegative(chk, "A3000000", 32)
    chkIsNegative(chk, "A400000000000000", 64)
    chkIsNegative(chk, "A5000000000000000000000000000000", 128)
    chkIsNegative(chk, "A600000000000000000000000000000000000000000000000000000000000000", 256)

  tst "operator not `isNegative`":
    chkNotIsNegative(chk, "0", 8)
    chkNotIsNegative(chk, "0", 16)
    chkNotIsNegative(chk, "0", 32)
    chkNotIsNegative(chk, "0", 64)
    chkNotIsNegative(chk, "0", 128)
    chkNotIsNegative(chk, "0", 256)

    chkNotIsNegative(chk, "1", 8)
    chkNotIsNegative(chk, "2", 16)
    chkNotIsNegative(chk, "3", 32)
    chkNotIsNegative(chk, "4", 64)
    chkNotIsNegative(chk, "5", 128)
    chkNotIsNegative(chk, "6", 256)

    chkNotIsNegative(chk, "71", 8)
    chkNotIsNegative(chk, "7200", 16)
    chkNotIsNegative(chk, "73000000", 32)
    chkNotIsNegative(chk, "7400000000000000", 64)
    chkNotIsNegative(chk, "75000000000000000000000000000000", 128)
    chkNotIsNegative(chk, "7600000000000000000000000000000000000000000000000000000000000000", 256)

  tst "operator `isOdd`":
    chkIsOdd(chk, "1", 8)
    chkIsOdd(chk, "1", 16)
    chkIsOdd(chk, "1", 32)
    chkIsOdd(chk, "1", 64)
    chkIsOdd(chk, "1", 128)
    chkIsOdd(chk, "1", 256)

    chkIsOdd(chk, "FF", 8)
    chkIsOdd(chk, "FFF", 16)
    chkIsOdd(chk, "FFFFF", 32)
    chkIsOdd(chk, "FFFFFF", 64)
    chkIsOdd(chk, "FFFFFFFFFFFFFFF", 128)
    chkIsOdd(chk, "FFFFFFFFFFFFFFFFFF", 256)

  tst "operator not `isOdd`":
    chkNotIsOdd(chk, "0", 8)
    chkNotIsOdd(chk, "0", 16)
    chkNotIsOdd(chk, "0", 32)
    chkNotIsOdd(chk, "0", 64)
    chkNotIsOdd(chk, "0", 128)
    chkNotIsOdd(chk, "0", 256)

    chkNotIsOdd(chk, "4", 8)
    chkNotIsOdd(chk, "4", 16)
    chkNotIsOdd(chk, "4", 32)
    chkNotIsOdd(chk, "4", 64)
    chkNotIsOdd(chk, "4", 128)
    chkNotIsOdd(chk, "4", 256)

    chkNotIsOdd(chk, "A", 8)
    chkNotIsOdd(chk, "AAA", 16)
    chkNotIsOdd(chk, "AAAA", 32)
    chkNotIsOdd(chk, "FFFFFA", 64)
    chkNotIsOdd(chk, "FFFFFFFFFFFFFFA", 128)
    chkNotIsOdd(chk, "FFFFFFFFFFFFFFFFFA", 256)

  tst "operator `isEven`":
    chkNotIsOdd(chk, "0", 8)
    chkNotIsOdd(chk, "0", 16)
    chkNotIsOdd(chk, "0", 32)
    chkNotIsOdd(chk, "0", 64)
    chkNotIsOdd(chk, "0", 128)
    chkNotIsOdd(chk, "0", 256)

    chkNotIsOdd(chk, "4", 8)
    chkNotIsOdd(chk, "4", 16)
    chkNotIsOdd(chk, "4", 32)
    chkNotIsOdd(chk, "4", 64)
    chkNotIsOdd(chk, "4", 128)
    chkNotIsOdd(chk, "4", 256)

    chkNotIsOdd(chk, "A", 8)
    chkNotIsOdd(chk, "AAA", 16)
    chkNotIsOdd(chk, "AAAA", 32)
    chkNotIsOdd(chk, "FFFFFA", 64)
    chkNotIsOdd(chk, "FFFFFFFFFFFFFFA", 128)
    chkNotIsOdd(chk, "FFFFFFFFFFFFFFFFFA", 256)

  tst "operator not `isEven`":
    chkIsOdd(chk, "1", 8)
    chkIsOdd(chk, "1", 16)
    chkIsOdd(chk, "1", 32)
    chkIsOdd(chk, "1", 64)
    chkIsOdd(chk, "1", 128)
    chkIsOdd(chk, "1", 256)

    chkIsOdd(chk, "FF", 8)
    chkIsOdd(chk, "FFF", 16)
    chkIsOdd(chk, "FFFFF", 32)
    chkIsOdd(chk, "FFFFFF", 64)
    chkIsOdd(chk, "FFFFFFFFFFFFFFF", 128)
    chkIsOdd(chk, "FFFFFFFFFFFFFFFFFF", 256)

static:
  testComparison(ctCheck, ctTest)

proc main() =
  # Nim GC protests we are using too much global variables
  # so put it in a proc

  suite "Wider signed int comparison coverage":
    testComparison(check, test)

  suite "Signed int - Testing comparison operators":
    let
      a = 10'i16.stint(16)
      b = 15'i16.stint(16)
      c = 150'i16.stint(16)

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

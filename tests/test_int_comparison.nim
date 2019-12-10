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
  chk fromHex(Stint[bits], a) < fromHex(Stint[bits], b)

template chknotLT(chk: untyped, a, b: string, bits: int) =
  chk (not(fromHex(Stint[bits], b) < fromHex(Stint[bits], a)))

template chkLTE(chk: untyped, a, b: string, bits: int) =
  chk fromHex(Stint[bits], a) <= fromHex(Stint[bits], b)

template chknotLTE(chk: untyped, a, b: string, bits: int) =
  chk (not(fromHex(Stint[bits], b) <= fromHex(Stint[bits], a)))

template chkEQ(chk: untyped, a, b: string, bits: int) =
  chk fromHex(Stint[bits], a) == fromHex(Stint[bits], b)

template chknotEQ(chk: untyped, a, b: string, bits: int) =
  chk (not(fromHex(Stint[bits], a) == fromHex(Stint[bits], b)))

template chkisZero(chk: untyped, a: string, bits: int) =
  chk fromHex(Stint[bits], a).isZero()

template chknotisZero(chk: untyped, a: string, bits: int) =
  chk (not fromHex(Stint[bits], a).isZero())

template chkisNegative(chk: untyped, a: string, bits: int) =
  chk fromHex(Stint[bits], a).isNegative()

template chknotisNegative(chk: untyped, a: string, bits: int) =
  chk (not fromHex(Stint[bits], a).isNegative())

template chkisOdd(chk: untyped, a: string, bits: int) =
  chk fromHex(Stint[bits], a).isOdd()

template chknotisOdd(chk: untyped, a: string, bits: int) =
  chk (not fromHex(Stint[bits], a).isOdd())

template chkisEven(chk: untyped, a: string, bits: int) =
  chk fromHex(Stint[bits], a).isEven()

template chknotisEven(chk: untyped, a: string, bits: int) =
  chk (not fromHex(Stint[bits], a).isEven())

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
    chknotLT(chk, "0", "F", 8)
    chknotLT(chk, "F", "7F", 8)
    chknotLT(chk, "FF", "7F", 8)

    chknotLT(chk, "0", "F", 16)
    chknotLT(chk, "F", "FF", 16)
    chknotLT(chk, "FF", "FFF", 16)
    chknotLT(chk, "FFFF", "FFF", 16)

    chknotLT(chk, "0", "F", 32)
    chknotLT(chk, "F", "FF", 32)
    chknotLT(chk, "FF", "FFF", 32)
    chknotLT(chk, "FFFF", "FFFFF", 32)
    chknotLT(chk, "FFFFFFFF", "FFFFF", 32)

    chknotLT(chk, "0", "F", 64)
    chknotLT(chk, "F", "FF", 64)
    chknotLT(chk, "FF", "FFF", 64)
    chknotLT(chk, "FFFF", "FFFFF", 64)
    chknotLT(chk, "FFFFF", "FFFFFFFF", 64)
    chknotLT(chk, "FFFFFFFFFFFFFFFF", "FFFFFFFF", 64)

    chknotLT(chk, "0", "F", 128)
    chknotLT(chk, "F", "FF", 128)
    chknotLT(chk, "FF", "FFF", 128)
    chknotLT(chk, "FFFF", "FFFFF", 128)
    chknotLT(chk, "FFFFF", "FFFFFFFF", 128)
    chknotLT(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chknotLT(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

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
    chknotLTE(chk, "0", "F", 8)
    chknotLTE(chk, "F", "7F", 8)
    chknotLTE(chk, "FF", "7F", 8)

    chknotLTE(chk, "0", "F", 16)
    chknotLTE(chk, "F", "FF", 16)
    chknotLTE(chk, "FF", "FFF", 16)
    chknotLTE(chk, "FFFF", "FFF", 16)

    chknotLTE(chk, "0", "F", 32)
    chknotLTE(chk, "F", "FF", 32)
    chknotLTE(chk, "FF", "FFF", 32)
    chknotLTE(chk, "FFFF", "FFFFF", 32)
    chknotLTE(chk, "FFFFFFFF", "FFFFF", 32)

    chknotLTE(chk, "0", "F", 64)
    chknotLTE(chk, "F", "FF", 64)
    chknotLTE(chk, "FF", "FFF", 64)
    chknotLTE(chk, "FFFF", "FFFFF", 64)
    chknotLTE(chk, "FFFFF", "FFFFFFFF", 64)
    chknotLTE(chk, "FFFFFFFFFFFFFFFF", "FFFFFFFF", 64)

    chknotLTE(chk, "0", "F", 128)
    chknotLTE(chk, "F", "FF", 128)
    chknotLTE(chk, "FF", "FFF", 128)
    chknotLTE(chk, "FFFF", "FFFFF", 128)
    chknotLTE(chk, "FFFFF", "FFFFFFFF", 128)
    chknotLTE(chk, "FFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chknotLTE(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFF", 128)

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
    chknotEQ(chk, "0", "F", 8)
    chknotEQ(chk, "F", "FF", 8)

    chknotEQ(chk, "0", "F", 16)
    chknotEQ(chk, "F", "FF", 16)
    chknotEQ(chk, "FF", "FFA", 16)

    chknotEQ(chk, "0", "F", 32)
    chknotEQ(chk, "F", "FF", 32)
    chknotEQ(chk, "FF", "FFF", 32)
    chknotEQ(chk, "FFFF", "FAFFF", 32)

    chknotEQ(chk, "0", "F", 64)
    chknotEQ(chk, "F", "FF", 64)
    chknotEQ(chk, "FF", "FFF", 64)
    chknotEQ(chk, "FFFF", "FFFFF", 64)
    chknotEQ(chk, "FFFFF", "FAFFFFFFF", 64)

    chknotEQ(chk, "0", "F", 128)
    chknotEQ(chk, "F", "FF", 128)
    chknotEQ(chk, "FF", "FFF", 128)
    chknotEQ(chk, "FFFF", "FFFFF", 128)
    chknotEQ(chk, "FFFFF", "FFAFFFFF", 128)
    chknotEQ(chk, "FFFFFFFFFFF", "AFFFFFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `isZero`":
    chkIsZero(chk, "0", 8)
    chkIsZero(chk, "0", 16)
    chkIsZero(chk, "0", 32)
    chkIsZero(chk, "0", 64)
    chkIsZero(chk, "0", 128)
    chkIsZero(chk, "0", 256)

  tst "operator not `isZero`":
    chknotIsZero(chk, "1", 8)
    chknotIsZero(chk, "2", 16)
    chknotIsZero(chk, "3", 32)
    chknotIsZero(chk, "4", 64)
    chknotIsZero(chk, "5", 128)
    chknotIsZero(chk, "6", 256)

    chknotIsZero(chk, "FF", 8)
    chknotIsZero(chk, "FFFF", 16)
    chknotIsZero(chk, "FFFFFFFF", 32)
    chknotIsZero(chk, "FFFFFFFFFFFFFFFF", 64)
    chknotIsZero(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chknotIsZero(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 256)

  tst "operator `isNegative`":
    chkisNegative(chk, "F0", 8)
    chkisNegative(chk, "F000", 16)
    chkisNegative(chk, "F0000000", 32)
    chkisNegative(chk, "F000000000000000", 64)
    chkisNegative(chk, "F0000000000000000000000000000000", 128)
    chkisNegative(chk, "F000000000000000000000000000000000000000000000000000000000000000", 256)

    chkisNegative(chk, "A1", 8)
    chkisNegative(chk, "A200", 16)
    chkisNegative(chk, "A3000000", 32)
    chkisNegative(chk, "A400000000000000", 64)
    chkisNegative(chk, "A5000000000000000000000000000000", 128)
    chkisNegative(chk, "A600000000000000000000000000000000000000000000000000000000000000", 256)

  tst "operator not `isNegative`":
    chknotIsNegative(chk, "0", 8)
    chknotIsNegative(chk, "0", 16)
    chknotIsNegative(chk, "0", 32)
    chknotIsNegative(chk, "0", 64)
    chknotIsNegative(chk, "0", 128)
    chknotIsNegative(chk, "0", 256)

    chknotIsNegative(chk, "1", 8)
    chknotIsNegative(chk, "2", 16)
    chknotIsNegative(chk, "3", 32)
    chknotIsNegative(chk, "4", 64)
    chknotIsNegative(chk, "5", 128)
    chknotIsNegative(chk, "6", 256)

    chknotIsNegative(chk, "71", 8)
    chknotIsNegative(chk, "7200", 16)
    chknotIsNegative(chk, "73000000", 32)
    chknotIsNegative(chk, "7400000000000000", 64)
    chknotIsNegative(chk, "75000000000000000000000000000000", 128)
    chknotIsNegative(chk, "7600000000000000000000000000000000000000000000000000000000000000", 256)

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

# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, test_helpers

template chkMul(chk: untyped, a, b, c: string, bits: int) =
  chk (fromHex(StInt[bits], a) * fromHex(StInt[bits], b)) == fromHex(StInt[bits], c)

template chkDiv(chk: untyped, a, b, c: string, bits: int) =
  chk (fromHex(StInt[bits], a) div fromHex(StInt[bits], b)) == fromHex(StInt[bits], c)

template chkMod(chk: untyped, a, b, c: string, bits: int) =
  chk (fromHex(StInt[bits], a) mod fromHex(StInt[bits], b)) == fromHex(StInt[bits], c)

template chkMod(chk: untyped, a, b, c: int, bits: int) =
  chk (stint(a, bits) mod stint(b, bits)) == stint(c, bits)

template chkDivMod(chk: untyped, a, b, c, d: string, bits: int) =
  chk divmod(fromHex(StInt[bits], a), fromHex(StInt[bits], b)) == (fromHex(StInt[bits], c), fromHex(StInt[bits], d))

template testMuldiv(chk, tst: untyped) =
  tst "operator `mul`":
    chkMul(chk, "0", "3", "0", 128)
    chkMul(chk, "1", "3", "3", 128)
    chkMul(chk, "F0", "3", "2D0", 128)
    chkMul(chk, "F000", "3", "2D000", 128)
    chkMul(chk, "F0000000", "3", "2D0000000", 128)
    chkMul(chk, "F000000000000000", "3", "2D000000000000000", 128)
    chkMul(chk, "F0000000000000000000000000000000", "3", "D0000000000000000000000000000000", 128)
    chkMul(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "1", 128)

  tst "operator `div`":
    chkDiv(chk, "0", "3", "0", 64)
    chkDiv(chk, "1", "3", "0", 64)
    chkDiv(chk, "3", "3", "1", 64)
    chkDiv(chk, "3", "1", "3", 64)
    chkDiv(chk, "FF", "3", "55", 64)
    chkDiv(chk, "0F", "FF", "0", 64)
    chkDiv(chk, "FF", "FF", "1", 64)
    chkDiv(chk, "FFFF", "3", "5555", 64)
    chkDiv(chk, "0F", "FFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFF1", 64)
    chkDiv(chk, "FFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFF", "1", 64)

    chkDiv(chk, "0", "3", "0", 128)
    chkDiv(chk, "1", "3", "0", 128)
    chkDiv(chk, "3", "3", "1", 128)
    chkDiv(chk, "3", "1", "3", 128)
    chkDiv(chk, "FF", "3", "55", 128)
    chkDiv(chk, "0F", "FF", "0", 128)
    chkDiv(chk, "FF", "FF", "1", 128)
    chkDiv(chk, "FFFF", "3", "5555", 128)
    chkDiv(chk, "0F", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1", 128)
    chkDiv(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "1", 128)

  tst "operator `mod`":
    chkMod(chk, "0", "3", "0", 64)
    chkMod(chk, "1", "3", "1", 64)
    chkMod(chk, "3", "3", "0", 64)
    chkMod(chk, "3", "1", "0", 64)
    chkMod(chk, "FFFFFFFFFFFFFFFF", "3", "FFFFFFFFFFFFFFFF", 64)
    chkMod(chk, "FFFFFFFFFFFFFFFF", "4", "FFFFFFFFFFFFFFFF", 64)
    chkMod(chk, "FFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFF", "0", 64)
    chkMod(chk, "0F", "FFFFFFFFFFFFFFFC", "3", 64)

    chkMod(chk, "0", "3", "0", 128)
    chkMod(chk, "1", "3", "1", 128)
    chkMod(chk, "3", "3", "0", 128)
    chkMod(chk, "3", "1", "0", 128)
    chkMod(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "3", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkMod(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "4", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkMod(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "0", 128)
    chkMod(chk, "0F", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC", "3", 128)

  tst "operator `divmod`":
    chkDivMod(chk, "0", "3", "0", "0", 64)
    chkDivMod(chk, "1", "3", "0", "1", 64)
    chkDivMod(chk, "3", "3", "1", "0", 64)
    chkDivMod(chk, "3", "1", "3", "0", 64)
    chkDivMod(chk, "FFFFFFFFFFFFFFFF", "3", "0", "FFFFFFFFFFFFFFFF", 64)
    chkDivMod(chk, "FFFFFFFFFFFFFFFF", "4", "0", "FFFFFFFFFFFFFFFF", 64)
    chkDivMod(chk, "FFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFF", "1", "0", 64)
    chkDivMod(chk, "0F", "FFFFFFFFFFFFFFFC", "FFFFFFFFFFFFFFFD", "3", 64)

    chkDivMod(chk, "0", "3", "0", "0", 128)
    chkDivMod(chk, "1", "3", "0", "1", 128)
    chkDivMod(chk, "3", "3", "1", "0", 128)
    chkDivMod(chk, "3", "1", "3", "0", 128)
    chkDivMod(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "3", "0", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkDivMod(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "4", "0", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkDivMod(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "1", "0", 128)
    chkDivMod(chk, "0F", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD", "3", 128)

  tst "issues with Nim v1.0.2":
    block:
      let x = -2.stint(256)
      let y = 3200566678774828.stint(256)
      let z = -6401133357549656.stint(256)
      chk x * y == z

    chkMod(chk, -3, 7, -3, 64)
    chkMod(chk, -3, 5, -3, 64)
    chkMod(chk, -13, 5, -3, 64)
    chkMod(chk, 7, 5, 2, 64)
    chkMod(chk, -7, 5, -2, 64)
    chkMod(chk, 7, -5, 2, 64)
    chkMod(chk, -7, -5, -2, 64)

    chkMod(chk, 2, 5, 2, 64)
    chkMod(chk, -2, 5, -2, 64)
    chkMod(chk, 2, -5, 2, 64)
    chkMod(chk, -2, -5, -2, 64)

#static:
  #testMuldiv(ctCheck, ctTest)

suite "Wider signed int muldiv coverage":
  testMuldiv(check, test)

suite "Testing signed int multiplication implementation":
  test "Multiplication with result fitting in low half":

    let a = 10000.stint(64)
    let b = 10000.stint(64)

    check: cast[int64](a*b) == 100_000_000'i64 # need 27-bits

  test "Multiplication with result overflowing low half":

    let a = 1_000_000.stint(64)
    let b = 1_000_000.stint(64)

    check: cast[int64](a*b) == 1_000_000_000_000'i64 # need 40 bits

  test "Multiplication with result fitting in low half - opposite signs":

    let a = -10000.stint(64)
    let b = 10000.stint(64)

    check:
      cast[int64](a*b) == -100_000_000'i64 # need 27-bits
      cast[int64](b*a) == -100_000_000'i64


  test "Multiplication with result overflowing low half - opposite signs":

    let a = -1_000_000.stint(64)
    let b = 1_000_000.stint(64)

    check:
      cast[int64](a*b) == -1_000_000_000_000'i64 # need 40 bits
      cast[int64](b*a) == -1_000_000_000_000'i64

  test "Multiplication with result fitting in low half - both negative":

    let a = -10000.stint(64)
    let b = -10000.stint(64)

    check: cast[int64](a*b) == 100_000_000'i64 # need 27-bits

  test "Multiplication with result overflowing low half - both negative":

    let a = -1_000_000.stint(64)
    let b = -1_000_000.stint(64)

    check: cast[int64](a*b) == 1_000_000_000_000'i64 # need 40 bits

suite "Testing signed int division and modulo implementation":
  test "Divmod(100, 13) returns the correct result":

    let a = 100.stint(64)
    let b = 13.stint(64)
    let qr = divmod(a, b)

    check: cast[int64](qr.quot) == 7'i64
    check: cast[int64](qr.rem)  == 9'i64

  test "Divmod(-100, 13) returns the correct result":

    let a = -100.stint(64)
    let b = 13.stint(64)
    let qr = divmod(a, b)

    check: cast[int64](qr.quot) == -100'i64 div 13
    check: cast[int64](qr.rem)  == -100'i64 mod 13

  test "Divmod(100, -13) returns the correct result":

    let a = 100.stint(64)
    let b = -13.stint(64)
    let qr = divmod(a, b)

    check: cast[int64](qr.quot) == 100'i64 div -13
    check: cast[int64](qr.rem)  == 100'i64 mod -13

  test "Divmod(-100, -13) returns the correct result":

    let a = -100.stint(64)
    let b = -13.stint(64)
    let qr = divmod(a, b)

    check: cast[int64](qr.quot) == -100'i64 div -13
    check: cast[int64](qr.rem)  == -100'i64 mod -13

  test "Divmod(2^64, 3) returns the correct result":
    let a = 1.stint(128) shl 64
    let b = 3.stint(128)

    let qr = divmod(a, b)

    let q = qr.quot
    let r = qr.rem

    check:
      q == 6148914691236517205'u64.i128
      r == 1'u64.i128

  test "Divmod(1234567891234567890, 10) returns the correct result":
    let a = cast[StInt[64]](1234567891234567890'i64)
    let b = cast[StInt[64]](10'i64)

    let qr = divmod(a, b)

    let q = cast[int64](qr.quot)
    let r = cast[int64](qr.rem)

    check: q == 123456789123456789'i64
    check: r == 0'i64

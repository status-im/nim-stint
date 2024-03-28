# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template chkMul(a, b, c: string, bits: int) =
  check (fromHex(StInt[bits], a) * fromHex(StInt[bits], b)) == fromHex(StInt[bits], c)

template chkDiv(a, b, c: string, bits: int) =
  check (fromHex(StInt[bits], a) div fromHex(StInt[bits], b)) == fromHex(StInt[bits], c)

template chkMod(a, b, c: string, bits: int) =
  check (fromHex(StInt[bits], a) mod fromHex(StInt[bits], b)) == fromHex(StInt[bits], c)

template chkMod(a, b, c: int, bits: int) =
  check (stint(a, bits) mod stint(b, bits)) == stint(c, bits)

template chkDivMod(a, b, c, d: string, bits: int) =
  check divmod(fromHex(StInt[bits], a), fromHex(StInt[bits], b)) == (fromHex(StInt[bits], c), fromHex(StInt[bits], d))

suite "Wider signed int muldiv coverage":
  test "operator `mul`":
    chkMul("0", "3", "0", 128)
    chkMul("1", "3", "3", 128)
    chkMul("F0", "3", "2D0", 128)
    chkMul("F000", "3", "2D000", 128)
    chkMul("F0000000", "3", "2D0000000", 128)
    chkMul("F000000000000000", "3", "2D000000000000000", 128)
    chkMul("F0000000000000000000000000000000", "3", "D0000000000000000000000000000000", 128)
    chkMul("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "1", 128)

  test "operator `div`":
    chkDiv("0", "3", "0", 64)
    chkDiv("1", "3", "0", 64)
    chkDiv("3", "3", "1", 64)
    chkDiv("3", "1", "3", 64)
    chkDiv("FF", "3", "55", 64)
    chkDiv("0F", "FF", "0", 64)
    chkDiv("FF", "FF", "1", 64)
    chkDiv("FFFF", "3", "5555", 64)
    chkDiv("0F", "FFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFF1", 64)
    chkDiv("FFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFF", "1", 64)

    chkDiv("0", "3", "0", 128)
    chkDiv("1", "3", "0", 128)
    chkDiv("3", "3", "1", 128)
    chkDiv("3", "1", "3", 128)
    chkDiv("FF", "3", "55", 128)
    chkDiv("0F", "FF", "0", 128)
    chkDiv("FF", "FF", "1", 128)
    chkDiv("FFFF", "3", "5555", 128)
    chkDiv("0F", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1", 128)
    chkDiv("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "1", 128)

  test "operator `mod`":
    chkMod("0", "3", "0", 64)
    chkMod("1", "3", "1", 64)
    chkMod("3", "3", "0", 64)
    chkMod("3", "1", "0", 64)
    chkMod("FFFFFFFFFFFFFFFF", "3", "FFFFFFFFFFFFFFFF", 64)
    chkMod("FFFFFFFFFFFFFFFF", "4", "FFFFFFFFFFFFFFFF", 64)
    chkMod("FFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFF", "0", 64)
    chkMod("0F", "FFFFFFFFFFFFFFFC", "3", 64)

    chkMod("0", "3", "0", 128)
    chkMod("1", "3", "1", 128)
    chkMod("3", "3", "0", 128)
    chkMod("3", "1", "0", 128)
    chkMod("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "3", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkMod("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "4", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkMod("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "0", 128)
    chkMod("0F", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC", "3", 128)

  test "operator `divmod`":
    chkDivMod("0", "3", "0", "0", 64)
    chkDivMod("1", "3", "0", "1", 64)
    chkDivMod("3", "3", "1", "0", 64)
    chkDivMod("3", "1", "3", "0", 64)
    chkDivMod("FFFFFFFFFFFFFFFF", "3", "0", "FFFFFFFFFFFFFFFF", 64)
    chkDivMod("FFFFFFFFFFFFFFFF", "4", "0", "FFFFFFFFFFFFFFFF", 64)
    chkDivMod("FFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFF", "1", "0", 64)
    chkDivMod("0F", "FFFFFFFFFFFFFFFC", "FFFFFFFFFFFFFFFD", "3", 64)

    chkDivMod("0", "3", "0", "0", 128)
    chkDivMod("1", "3", "0", "1", 128)
    chkDivMod("3", "3", "1", "0", 128)
    chkDivMod("3", "1", "3", "0", 128)
    chkDivMod("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "3", "0", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkDivMod("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "4", "0", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkDivMod("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "1", "0", 128)
    chkDivMod("0F", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD", "3", 128)

  test "issues with Nim v1.0.2":
    block:
      let x = -2.stint(256)
      let y = 3200566678774828.stint(256)
      let z = -6401133357549656.stint(256)
      check x * y == z

    chkMod(-3, 7, -3, 64)
    chkMod(-3, 5, -3, 64)
    chkMod(-13, 5, -3, 64)
    chkMod(7, 5, 2, 64)
    chkMod(-7, 5, -2, 64)
    chkMod(7, -5, 2, 64)
    chkMod(-7, -5, -2, 64)

    chkMod(2, 5, 2, 64)
    chkMod(-2, 5, -2, 64)
    chkMod(2, -5, 2, 64)
    chkMod(-2, -5, -2, 64)

suite "Testing signed int multiplication implementation":
  test "Multiplication with result fitting in low half":

    let a = 10000.stint(64)
    let b = 10000.stint(64)

    check: truncate(a*b, int64) == 100_000_000'i64 # need 27-bits

  test "Multiplication with result overflowing low half":

    let a = 1_000_000.stint(64)
    let b = 1_000_000.stint(64)

    check: truncate(a*b, int64) == 1_000_000_000_000'i64 # need 40 bits

  test "Multiplication with result fitting in low half - opposite signs":

    let a = -10000.stint(64)
    let b = 10000.stint(64)

    check:
      truncate(a*b, int64) == -100_000_000'i64 # need 27-bits
      truncate(b*a, int64) == -100_000_000'i64


  test "Multiplication with result overflowing low half - opposite signs":

    let a = -1_000_000.stint(64)
    let b = 1_000_000.stint(64)

    when sizeof(int) == 8:
      check:
        truncate(a*b, int64) == -1_000_000_000_000'i64 # need 40 bits
        truncate(b*a, int64) == -1_000_000_000_000'i64
    else:
      discard # TODO https://github.com/status-im/nim-stint/issues/144
      # TODO truncate fails here

  test "Multiplication with result fitting in low half - both negative":

    let a = -10000.stint(64)
    let b = -10000.stint(64)

    check: truncate(a*b, int64) == 100_000_000'i64 # need 27-bits

  test "Multiplication with result overflowing low half - both negative":

    let a = -1_000_000.stint(64)
    let b = -1_000_000.stint(64)

    check: truncate(a*b, int64) == 1_000_000_000_000'i64 # need 40 bits

suite "Testing signed int division and modulo implementation":
  test "Divmod(100, 13) returns the correct result":

    let a = 100.stint(64)
    let b = 13.stint(64)
    let qr = divmod(a, b)

    check: truncate(qr.quot, int64) == 7'i64
    check: truncate(qr.rem, int64)  == 9'i64

  test "Divmod(-100, 13) returns the correct result":

    let a = -100.stint(64)
    let b = 13.stint(64)
    let qr = divmod(a, b)

    check: truncate(qr.quot, int64) == -100'i64 div 13
    check: truncate(qr.rem, int64)  == -100'i64 mod 13

  test "Divmod(100, -13) returns the correct result":

    let a = 100.stint(64)
    let b = -13.stint(64)
    let qr = divmod(a, b)

    check: truncate(qr.quot, int64) == 100'i64 div -13
    check: truncate(qr.rem, int64)  == 100'i64 mod -13

  test "Divmod(-100, -13) returns the correct result":

    let a = -100.stint(64)
    let b = -13.stint(64)
    let qr = divmod(a, b)

    check: truncate(qr.quot, int64) == -100'i64 div -13
    check: truncate(qr.rem, int64)  == -100'i64 mod -13

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
    let a = stint(1234567891234567890'i64, 64)
    let b = stint(10'i64, 64)

    let qr = divmod(a, b)

    let q = truncate(qr.quot, int64)
    let r = truncate(qr.rem, int64)

    check: q == 123456789123456789'i64
    check: r == 0'i64

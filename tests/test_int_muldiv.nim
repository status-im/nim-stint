# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/stint, unittest

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

  # test "Divmod(2^64, 3) returns the correct result":
  #   let a = 1.stint(128) shl 64
  #   let b = 3.stint(128)

  #   let qr = divmod(a, b)

  #   let q = cast[UintImpl[uint64]](qr.quot)
  #   let r = cast[UintImpl[uint64]](qr.rem)

  #   check: q.lo == 6148914691236517205'u64
  #   check: q.hi == 0'u64
  #   check: r.lo == 1'u64
  #   check: r.hi == 0'u64

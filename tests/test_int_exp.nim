# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, math, test_helpers

template chkPow(chk: untyped, a, b, c: string, bits: int) =
  chk pow(fromHex(StInt[bits], a), fromHex(StInt[bits], b)) == fromHex(StInt[bits], c)

template chkPow(chk: untyped, a: string, b: SomeInteger, c: string, bits: int) =
  chk pow(fromHex(StInt[bits], a), b) == fromHex(StInt[bits], c)

template testExp(chk, tst: untyped) =
  tst "signed BigInt BigInt Pow":
    chkPow(chk, "F", "2", "E1", 128)
    chkPow(chk, "FF", "2", "FE01", 128)
    chkPow(chk, "FF", "3", "FD02FF", 128)
    chkPow(chk, "FFF", "3", "FFD002FFF", 128)
    chkPow(chk, "FFFFF", "3", "ffffd00002fffff", 128)

    chk pow(-10.i128, 2.i128) == 100.i128
    chk pow(-10.i128, 3.i128) == -1000.i128

  tst "signed BigInt Natural Pow":
    chkPow(chk, "F", 2, "E1", 128)
    chkPow(chk, "FF", 2, "FE01", 128)
    chkPow(chk, "FF", 3, "FD02FF", 128)
    chkPow(chk, "FFF", 3, "FFD002FFF", 128)
    chkPow(chk, "FFFFF", 3, "ffffd00002fffff", 128)

    chk pow(-10.i128, 2) == 100.i128
    chk pow(-10.i128, 3) == -1000.i128

static:
  testExp(ctCheck, ctTest)

suite "Wider signed int exp coverage":
  testExp(check, test)

suite "Testing signed exponentiation":
  test "Simple exponentiation 5^3":

    let
      a = 5'u64
      b = 3
      u = a.stint(64)

    check:
      cast[uint64](u.pow(b)) == a ^ b
      cast[uint64](u.pow(b.stint(64))) == a ^ b

  test "12 ^ 34 == 4922235242952026704037113243122008064":
    # https://www.wolframalpha.com/input/?i=12+%5E+34
    let
      a = 12.stint(256)
      b = 34

    check: a.pow(b) == "4922235242952026704037113243122008064".i256
    check: a.pow(b.stint(256)) == "4922235242952026704037113243122008064".i256

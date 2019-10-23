# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, math, test_helpers

template chkPow(chk: untyped, a, b, c: string, bits: int) =
  chk pow(fromHex(Stuint[bits], a), fromHex(Stuint[bits], b)) == fromHex(Stuint[bits], c)

template chkPow(chk: untyped, a: string, b: SomeInteger, c: string, bits: int) =
  chk pow(fromHex(Stuint[bits], a), b) == fromHex(Stuint[bits], c)

template testExp(chk, tst: untyped) =
  tst "BigInt BigInt Pow":
    chkPow(chk, "F", "2", "E1", 8)

    chkPow(chk, "F", "2", "E1", 16)
    chkPow(chk, "FF", "2", "FE01", 16)

    chkPow(chk, "F", "2", "E1", 32)
    chkPow(chk, "FF", "2", "FE01", 32)
    chkPow(chk, "FF", "3", "FD02FF", 32)

    chkPow(chk, "F", "2", "E1", 64)
    chkPow(chk, "FF", "2", "FE01", 64)
    chkPow(chk, "FF", "3", "FD02FF", 64)
    chkPow(chk, "FFF", "3", "FFD002FFF", 64)

    chkPow(chk, "F", "2", "E1", 128)
    chkPow(chk, "FF", "2", "FE01", 128)
    chkPow(chk, "FF", "3", "FD02FF", 128)
    chkPow(chk, "FFF", "3", "FFD002FFF", 128)
    chkPow(chk, "FFFFF", "3", "ffffd00002fffff", 128)

  tst "BigInt Natural Pow":
    chkPow(chk, "F", 2, "E1", 8)

    chkPow(chk, "F", 2, "E1", 16)
    chkPow(chk, "FF", 2, "FE01", 16)

    chkPow(chk, "F", 2, "E1", 32)
    chkPow(chk, "FF", 2, "FE01", 32)
    chkPow(chk, "FF", 3, "FD02FF", 32)

    chkPow(chk, "F", 2, "E1", 64)
    chkPow(chk, "FF", 2, "FE01", 64)
    chkPow(chk, "FF", 3, "FD02FF", 64)
    chkPow(chk, "FFF", 3, "FFD002FFF", 64)

    chkPow(chk, "F", 2, "E1", 128)
    chkPow(chk, "FF", 2, "FE01", 128)
    chkPow(chk, "FF", 3, "FD02FF", 128)
    chkPow(chk, "FFF", 3, "FFD002FFF", 128)
    chkPow(chk, "FFFFF", 3, "ffffd00002fffff", 128)

static:
  testExp(ctCheck, ctTest)

suite "Wider unsigned int exp coverage":
  testExp(check, test)

suite "Testing unsigned exponentiation":
  test "Simple exponentiation 5^3":

    let
      a = 5'u64
      b = 3
      u = a.stuint(64)

    check:
      cast[uint64](u.pow(b)) == a ^ b
      cast[uint64](u.pow(b.stuint(64))) == a ^ b

  test "12 ^ 34 == 4922235242952026704037113243122008064":
    # https://www.wolframalpha.com/input/?i=12+%5E+34
    let
      a = 12.stuint(256)
      b = 34

    check: a.pow(b) == "4922235242952026704037113243122008064".u256
    check: a.pow(b.stuint(256)) == "4922235242952026704037113243122008064".u256

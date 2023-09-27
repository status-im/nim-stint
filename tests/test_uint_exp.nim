# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2, math

template chkPow(a, b, c: string, bits: int) =
  check pow(fromHex(StUint[bits], a), fromHex(StUint[bits], b)) == fromHex(StUint[bits], c)

template chkPow(a: string, b: SomeInteger, c: string, bits: int) =
  check pow(fromHex(StUint[bits], a), b) == fromHex(StUint[bits], c)

suite "Wider unsigned int exp coverage":
  test "BigInt BigInt Pow":
    chkPow("F", "2", "E1", 128)
    chkPow("FF", "2", "FE01", 128)
    chkPow("FF", "3", "FD02FF", 128)
    chkPow("FFF", "3", "FFD002FFF", 128)
    chkPow("FFFFF", "3", "ffffd00002fffff", 128)

  test "BigInt Natural Pow":
    chkPow("F", 2, "E1", 128)
    chkPow("FF", 2, "FE01", 128)
    chkPow("FF", 3, "FD02FF", 128)
    chkPow("FFF", 3, "FFD002FFF", 128)
    chkPow("FFFFF", 3, "ffffd00002fffff", 128)

suite "Testing unsigned exponentiation":
  test "Simple exponentiation 5^3":

    let
      a = 5'u64
      b = 3
      u = a.stuint(64)

    check:
      u.pow(b).truncate(uint64) == a ^ b
      u.pow(b.stuint(64)).truncate(uint64) == a ^ b

  test "12 ^ 34 == 4922235242952026704037113243122008064":
    # https://www.wolframalpha.com/input/?i=12+%5E+34
    let
      a = 12.stuint(256)
      b = 34

    check: a.pow(b) == "4922235242952026704037113243122008064".u256
    check: a.pow(b.stuint(256)) == "4922235242952026704037113243122008064".u256

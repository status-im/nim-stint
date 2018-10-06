# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, math

suite "Modular arithmetic":
  test "Modular addition":

    # uint16 rolls over at 65535
    let a = 50000'u16.stuint(16)
    let b = 20000'u16.stuint(16)
    let m = 60000'u16.stuint(16)

    check: addmod(a, b, m) == 10000'u16.stuint(16)

  test "Modular substraction":

    let a = 5'u16.stuint(16)
    let b = 7'u16.stuint(16)
    let m = 20'u16.stuint(16)

    check: submod(a, b, m) == 18'u16.stuint(16)

  test "Modular multiplication":
    # https://www.wolframalpha.com/input/?i=(1234567890+*+987654321)+mod+999999999
    # --> 345_679_002
    let a = 1234567890'u64.stuint(64)
    let b = 987654321'u64.stuint(64)
    let m = 999999999'u64.stuint(64)

    check: mulmod(a, b, m) == 345_679_002'u64.stuint(64)

  test "Modular exponentiation":
    # https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/fast-modular-exponentiation
    check:
      powmod(5'u16.stuint(16), 117'u16.stuint(16), 19'u16.stuint(16)) == 1'u16.stuint(16)
      powmod(3'u16.stuint(16), 1993'u16.stuint(16), 17'u16.stuint(16)) == 14'u16.stuint(16)

    check:
      powmod(12.stuint(256), 34.stuint(256), high(UInt256)) == "4922235242952026704037113243122008064".u256

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
    block: # https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/fast-modular-exponentiation
      check:
        powmod(5'u16.stuint(16), 117'u16.stuint(16), 19'u16.stuint(16)) == 1'u16.stuint(16)
        powmod(3'u16.stuint(16), 1993'u16.stuint(16), 17'u16.stuint(16)) == 14'u16.stuint(16)

      check:
        powmod(12.stuint(256), 34.stuint(256), high(UInt256)) == "4922235242952026704037113243122008064".u256

    block: # Little Fermat theorem
      # https://programmingpraxis.com/2014/08/08/big-modular-exponentiation/
      let P = "34534985349875439875439875349875".u256
      let Q = "93475349759384754395743975349573495".u256
      let M = 10.u256.pow(9) + 7 # 1000000007
      let expected = 735851262.u256

      check:
        powmod(P, Q, M) == expected

    block: # Little Fermat theorem
      # https://www.hackerrank.com/challenges/power-of-large-numbers/problem
      let P = "34543987529435983745230948023948".u256
      let Q = "3498573497543987543985743989120393097595572309482304".u256
      let M = 10.u256.pow(9) + 7 # 1000000007
      let expected = 985546465.u256

      check:
        powmod(P, Q, M) == expected

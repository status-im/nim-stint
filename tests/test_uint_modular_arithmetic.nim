# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template chkAddMod(a, b, m, c: string, bits: int) =
  check addmod(fromHex(StUint[bits], a), fromHex(StUint[bits], b),  fromHex(StUint[bits], m)) == fromHex(StUint[bits], c)

template chkSubMod(a, b, m, c: string, bits: int) =
  check submod(fromHex(StUint[bits], a), fromHex(StUint[bits], b),  fromHex(StUint[bits], m)) == fromHex(StUint[bits], c)

template chkMulMod(a, b, m, c: string, bits: int) =
  check mulmod(fromHex(StUint[bits], a), fromHex(StUint[bits], b),  fromHex(StUint[bits], m)) == fromHex(StUint[bits], c)

template chkPowMod(a, b, m, c: string, bits: int) =
  check powmod(fromHex(StUint[bits], a), fromHex(StUint[bits], b),  fromHex(StUint[bits], m)) == fromHex(StUint[bits], c)

suite "Wider unsigned Modular arithmetic coverage":
  test "addmod":
    chkAddMod("F", "F", "7", "2", 128)
    chkAddMod("AAAA", "AA", "F", "0", 128)
    chkAddMod("BBBB", "AAAA", "9", "3", 128)
    chkAddMod("BBBBBBBB", "AAAAAAAA", "9", "6", 128)
    chkAddMod("BBBBBBBBBBBBBBBB", "AAAAAAAAAAAAAAAA", "9", "3", 128)
    chkAddMod("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB", "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", "9", "6", 128)

  test "submod":
    chkSubMod("C", "3", "C", "9", 128)
    chkSubMod("1", "3", "C", "A", 128)
    chkSubMod("1", "FFFF", "C", "A", 128)
    chkSubMod("1", "FFFFFFFF", "C", "A", 128)
    chkSubMod("1", "FFFFFFFFFFFFFFFF", "C", "A", 128)
    chkSubMod("1", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "C", "A", 128)

  test "mulmod":
    chkMulMod("C", "3", "C", "0", 128)
    chkMulMod("1", "3", "C", "3", 128)
    chkMulMod("1", "FFFF", "C", "3", 128)
    chkMulMod("1", "FFFFFFFF", "C", "3", 128)
    chkMulMod("1", "FFFFFFFFFFFFFFFF", "C", "3", 128)
    chkMulMod("1", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "C", "3", 128)

  test "powmod":
    chkPowMod("C", "3", "C", "0", 128)
    chkPowMod("1", "3", "C", "1", 128)
    chkPowMod("1", "FF", "C", "1", 128)
    chkPowMod("FF", "3", "C", "3", 128)
    chkPowMod("FFFF", "3", "C", "3", 128)
    chkPowMod("FFFFFFFF", "3", "C", "3", 128)
    chkPowMod("FFFFFFFFFFFFFFFF", "3", "C", "3", 128)
    chkPowMod("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "3", "C", "3", 128)

suite "Modular arithmetic":
  test "Modular addition":

    # uint16 rolls over at 65535
    let a = 50000.u256
    let b = 20000.u256
    let m = 60000.u256

    check: addmod(a, b, m) == 10000.u256

  test "Modular substraction":

    let a = 5.u256
    let b = 7.u256
    let m = 20.u256

    check: submod(a, b, m) == 18.u256

  test "Modular multiplication":
    # https://www.wolframalpha.com/input/?i=(1234567890+*+987654321)+mod+999999999
    # --> 345_679_002
    let a = 1234567890.u256
    let b = 987654321.u256
    let m = 999999999.u256

    check: mulmod(a, b, m) == 345_679_002.u256

  test "Modular exponentiation":
    block: # https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/fast-modular-exponentiation
      check:
        powmod(5.u256, 117.u256, 19.u256) == 1.u256
        powmod(3.u256, 1993.u256, 17.u256) == 14.u256

      check:
        powmod(12.u256, 34.u256, high(UInt256)) == "4922235242952026704037113243122008064".u256

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

# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, math, test_helpers

template chkAddMod(chk: untyped, a, b, m, c: string, bits: int) =
  chk addmod(fromHex(StUint[bits], a), fromHex(StUint[bits], b),  fromHex(StUint[bits], m)) == fromHex(StUint[bits], c)

template chkSubMod(chk: untyped, a, b, m, c: string, bits: int) =
  chk submod(fromHex(StUint[bits], a), fromHex(StUint[bits], b),  fromHex(StUint[bits], m)) == fromHex(StUint[bits], c)

template chkMulMod(chk: untyped, a, b, m, c: string, bits: int) =
  chk mulmod(fromHex(StUint[bits], a), fromHex(StUint[bits], b),  fromHex(StUint[bits], m)) == fromHex(StUint[bits], c)

template chkPowMod(chk: untyped, a, b, m, c: string, bits: int) =
  chk powmod(fromHex(StUint[bits], a), fromHex(StUint[bits], b),  fromHex(StUint[bits], m)) == fromHex(StUint[bits], c)

template testModArith(chk, tst: untyped) =
  tst "addmod":
    chkAddMod(chk, "F", "F", "7", "2", 8)
    chkAddMod(chk, "AAAA", "AA", "F", "0", 16)
    chkAddMod(chk, "BBBB", "AAAA", "9", "3", 16)

    chkAddMod(chk, "F", "F", "7", "2", 32)
    chkAddMod(chk, "AAAA", "AA", "F", "0", 32)
    chkAddMod(chk, "BBBB", "AAAA", "9", "3", 32)
    chkAddMod(chk, "BBBBBBBB", "AAAAAAAA", "9", "6", 32)

    chkAddMod(chk, "F", "F", "7", "2", 64)
    chkAddMod(chk, "AAAA", "AA", "F", "0", 64)
    chkAddMod(chk, "BBBB", "AAAA", "9", "3", 64)
    chkAddMod(chk, "BBBBBBBB", "AAAAAAAA", "9", "6", 64)
    chkAddMod(chk, "BBBBBBBBBBBBBBBB", "AAAAAAAAAAAAAAAA", "9", "3", 64)

    chkAddMod(chk, "F", "F", "7", "2", 128)
    chkAddMod(chk, "AAAA", "AA", "F", "0", 128)
    chkAddMod(chk, "BBBB", "AAAA", "9", "3", 128)
    chkAddMod(chk, "BBBBBBBB", "AAAAAAAA", "9", "6", 128)
    chkAddMod(chk, "BBBBBBBBBBBBBBBB", "AAAAAAAAAAAAAAAA", "9", "3", 128)
    chkAddMod(chk, "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB", "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", "9", "6", 128)


  tst "submod":
    chkSubMod(chk, "C", "3", "C", "9", 8)
    chkSubMod(chk, "1", "3", "C", "A", 8)
    chkSubMod(chk, "1", "FF", "C", "A", 8)

    chkSubMod(chk, "C", "3", "C", "9", 16)
    chkSubMod(chk, "1", "3", "C", "A", 16)
    chkSubMod(chk, "1", "FFFF", "C", "A", 32)

    chkSubMod(chk, "C", "3", "C", "9", 32)
    chkSubMod(chk, "1", "3", "C", "A", 32)
    chkSubMod(chk, "1", "FFFF", "C", "A", 32)
    chkSubMod(chk, "1", "FFFFFFFF", "C", "A", 32)

    chkSubMod(chk, "C", "3", "C", "9", 64)
    chkSubMod(chk, "1", "3", "C", "A", 64)
    chkSubMod(chk, "1", "FFFF", "C", "A", 64)
    chkSubMod(chk, "1", "FFFFFFFF", "C", "A", 64)
    chkSubMod(chk, "1", "FFFFFFFFFFFFFFFF", "C", "A", 64)

    chkSubMod(chk, "C", "3", "C", "9", 128)
    chkSubMod(chk, "1", "3", "C", "A", 128)
    chkSubMod(chk, "1", "FFFF", "C", "A", 128)
    chkSubMod(chk, "1", "FFFFFFFF", "C", "A", 128)
    chkSubMod(chk, "1", "FFFFFFFFFFFFFFFF", "C", "A", 128)
    chkSubMod(chk, "1", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "C", "A", 128)

  tst "mulmod":
    chkMulMod(chk, "C", "3", "C", "0", 8)
    chkMulMod(chk, "1", "3", "C", "3", 8)
    chkMulMod(chk, "1", "FF", "C", "3", 8)

    chkMulMod(chk, "C", "3", "C", "0", 16)
    chkMulMod(chk, "1", "3", "C", "3", 16)
    chkMulMod(chk, "1", "FFFF", "C", "3", 16)

    chkMulMod(chk, "C", "3", "C", "0", 32)
    chkMulMod(chk, "1", "3", "C", "3", 32)
    chkMulMod(chk, "1", "FFFF", "C", "3", 32)
    chkMulMod(chk, "1", "FFFFFFFF", "C", "3", 32)

    chkMulMod(chk, "C", "3", "C", "0", 64)
    chkMulMod(chk, "1", "3", "C", "3", 64)
    chkMulMod(chk, "1", "FFFF", "C", "3", 64)
    chkMulMod(chk, "1", "FFFFFFFF", "C", "3", 64)
    chkMulMod(chk, "1", "FFFFFFFFFFFFFFFF", "C", "3", 64)

    chkMulMod(chk, "C", "3", "C", "0", 128)
    chkMulMod(chk, "1", "3", "C", "3", 128)
    chkMulMod(chk, "1", "FFFF", "C", "3", 128)
    chkMulMod(chk, "1", "FFFFFFFF", "C", "3", 128)
    chkMulMod(chk, "1", "FFFFFFFFFFFFFFFF", "C", "3", 128)
    chkMulMod(chk, "1", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "C", "3", 128)

  # TODO: bug #98
  when nimvm:
    # this ugly branch needed due to nim-lang/Nim#12518
    discard
  else:
    tst "powmod":
      chkPowMod(chk, "C", "3", "C", "0", 8)
      chkPowMod(chk, "1", "3", "C", "1", 8)
      chkPowMod(chk, "1", "FF", "C", "1", 8)
      chkPowMod(chk, "FF", "3", "C", "3", 8)

      chkPowMod(chk, "C", "3", "C", "0", 16)
      chkPowMod(chk, "1", "3", "C", "1", 16)
      chkPowMod(chk, "1", "FF", "C", "1", 16)
      chkPowMod(chk, "FF", "3", "C", "3", 16)
      chkPowMod(chk, "FFFF", "3", "C", "3", 16)

      chkPowMod(chk, "C", "3", "C", "0", 32)
      chkPowMod(chk, "1", "3", "C", "1", 32)
      chkPowMod(chk, "1", "FF", "C", "1", 32)
      chkPowMod(chk, "FF", "3", "C", "3", 32)
      chkPowMod(chk, "FFFF", "3", "C", "3", 32)
      chkPowMod(chk, "FFFFFFFF", "3", "C", "3", 32)

      chkPowMod(chk, "C", "3", "C", "0", 64)
      chkPowMod(chk, "1", "3", "C", "1", 64)
      chkPowMod(chk, "1", "FF", "C", "1", 64)
      chkPowMod(chk, "FF", "3", "C", "3", 64)
      chkPowMod(chk, "FFFF", "3", "C", "3", 64)
      chkPowMod(chk, "FFFFFFFF", "3", "C", "3", 64)
      chkPowMod(chk, "FFFFFFFFFFFFFFFF", "3", "C", "3", 64)

      chkPowMod(chk, "C", "3", "C", "0", 128)
      chkPowMod(chk, "1", "3", "C", "1", 128)
      chkPowMod(chk, "1", "FF", "C", "1", 128)
      chkPowMod(chk, "FF", "3", "C", "3", 128)
      chkPowMod(chk, "FFFF", "3", "C", "3", 128)
      chkPowMod(chk, "FFFFFFFF", "3", "C", "3", 128)
      chkPowMod(chk, "FFFFFFFFFFFFFFFF", "3", "C", "3", 128)
      chkPowMod(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "3", "C", "3", 128)

static:
  testModArith(ctCheck, ctTest)

suite "Wider unsigned Modular arithmetic coverage":
  testModArith(check, test)

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

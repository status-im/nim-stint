# Stint
# Copyright 2018-Present Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2, math

template chkAddMod(chk: untyped, a, b, m, c: string, bits: int) =
  check addmod(fromHex(StInt[bits], a), fromHex(StInt[bits], b),  fromHex(StInt[bits], m)) == fromHex(StInt[bits], c)

template chkMulMod(chk: untyped, a, b, m, c: string, bits: int) =
  check mulmod(fromHex(StInt[bits], a), fromHex(StInt[bits], b),  fromHex(StInt[bits], m)) == fromHex(StInt[bits], c)

template chkPowMod(chk: untyped, a, b, m, c: string, bits: int) =
  check powmod(fromHex(StInt[bits], a), fromHex(StInt[bits], b),  fromHex(StInt[bits], m)) == fromHex(StInt[bits], c)

suite "Wider unsigned Modular arithmetic coverage":
  test "addmod":
    chkAddMod(chk, "F", "F", "7", "2", 128)
    chkAddMod(chk, "AAAA", "AA", "F", "0", 128)
    chkAddMod(chk, "BBBB", "AAAA", "9", "3", 128)
    chkAddMod(chk, "BBBBBBBB", "AAAAAAAA", "9", "6", 128)
    chkAddMod(chk, "BBBBBBBBBBBBBBBB", "AAAAAAAAAAAAAAAA", "9", "3", 128)
    check addmod(-5.i128, -5.i128, 3.i128) == -1.i128
    check addmod(5.i128, -9.i128, 3.i128) == -1.i128
    check addmod(-5.i128, 9.i128, 3.i128) == 1.i128

  test "submod":
    check submod(10.i128, 5.i128, 3.i128) == 2.i128
    check submod(-6.i128, -5.i128, 3.i128) == -1.i128
    check submod(5.i128, -9.i128, 3.i128) == 2.i128
    check submod(-5.i128, 9.i128, 3.i128) == -2.i128

  test "mulmod":
    check mulmod(10.i128, 5.i128, 3.i128) == 2.i128
    check mulmod(-7.i128, -5.i128, 3.i128) == 2.i128
    check mulmod(6.i128, -9.i128, 4.i128) == -2.i128
    check mulmod(-5.i128, 7.i128, 3.i128) == -2.i128

  test "powmod":
    check powmod(10.i128, 5.i128, 3.i128) == 1.i128
    check powmod(-7.i128, 4.i128, 3.i128) == 1.i128
    check powmod(-7.i128, 3.i128, 3.i128) == -1.i128
    check powmod(5.i128,  9.i128, 3.i128) == 2.i128
    check powmod(-5.i128, 9.i128, 3.i128) == -2.i128

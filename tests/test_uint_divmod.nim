# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template chkDiv(a, b, c: string, bits: int) =
  check (fromHex(StUint[bits], a) div fromHex(StUint[bits], b)) == fromHex(StUint[bits], c)

template chkMod(a, b, c: string, bits: int) =
  check (fromHex(StUint[bits], a) mod fromHex(StUint[bits], b)) == fromHex(StUint[bits], c)

template chkDivMod(a, b, c, d: string, bits: int) =
  check divmod(fromHex(StUint[bits], a), fromHex(StUint[bits], b)) == (fromHex(StUint[bits], c), fromHex(StUint[bits], d))

suite "Wider unsigned int muldiv coverage":
  test "operator `div`":
    chkDiv("0", "3", "0", 128)
    chkDiv("1", "3", "0", 128)
    chkDiv("3", "3", "1", 128)
    chkDiv("3", "1", "3", 128)
    chkDiv("FF", "3", "55", 128)
    chkDiv("FFFF", "3", "5555", 128)
    chkDiv("FFFFFFFF", "3", "55555555", 128)
    chkDiv("FFFFFFFFFFFFFFFF", "3", "5555555555555555", 128)
    chkDiv("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "3", "55555555555555555555555555555555", 128)

  test "operator `mod`":
    chkMod("0", "3", "0", 128)
    chkMod("1", "3", "1", 128)
    chkMod("3", "3", "0", 128)
    chkMod("3", "1", "0", 128)
    chkMod("FF", "3", "0", 128)
    chkMod("FF", "4", "3", 128)
    chkMod("FFFF", "3", "0", 128)
    chkMod("FFFF", "17", "8", 128)
    chkMod("FFFFFFFF", "3", "0", 128)
    chkMod("FFFFFFFF", "23", "A", 128)
    chkMod("FFFFFFFF", "27", "15", 128)
    chkMod("FFFFFFFFFFFFFFFF", "27", "F", 128)
    chkMod("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "27", "15", 128)

  test "operator `divmod`":
    chkDivMod("0", "3", "0", "0", 128)
    chkDivMod("1", "3", "0", "1", 128)
    chkDivMod("3", "3", "1", "0", 128)
    chkDivMod("3", "1", "3", "0", 128)
    chkDivMod("FF", "3", "55", "0", 128)
    chkDivMod("FF", "4", "3F", "3", 128)
    chkDivMod("FFFF", "3", "5555", "0", 128)
    chkDivMod("FFFF", "17", "B21", "8", 128)
    chkDivMod("FFFFFFFF", "3", "55555555", "0", 128)
    chkDivMod("FFFFFFFF", "23", "7507507", "0A", 128)
    chkDivMod("FFFFFFFF", "27", "6906906", "15", 128)
    chkDivMod("FFFFFFFFFFFFFFFF", "27", "690690690690690", "F", 128)
    chkDivMod("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "27", "6906906906906906906906906906906", "15", 128)

suite "Testing unsigned int division and modulo implementation":
  test "Divmod(100, 13) returns the correct result":

    let a = 100.stuint(256)
    let b = 13.stuint(256)
    let qr = divmod(a, b)

    check qr.quot == 7'u64.u256
    check qr.rem  == 9'u64.u256

  test "Divmod(2^64, 3) returns the correct result":
     let a = 1.stuint(128) shl 64
     let b = 3.stuint(128)

     let qr = divmod(a, b)

     let q = qr.quot
     let r = qr.rem

     check:
        q == 6148914691236517205'u64.u128
        r == 1'u64.u128

  test "Divmod(1234567891234567890, 10) returns the correct result":
    let a = 1234567891234567890'u64.u256
    let b = 10'u64.u256

    let qr = divmod(a, b)

    let q = qr.quot
    let r = qr.rem

    check:
      q == 123456789123456789'u64.u256
      r == 0'u64.u256

suite "Testing specific failures highlighted by property-based testing":
  test "Modulo: 65696211516342324 mod 174261910798982":

    let u = 65696211516342324'u64
    let v = 174261910798982'u64

    let a = u.u256
    let b = v.u256

    let z = u mod v
    let tz = a mod b

    check z.u256 == tz

  test "Modulo: 15080397990160655 mod 600432699691":
    let u = 15080397990160655'u64
    let v = 600432699691'u64

    let a = u.u256
    let b = v.u256

    let z = u mod v
    let tz = a mod b

    check z.u256 == tz

  test "bug #133: SIGFPE":
    let a = "115792089237316195423570985008687907852908329466009024615882241056864671687049".u256
    let b = "15030568110056696491".u256
    let q = a div b
    let r = a mod b
    check q == "7703773296489151700480904010733627392011592199037677352760".u256
    let w = q * b + r
    check w == a


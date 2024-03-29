# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, stew/byteutils, test_helpers

template chkToBytesLE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  chk toBytes(x, littleEndian).toHex() == x.dumpHex(littleEndian)

template chkToBytesBE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  chk toBytes(x, bigEndian).toHex() == x.dumpHex(bigEndian)


template chkFromBytesBE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  let z = fromBytesBE(StUint[bits], toByteArrayBE(x))
  chk z == x

template chkFromBytesLE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  let z = fromBytesLE(StUint[bits], toByteArrayLE(x))
  chk z == x

template chkEndians(chkFunc, tst, name: untyped) =
  tst astToStr(name).substr(3):
    name(chkFunc, 64, "abcdef1234567890")
    name(chkFunc, 128, "abcdef1234567890abcdef1234567890")
    name(chkFunc, 256, "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890")

template testEndians(chkFunc, tst: untyped) =
  chkEndians(chkFunc, tst, chkToBytesLE)
  chkEndians(chkFunc, tst, chkToBytesBE)
  chkEndians(chkFunc, tst, chkFromBytesLE)
  chkEndians(chkFunc, tst, chkFromBytesBE)

static:
  testEndians(ctCheck, ctTest)

suite "Testing endians":
  test "Endians give sane results":

    check:
      1.u128.toByteArrayBE() ==
        [0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]

      1.u128.toByteArrayLE() ==
        [1'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

      1.u128 == UInt128.fromBytesBE(
        [0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1])

      1.u128 == UInt128.fromBytesLE(
        [1'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

  testEndians(check, test)

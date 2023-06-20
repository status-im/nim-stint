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
  let x = fromHex(StInt[bits], hex)
  chk toBytes(x, littleEndian).toHex() == x.dumpHex(littleEndian)

template chkToBytesBE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StInt[bits], hex)
  chk toBytes(x, bigEndian).toHex() == x.dumpHex(bigEndian)


template chkFromBytesBE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StInt[bits], hex)
  let z = fromBytesBE(StInt[bits], toByteArrayBE(x))
  chk z == x

template chkFromBytesLE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StInt[bits], hex)
  let z = fromBytesLE(StInt[bits], toByteArrayLE(x))
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
      1.i128.toByteArrayBE() ==
        [0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]

      1.i128.toByteArrayLE() ==
        [1'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

      1.i128 == Int128.fromBytesBE(
        [0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1])

      1.i128 == Int128.fromBytesLE(
        [1'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

      -1.i128.toByteArrayBE() ==
        [255'u8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]

      -2.i128.toByteArrayBE() ==
        [255'u8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254]

      -1.i128.toByteArrayLE() ==
        [255'u8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]

      -2.i128.toByteArrayLE() ==
        [254'u8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]

      -2.i128 == Int128.fromBytesBE(
        [255'u8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254])

      -2.i128 == Int128.fromBytesLE(
        [254'u8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255])

  testEndians(check, test)

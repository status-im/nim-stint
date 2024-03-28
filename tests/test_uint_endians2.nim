# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2, stew/byteutils

template chkToBytesLE(bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  check toBytes(x, littleEndian).toHex() == x.dumpHex(littleEndian)

template chkToBytesBE(bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  check toBytes(x, bigEndian).toHex() == x.dumpHex(bigEndian)

template chkFromBytesBE(bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  let z = fromBytesBE(StUint[bits], toByteArrayBE(x))
  check z == x

template chkFromBytesLE(bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  let z = fromBytesLE(StUint[bits], toByteArrayLE(x))
  check z == x

template chkEndians(name: untyped) =
  test astToStr(name).substr(3):
    name(64, "abcdef1234567890")
    name(128, "abcdef1234567890abcdef1234567890")
    name(256, "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890")

suite "Testing endians":
  chkEndians(chkToBytesLE)
  chkEndians(chkToBytesBE)
  chkEndians(chkFromBytesLE)
  chkEndians(chkFromBytesBE)

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

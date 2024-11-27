# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, ../stint/endians2, unittest2, stew/byteutils, std/algorithm

template chkToBytesLE(bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  check toBytes(x, littleEndian).toHex() == x.dumpHex(littleEndian)

template chkToBytesBE(bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  check toBytes(x, bigEndian).toHex() == x.dumpHex(bigEndian)

template chkFromBytesBE(bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)

  check:
    x.toBytesBE().toHex() == hex

  let z = fromBytesBE(StUint[bits], toBytesBE(x))
  check toHex(z) == hex

template chkFromBytesLE(bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)

  check:
    x.toBytesLE().toHex() == reversed(hexToSeqByte(hex)).toHex()

  let z = fromBytesLE(StUint[bits], toBytesLE(x))
  check toHex(z) == hex

template chkEndians(name: untyped) =
  test astToStr(name).substr(3):
    name(64, "abcdef1234567890")
    name(128, "abcdef1234567890abcdef1234567890")
    name(256, "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890")

    name(72, "a0a1a2a3a4a5a6a7a8")
    name(80, "a0a1a2a3a4a5a6a7a8a9")
    name(88, "a0a1a2a3a4a5a6a7a8a9aa")
    name(96, "a0a1a2a3a4a5a6a7a8a9aaab")
    name(104, "a0a1a2a3a4a5a6a7a8a9aaabac")

    name(264, "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890aa")

suite "Testing endians":
  chkEndians(chkToBytesLE)
  chkEndians(chkToBytesBE)
  chkEndians(chkFromBytesLE)
  chkEndians(chkFromBytesBE)

  test "Endians give sane results":
    check:
      1.u128.toBytesBE() ==
        [0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]

      1.u128.toBytesLE() ==
        [1'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

      1.u128 == UInt128.fromBytesBE(
        [0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1])

      1.u128 == UInt128.fromBytesLE(
        [1'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

      1.u128 == UInt128.fromBytesBE(
        [0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 42])

      1.u128 == UInt128.fromBytesLE(
        [1'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42])

      1.stuint(120) == StUint[120].fromBytesLE(
        [1'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42])


      # TOOD the tests below are not valid according to docs by encode de-facto
      #      usage in the wild

      1.stuint(128) == StUint[128].fromBytesLE([1'u8, 0, 0, 0, 0, 0, 0, 0])
      1.stuint(128) == StUint[128].fromBytesBE([0'u8, 0, 0, 0, 0, 0, 0, 0, 1])

      1.stuint(128) == StUint[128].fromBytesLE([1'u8])
      1.stuint(128) == StUint[128].fromBytesBE([1'u8])

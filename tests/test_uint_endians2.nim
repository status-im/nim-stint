# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, stew/byteutils, test_helpers


template chkSwapBytes(chk: untyped, bits: int, hex: string) =
  # dumpHex already do the job to swap the output if
  # we use `littleEndian` on both platform
  # bigEndian:    B to B, B to L, L to B
  # littleEndian: B to L, L to B, B to B
  chk swapBytes(fromHex(StUint[bits], hex)).dumpHex(littleEndian) == hex

template chkToBytes(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  chk toBytes(x).toHex() == x.dumpHex(system.cpuEndian)

template chkToBytesLE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  chk toBytes(x, littleEndian).toHex() == x.dumpHex(littleEndian)

template chkToBytesBE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  chk toBytes(x, bigEndian).toHex() == x.dumpHex(bigEndian)

template chkFromBytes(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  let z = fromBytes(StUint[bits], toBytes(x))
  chk z == x

template chkFromBytesBE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  let z = fromBytesBE(StUint[bits], toBytesBE(x))
  chk z == x

template chkFromBytesLE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  let z = fromBytesLE(StUint[bits], toBytesLE(x))
  chk z == x

template chkFromToLE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  let z = x.fromLE.toLE
  chk z == x

template chkFromToBE(chk: untyped, bits: int, hex: string) =
  let x = fromHex(StUint[bits], hex)
  let z = x.fromBE.toBE
  chk z == x

template chkEndians(chkFunc, tst, name: untyped) =
  tst astToStr(name).substr(3):
    name(chkFunc, 8, "ab")
    name(chkFunc, 16, "abcd")
    name(chkFunc, 32, "abcdef12")
    name(chkFunc, 64, "abcdef1234567890")
    name(chkFunc, 128, "abcdef1234567890abcdef1234567890")
    name(chkFunc, 256, "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890")

template testEndians(chkFunc, tst: untyped) =
  chkEndians(chkFunc, tst, chkSwapBytes)
  chkEndians(chkFunc, tst, chkToBytes)
  chkEndians(chkFunc, tst, chkToBytesLE)
  chkEndians(chkFunc, tst, chkToBytesBE)
  chkEndians(chkFunc, tst, chkFromBytes)
  chkEndians(chkFunc, tst, chkFromBytesLE)
  chkEndians(chkFunc, tst, chkFromBytesBE)
  chkEndians(chkFunc, tst, chkFromToLE)
  chkEndians(chkFunc, tst, chkFromToBE)

static:
  testEndians(ctCheck, ctTest)

suite "Testing endians":
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

  testEndians(check, test)

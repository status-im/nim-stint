# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template chkCountOnes(bits: int) =
  block:
    var x = 0.stuint(bits)
    check x.countOnes == 0

    for i in 1 .. bits:
      x = x shl 1
      x = x or 1.stuint(bits)
      check x.countOnes == i

template chkParity(bits: int) =
  block:
    var x = 0.stuint(bits)
    check x.parity == 0

    for i in 1 .. bits:
      x = x shl 1
      x = x or 1.stuint(bits)
      check x.parity == (i mod 2)

template chkFirstOne(bits: int) =
  block:
    var x = 0.stuint(bits)
    check x.firstOne == 0
    x = x + 1
    check x.firstOne == 1

    for i in 2 .. bits:
      x = x shl 1
      check x.firstOne == i

template chkLeadingZeros(bits: int) =
  block:
    var x = 0.stuint(bits)
    check x.leadingZeros == bits
    x = x + 1
    check x.leadingZeros == (bits-1)

    for i in 2 .. bits:
      x = x shl 1
      check x.leadingZeros == (bits-i)

template chkTrailingZeros(bits: int) =
  block:
    var x = 0.stuint(bits)
    check x.trailingZeros == bits
    x = x + 1
    check x.trailingZeros == 0

    for i in 1 .. bits:
      x = x shl 1
      check x.trailingZeros == i

suite "Testing bitops2":
  test "countOnes":
    check countOnes(0b01000100'u8.stuint(8)) == 2

    check countOnes(0b01000100'u8.stuint(16)) == 2
    check countOnes(0b01000100_01000100'u16.stuint(16)) == 4

    check countOnes(0b01000100'u8.stuint(32)) == 2
    check countOnes(0b01000100_01000100'u16.stuint(32)) == 4
    check countOnes(0b01000100_01000100_01000100_01000100'u32.stuint(32)) == 8

    check countOnes(0b01000100'u8.stuint(64)) == 2
    check countOnes(0b01000100_01000100'u16.stuint(64)) == 4
    check countOnes(0b01000100_01000100_01000100_01000100'u32.stuint(64)) == 8
    check countOnes(0b01000100_01000100_01000100_01000100_01000100_01000100_01000100_01000100'u64.stuint(64)) == 16

    check countOnes(0b01000100'u8.stuint(128)) == 2
    check countOnes(0b01000100_01000100'u16.stuint(128)) == 4
    check countOnes(0b01000100_01000100_01000100_01000100'u32.stuint(128)) == 8
    check countOnes(0b01000100_01000100_01000100_01000100_01000100_01000100_01000100_01000100'u64.stuint(128)) == 16
    check countOnes(0b01000100'u8.stuint(128) shl 100) == 2

    chkCountOnes(128)
    chkCountOnes(256)

  test "parity":
    check parity(0b00000001'u8.stuint(8)) == 1
    check parity(0b00000011'u8.stuint(8)) == 0

    check parity(0b00000001'u8.stuint(16)) == 1
    check parity(0b00000011'u8.stuint(16)) == 0
    check parity(0b00000001_00000001'u16.stuint(16)) == 0
    check parity(0b00000011_00000001'u16.stuint(16)) == 1

    check parity(0b00000001'u8.stuint(32)) == 1
    check parity(0b00000011'u8.stuint(32)) == 0
    check parity(0b00000001_00000001'u16.stuint(32)) == 0
    check parity(0b00000011_00000001'u16.stuint(32)) == 1
    check parity(0b00000001_00000001_00000001_00000001'u32.stuint(32)) == 0
    check parity(0b00000011_00000001_00000001_00000001'u32.stuint(32)) == 1

    check parity(0b00000001'u8.stuint(64)) == 1
    check parity(0b00000011'u8.stuint(64)) == 0
    check parity(0b00000001_00000001'u16.stuint(64)) == 0
    check parity(0b00000011_00000001'u16.stuint(64)) == 1
    check parity(0b00000001_00000001_00000001_00000001'u32.stuint(64)) == 0
    check parity(0b00000011_00000001_00000001_00000001'u32.stuint(64)) == 1
    check parity(0b00000001_00000001_00000001_00000001_00000001_00000001_00000001_00000001'u64.stuint(64)) == 0
    check parity(0b00000011_00000001_00000001_00000001_00000001_00000001_00000001_00000001'u64.stuint(64)) == 1

    check parity(0b00000001'u8.stuint(128)) == 1
    check parity(0b00000011'u8.stuint(128)) == 0
    check parity(0b00000001_00000001'u16.stuint(128)) == 0
    check parity(0b00000011_00000001'u16.stuint(128)) == 1
    check parity(0b00000001_00000001_00000001_00000001'u32.stuint(128)) == 0
    check parity(0b00000011_00000001_00000001_00000001'u32.stuint(128)) == 1
    check parity(0b00000001_00000001_00000001_00000001_00000001_00000001_00000001_00000001'u64.stuint(128)) == 0
    check parity(0b00000011_00000001_00000001_00000001_00000001_00000001_00000001_00000001'u64.stuint(128)) == 1

    check parity(0b00000001'u8.stuint(128)) == 1
    check parity(0b00000001'u8.stuint(128) shl 100) == 1

    chkParity(128)
    chkParity(256)

  test "firstOne":
    check firstOne(0b00000010'u8.stuint(8)) == 2

    check firstOne(0b00000010'u8.stuint(16)) == 2
    check firstOne(0b00000010_00000000'u16.stuint(16)) == 10

    check firstOne(0b00000010'u8.stuint(32)) == 2
    check firstOne(0b00000010_00000000'u16.stuint(32)) == 10
    check firstOne(0b00000010_00000000_00000000_00000000'u32.stuint(32)) == 26

    check firstOne(0b00000010'u8.stuint(64)) == 8*0+2
    check firstOne(0b00000010_00000000'u16.stuint(64)) == 8*1+2
    check firstOne(0b00000010_00000000_00000000_00000000'u32.stuint(64)) == 8*3+2
    check firstOne(0b00000010_00000000_00000000_00000000_00000000_00000000_00000000_00000000'u64.stuint(64)) == 8*7+2

    check firstOne(0b00000010'u8.stuint(128)) == 2
    check firstOne(0b00000010'u8.stuint(128) shl 100) == 102
    check firstOne(0'u8.stuint(128)) == 0

    chkFirstOne(128)
    chkFirstOne(256)

  test "leadingZeros":
    check leadingZeros(0'u8.stuint(8)) == 8*1
    check leadingZeros(0b00010000'u8.stuint(8)) == 3

    check leadingZeros(0'u8.stuint(16)) == 8*2
    check leadingZeros(0b00010000'u8.stuint(16)) == 8*1+3
    check leadingZeros(0'u16.stuint(16)) == 8*2
    check leadingZeros(0b00000000_00010000'u16.stuint(16)) == 8*1+3

    check leadingZeros(0'u8.stuint(32)) == 8*4
    check leadingZeros(0b00010000'u8.stuint(32)) == 8*3+3
    check leadingZeros(0'u16.stuint(32)) == 8*4
    check leadingZeros(0b00000000_00010000'u16.stuint(32)) == 8*3+3
    check leadingZeros(0'u32.stuint(32)) == 8*4
    check leadingZeros(0b00000000_00000000_00000000_00010000'u32.stuint(32)) == 8*3+3

    check leadingZeros(0'u8.stuint(64)) == 8*8
    check leadingZeros(0b00010000'u8.stuint(64)) == 8*7+3
    check leadingZeros(0'u16.stuint(64)) == 8*8
    check leadingZeros(0b00000000_00010000'u16.stuint(64)) == 8*7+3
    check leadingZeros(0'u32.stuint(64)) == 8*8
    check leadingZeros(0b00000000_00000000_00000000_00010000'u32.stuint(64)) == 8*7+3
    check leadingZeros(0'u64.stuint(64)) == 8*8
    check leadingZeros(0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00010000'u64.stuint(64)) == 8*7+3

    check leadingZeros(0'u8.stuint(128)) == 128
    check leadingZeros(0b00100000'u8.stuint(128)) == 128 - 6
    check leadingZeros(0b00100000'u8.stuint(128) shl 100) == 128 - 106

    chkLeadingZeros(128)
    chkLeadingZeros(256)

  test "trailingZeros":
    check trailingZeros(0'u8.stuint(8)) == 8*1
    check trailingZeros(0b00010000'u8.stuint(8)) == 4

    check trailingZeros(0'u8.stuint(16)) == 8*2
    check trailingZeros(0b00010000'u8.stuint(16)) == 8*0+4
    check trailingZeros(0'u16.stuint(16)) == 8*2
    check trailingZeros(0b00010000_00000000'u16.stuint(16)) == 8*1+4

    check trailingZeros(0'u8.stuint(32)) == 8*4
    check trailingZeros(0b00010000'u8.stuint(32)) == 8*0+4
    check trailingZeros(0'u16.stuint(32)) == 8*4
    check trailingZeros(0b00010000_00000000'u16.stuint(32)) == 8*1+4
    check trailingZeros(0'u32.stuint(32)) == 8*4
    check trailingZeros(0b00010000_00000000_00000000_00000000'u32.stuint(32)) == 8*3+4

    check trailingZeros(0'u8.stuint(64)) == 8*8
    check trailingZeros(0b00010000'u8.stuint(64)) == 8*0+4
    check trailingZeros(0'u16.stuint(64)) == 8*8
    check trailingZeros(0b00010000_00000000'u16.stuint(64)) == 8*1+4
    check trailingZeros(0'u32.stuint(64)) == 8*8
    check trailingZeros(0b00010000_00000000_00000000_00000000'u32.stuint(64)) == 8*3+4
    check trailingZeros(0'u64.stuint(64)) == 8*8
    check trailingZeros(0b00010000_00000000_00000000_00000000_00000000_00000000_00000000_00000000'u64.stuint(64)) == 8*7+4

    check trailingZeros(0b00100000'u8.stuint(128)) == 5
    check trailingZeros(0b00100000'u8.stuint(128) shl 100) == 105
    check trailingZeros(0'u8.stuint(128)) == 128

    chkTrailingZeros(128)
    chkTrailingZeros(256)

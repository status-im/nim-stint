# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, test_helpers

template chkCountOnes(chk: untyped, bits: int) =
  block:
    var x = 0.stuint(bits)
    chk x.countOnes == 0

    for i in 1 .. bits:
      x = x shl 1
      x = x or 1.stuint(bits)
      chk x.countOnes == i

template chkParity(chk: untyped, bits: int) =
  block:
    var x = 0.stuint(bits)
    chk x.parity == 0

    for i in 1 .. bits:
      x = x shl 1
      x = x or 1.stuint(bits)
      chk x.parity == (i mod 2)

template chkFirstOne(chk: untyped, bits: int) =
  block:
    var x = 0.stuint(bits)
    chk x.firstOne == 0
    x = x + 1
    chk x.firstOne == 1

    for i in 2 .. bits:
      x = x shl 1
      chk x.firstOne == i

template chkLeadingZeros(chk: untyped, bits: int) =
  block:
    var x = 0.stuint(bits)
    chk x.leadingZeros == bits
    x = x + 1
    chk x.leadingZeros == (bits-1)

    for i in 2 .. bits:
      x = x shl 1
      chk x.leadingZeros == (bits-i)

template chkTrailingZeros(chk: untyped, bits: int) =
  block:
    var x = 0.stuint(bits)
    chk x.trailingZeros == bits
    x = x + 1
    chk x.trailingZeros == 0

    for i in 1 .. bits:
      x = x shl 1
      chk x.trailingZeros == i

template testBitOps(chk, tst: untyped) =
  tst "countOnes":
    chk countOnes(0b01000100'u8.stuint(8)) == 2

    chk countOnes(0b01000100'u8.stuint(16)) == 2
    chk countOnes(0b01000100_01000100'u16.stuint(16)) == 4

    chk countOnes(0b01000100'u8.stuint(32)) == 2
    chk countOnes(0b01000100_01000100'u16.stuint(32)) == 4
    chk countOnes(0b01000100_01000100_01000100_01000100'u32.stuint(32)) == 8

    chk countOnes(0b01000100'u8.stuint(64)) == 2
    chk countOnes(0b01000100_01000100'u16.stuint(64)) == 4
    chk countOnes(0b01000100_01000100_01000100_01000100'u32.stuint(64)) == 8
    chk countOnes(0b01000100_01000100_01000100_01000100_01000100_01000100_01000100_01000100'u64.stuint(64)) == 16

    chk countOnes(0b01000100'u8.stuint(128)) == 2
    chk countOnes(0b01000100_01000100'u16.stuint(128)) == 4
    chk countOnes(0b01000100_01000100_01000100_01000100'u32.stuint(128)) == 8
    chk countOnes(0b01000100_01000100_01000100_01000100_01000100_01000100_01000100_01000100'u64.stuint(128)) == 16
    chk countOnes(0b01000100'u8.stuint(128) shl 100) == 2

    chkCountOnes(chk, 128)
    chkCountOnes(chk, 256)

  tst "parity":
    chk parity(0b00000001'u8.stuint(8)) == 1
    chk parity(0b00000011'u8.stuint(8)) == 0

    chk parity(0b00000001'u8.stuint(16)) == 1
    chk parity(0b00000011'u8.stuint(16)) == 0
    chk parity(0b00000001_00000001'u16.stuint(16)) == 0
    chk parity(0b00000011_00000001'u16.stuint(16)) == 1

    chk parity(0b00000001'u8.stuint(32)) == 1
    chk parity(0b00000011'u8.stuint(32)) == 0
    chk parity(0b00000001_00000001'u16.stuint(32)) == 0
    chk parity(0b00000011_00000001'u16.stuint(32)) == 1
    chk parity(0b00000001_00000001_00000001_00000001'u32.stuint(32)) == 0
    chk parity(0b00000011_00000001_00000001_00000001'u32.stuint(32)) == 1

    chk parity(0b00000001'u8.stuint(64)) == 1
    chk parity(0b00000011'u8.stuint(64)) == 0
    chk parity(0b00000001_00000001'u16.stuint(64)) == 0
    chk parity(0b00000011_00000001'u16.stuint(64)) == 1
    chk parity(0b00000001_00000001_00000001_00000001'u32.stuint(64)) == 0
    chk parity(0b00000011_00000001_00000001_00000001'u32.stuint(64)) == 1
    chk parity(0b00000001_00000001_00000001_00000001_00000001_00000001_00000001_00000001'u64.stuint(64)) == 0
    chk parity(0b00000011_00000001_00000001_00000001_00000001_00000001_00000001_00000001'u64.stuint(64)) == 1

    chk parity(0b00000001'u8.stuint(128)) == 1
    chk parity(0b00000011'u8.stuint(128)) == 0
    chk parity(0b00000001_00000001'u16.stuint(128)) == 0
    chk parity(0b00000011_00000001'u16.stuint(128)) == 1
    chk parity(0b00000001_00000001_00000001_00000001'u32.stuint(128)) == 0
    chk parity(0b00000011_00000001_00000001_00000001'u32.stuint(128)) == 1
    chk parity(0b00000001_00000001_00000001_00000001_00000001_00000001_00000001_00000001'u64.stuint(128)) == 0
    chk parity(0b00000011_00000001_00000001_00000001_00000001_00000001_00000001_00000001'u64.stuint(128)) == 1

    chk parity(0b00000001'u8.stuint(128)) == 1
    chk parity(0b00000001'u8.stuint(128) shl 100) == 1

    chkParity(chk, 128)
    chkParity(chk, 256)

  tst "firstOne":
    chk firstOne(0b00000010'u8.stuint(8)) == 2

    chk firstOne(0b00000010'u8.stuint(16)) == 2
    chk firstOne(0b00000010_00000000'u16.stuint(16)) == 10

    chk firstOne(0b00000010'u8.stuint(32)) == 2
    chk firstOne(0b00000010_00000000'u16.stuint(32)) == 10
    chk firstOne(0b00000010_00000000_00000000_00000000'u32.stuint(32)) == 26

    chk firstOne(0b00000010'u8.stuint(64)) == 8*0+2
    chk firstOne(0b00000010_00000000'u16.stuint(64)) == 8*1+2
    chk firstOne(0b00000010_00000000_00000000_00000000'u32.stuint(64)) == 8*3+2
    chk firstOne(0b00000010_00000000_00000000_00000000_00000000_00000000_00000000_00000000'u64.stuint(64)) == 8*7+2

    chk firstOne(0b00000010'u8.stuint(128)) == 2
    chk firstOne(0b00000010'u8.stuint(128) shl 100) == 102
    chk firstOne(0'u8.stuint(128)) == 0

    chkFirstOne(chk, 128)
    chkFirstOne(chk, 256)

  tst "leadingZeros":
    chk leadingZeros(0'u8.stuint(8)) == 8*1
    chk leadingZeros(0b00010000'u8.stuint(8)) == 3

    chk leadingZeros(0'u8.stuint(16)) == 8*2
    chk leadingZeros(0b00010000'u8.stuint(16)) == 8*1+3
    chk leadingZeros(0'u16.stuint(16)) == 8*2
    chk leadingZeros(0b00000000_00010000'u16.stuint(16)) == 8*1+3

    chk leadingZeros(0'u8.stuint(32)) == 8*4
    chk leadingZeros(0b00010000'u8.stuint(32)) == 8*3+3
    chk leadingZeros(0'u16.stuint(32)) == 8*4
    chk leadingZeros(0b00000000_00010000'u16.stuint(32)) == 8*3+3
    chk leadingZeros(0'u32.stuint(32)) == 8*4
    chk leadingZeros(0b00000000_00000000_00000000_00010000'u32.stuint(32)) == 8*3+3

    chk leadingZeros(0'u8.stuint(64)) == 8*8
    chk leadingZeros(0b00010000'u8.stuint(64)) == 8*7+3
    chk leadingZeros(0'u16.stuint(64)) == 8*8
    chk leadingZeros(0b00000000_00010000'u16.stuint(64)) == 8*7+3
    chk leadingZeros(0'u32.stuint(64)) == 8*8
    chk leadingZeros(0b00000000_00000000_00000000_00010000'u32.stuint(64)) == 8*7+3
    chk leadingZeros(0'u64.stuint(64)) == 8*8
    chk leadingZeros(0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00010000'u64.stuint(64)) == 8*7+3

    chk leadingZeros(0'u8.stuint(128)) == 128
    chk leadingZeros(0b00100000'u8.stuint(128)) == 128 - 6
    chk leadingZeros(0b00100000'u8.stuint(128) shl 100) == 128 - 106

    chkLeadingZeros(chk, 128)
    chkLeadingZeros(chk, 256)

  tst "trailingZeros":
    chk trailingZeros(0'u8.stuint(8)) == 8*1
    chk trailingZeros(0b00010000'u8.stuint(8)) == 4

    chk trailingZeros(0'u8.stuint(16)) == 8*2
    chk trailingZeros(0b00010000'u8.stuint(16)) == 8*0+4
    chk trailingZeros(0'u16.stuint(16)) == 8*2
    chk trailingZeros(0b00010000_00000000'u16.stuint(16)) == 8*1+4

    chk trailingZeros(0'u8.stuint(32)) == 8*4
    chk trailingZeros(0b00010000'u8.stuint(32)) == 8*0+4
    chk trailingZeros(0'u16.stuint(32)) == 8*4
    chk trailingZeros(0b00010000_00000000'u16.stuint(32)) == 8*1+4
    chk trailingZeros(0'u32.stuint(32)) == 8*4
    chk trailingZeros(0b00010000_00000000_00000000_00000000'u32.stuint(32)) == 8*3+4

    chk trailingZeros(0'u8.stuint(64)) == 8*8
    chk trailingZeros(0b00010000'u8.stuint(64)) == 8*0+4
    chk trailingZeros(0'u16.stuint(64)) == 8*8
    chk trailingZeros(0b00010000_00000000'u16.stuint(64)) == 8*1+4
    chk trailingZeros(0'u32.stuint(64)) == 8*8
    chk trailingZeros(0b00010000_00000000_00000000_00000000'u32.stuint(64)) == 8*3+4
    chk trailingZeros(0'u64.stuint(64)) == 8*8
    chk trailingZeros(0b00010000_00000000_00000000_00000000_00000000_00000000_00000000_00000000'u64.stuint(64)) == 8*7+4

    chk trailingZeros(0b00100000'u8.stuint(128)) == 5
    chk trailingZeros(0b00100000'u8.stuint(128) shl 100) == 105
    chk trailingZeros(0'u8.stuint(128)) == 128

    chkTrailingZeros(chk, 128)
    chkTrailingZeros(chk, 256)

static:
  testBitOps(ctCheck, ctTest)

suite "Testing bitops2":
  testBitOps(check, test)

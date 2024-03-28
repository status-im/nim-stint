# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template chkNot(a, b: string, bits: int) =
  check fromHex(StUint[bits], a).not() == fromHex(StUint[bits], b)

template chkOr(a, b, c: string, bits: int) =
  check (fromHex(StUint[bits], a) or fromHex(StUint[bits], b)) == fromHex(StUint[bits], c)

template chkAnd(a, b, c: string, bits: int) =
  check (fromHex(StUint[bits], a) and fromHex(StUint[bits], b)) == fromHex(StUint[bits], c)

template chkXor(a, b, c: string, bits: int) =
  check (fromHex(StUint[bits], a) xor fromHex(StUint[bits], b)) == fromHex(StUint[bits], c)

template chkShl(a: string, b: SomeInteger, c: string, bits: int) =
  check (fromHex(StUint[bits], a) shl b) == fromHex(StUint[bits], c)

template chkShr(a: string, b: SomeInteger, c: string, bits: int) =
  check (fromHex(StUint[bits], a) shr b) == fromHex(StUint[bits], c)

suite "Wider unsigned int bitwise coverage":

  # TODO: see issue #95
  #chkShl("0F", 8, "00", 8)
  #chkShl("0F", 16, "00", 16)
  #chkShl("0F", 32, "00", 32)
  #chkShl("0F", 64, "00", 64)
  #chkShl("0F", 128, "00", 128)
  #chkShl("0F", 256, "00", 256)
  #
  #chkShr("F0", 8, "00", 8)
  #chkShr("F000", 16, "00", 16)
  #chkShr("F0000000", 32, "00", 32)
  #chkShr("F000000000000000", 64, "00", 64)
  #chkShr("F0000000000000000000000000000000", 128, "00", 128)

  test "operator `not`":
    #[chkNot(0'u8, not 0'u8, 8)
    chkNot(high(uint8), not high(uint8), 8)
    chkNot("F0", "0F", 8)
    chkNot("0F", "F0", 8)

    chkNot(0'u8, not 0'u16, 16)
    chkNot(0'u16, not 0'u16, 16)
    chkNot(high(uint8), not uint16(high(uint8)), 16)
    chkNot(high(uint16), not high(uint16), 16)
    chkNot("F0", "FF0F", 16)
    chkNot("0F", "FFF0", 16)
    chkNot("FF00", "00FF", 16)
    chkNot("00FF", "FF00", 16)
    chkNot("0FF0", "F00F", 16)

    chkNot(0'u8, not 0'u32, 32)
    chkNot(0'u16, not 0'u32, 32)
    chkNot(0'u32, not 0'u32, 32)
    chkNot(high(uint8), not uint32(high(uint8)), 32)
    chkNot(high(uint16), not uint32(high(uint16)), 32)
    chkNot(high(uint32), not high(uint32), 32)
    chkNot("F0", "FFFFFF0F", 32)
    chkNot("0F", "FFFFFFF0", 32)
    chkNot("FF00", "FFFF00FF", 32)
    chkNot("00FF", "FFFFFF00", 32)
    chkNot("0000FFFF", "FFFF0000", 32)
    chkNot("00FFFF00", "FF0000FF", 32)
    chkNot("0F0F0F0F", "F0F0F0F0", 32)

    chkNot(0'u8, not 0'u64, 64)
    chkNot(0'u16, not 0'u64, 64)
    chkNot(0'u32, not 0'u64, 64)
    chkNot(0'u64, not 0'u64, 64)
    chkNot(high(uint8), not uint64(high(uint8)), 64)
    chkNot(high(uint16), not uint64(high(uint16)), 64)
    chkNot(high(uint32), not uint64(high(uint32)), 64)
    chkNot(high(uint64), not high(uint64), 64)]#

    chkNot("0", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNot("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "0", 128)
    chkNot("F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0", "0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F", 128)
    chkNot("FFFFFFFFFFFF00000000000000000000", "000000000000FFFFFFFFFFFFFFFFFFFF", 128)

  test "operator `or`":
    #[chkOr("00", "FF", "FF", 8)
    chkOr("FF", "00", "FF", 8)
    chkOr("F0", "0F", "FF", 8)
    chkOr("00", "00", "00", 8)

    chkOr("00", "FF", "00FF", 16)
    chkOr("FF", "00", "00FF", 16)
    chkOr("F0", "0F", "00FF", 16)
    chkOr("00", "00", "0000", 16)
    chkOr("FF00", "0F00", "FF00", 16)

    chkOr("00", "FF", "000000FF", 32)
    chkOr("FF", "00", "000000FF", 32)
    chkOr("F0", "0F", "000000FF", 32)
    chkOr("00", "00", "00000000", 32)
    chkOr("FF00", "0F00", "0000FF00", 32)
    chkOr("00FF00FF", "000F000F", "00FF00FF", 32)

    chkOr("00", "FF", "00000000000000FF", 64)
    chkOr("FF", "00", "00000000000000FF", 64)
    chkOr("F0", "0F", "00000000000000FF", 64)
    chkOr("00", "00", "0000000000000000", 64)
    chkOr("FF00", "0F00", "000000000000FF00", 64)
    chkOr("00FF00FF", "000F000F", "0000000000FF00FF", 64)]#

    chkOr("00", "FF", "000000000000000000000000000000FF", 128)
    chkOr("FF", "00", "000000000000000000000000000000FF", 128)
    chkOr("F0", "0F", "000000000000000000000000000000FF", 128)
    chkOr("00", "00", "00000000000000000000000000000000", 128)
    chkOr("FF00", "0F00", "0000000000000000000000000000FF00", 128)
    chkOr("00FF00FF", "000F000F", "00000000000000000000000000FF00FF", 128)
    chkOr("00000000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", 128)

  test "operator `and`":
    #[chkAnd("00", "FF", "00", 8)
    chkAnd("FF", "00", "00", 8)
    chkAnd("F0", "0F", "00", 8)
    chkAnd("00", "00", "00", 8)
    chkAnd("0F", "0F", "0F", 8)
    chkAnd("FF", "FF", "FF", 8)

    chkAnd("00", "FF", "0000", 16)
    chkAnd("FF", "00", "0000", 16)
    chkAnd("F0", "0F", "0000", 16)
    chkAnd("00", "00", "0000", 16)
    chkAnd("FF00", "0F00", "0F00", 16)

    chkAnd("00", "FF", "00000000", 32)
    chkAnd("FF", "00", "00000000", 32)
    chkAnd("F0", "0F", "00000000", 32)
    chkAnd("00", "00", "00000000", 32)
    chkAnd("FF00", "0F00", "00000F00", 32)
    chkAnd("00FF00FF", "000F000F", "000F000F", 32)

    chkAnd("00", "FF", "0000000000000000", 64)
    chkAnd("FF", "00", "0000000000000000", 64)
    chkAnd("F0", "0F", "0000000000000000", 64)
    chkAnd("00", "00", "0000000000000000", 64)
    chkAnd("FF00", "0F00", "0000000000000F00", 64)
    chkAnd("00FF00FF", "000F000F", "00000000000F000F", 64)]#

    chkAnd("00", "FF", "00000000000000000000000000000000", 128)
    chkAnd("FF", "00", "00000000000000000000000000000000", 128)
    chkAnd("F0", "0F", "00000000000000000000000000000000", 128)
    chkAnd("00", "00", "00000000000000000000000000000000", 128)
    chkAnd("FF00", "0F00", "00000000000000000000000000000F00", 128)
    chkAnd("00FF00FF", "000F000F", "000000000000000000000000000F000F", 128)
    chkAnd("F0000000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", "F0000000000000000000000000FF00FF", 128)

  test "operator `xor`":
    #[chkXor("00", "FF", "FF", 8)
    chkXor("FF", "00", "FF", 8)
    chkXor("F0", "0F", "FF", 8)
    chkXor("00", "00", "00", 8)
    chkXor("0F", "0F", "00", 8)
    chkXor("FF", "FF", "00", 8)

    chkXor("00", "FF", "00FF", 16)
    chkXor("FF", "00", "00FF", 16)
    chkXor("F0", "0F", "00FF", 16)
    chkXor("00", "00", "0000", 16)
    chkXor("FF00", "0F00", "F000", 16)

    chkXor("00", "FF", "000000FF", 32)
    chkXor("FF", "00", "000000FF", 32)
    chkXor("F0", "0F", "000000FF", 32)
    chkXor("00", "00", "00000000", 32)
    chkXor("FF00", "0F00", "0000F000", 32)
    chkXor("00FF00FF", "000F000F", "00F000F0", 32)

    chkXor("00", "FF", "00000000000000FF", 64)
    chkXor("FF", "00", "00000000000000FF", 64)
    chkXor("F0", "0F", "00000000000000FF", 64)
    chkXor("00", "00", "0000000000000000", 64)
    chkXor("FF00", "0F00", "000000000000F000", 64)
    chkXor("00FF00FF", "000F000F", "0000000000F000F0", 64)]#

    chkXor("00", "FF", "000000000000000000000000000000FF", 128)
    chkXor("FF", "00", "000000000000000000000000000000FF", 128)
    chkXor("F0", "0F", "000000000000000000000000000000FF", 128)
    chkXor("00", "00", "00000000000000000000000000000000", 128)
    chkXor("FF00", "0F00", "0000000000000000000000000000F000", 128)
    chkXor("00FF00FF", "000F000F", "00000000000000000000000000F000F0", 128)
    chkXor("F0000000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", "0F0F0000000000000000000000000000", 128)

  test "operator `shl`":
    #[chkShl("0F", 4, "F0", 8)
    chkShl("F0", 4, "00", 8)
    chkShl("F0", 3, "80", 8)
    chkShl("0F", 7, "80", 8)

    chkShl("0F", 4, "F0", 16)
    chkShl("F0", 4, "F00", 16)
    chkShl("F0", 3, "780", 16)
    chkShl("F000", 3, "8000", 16)
    chkShl("0F", 15, "8000", 16)

    chkShl("0F", 4, "F0", 32)
    chkShl("F0", 4, "F00", 32)
    chkShl("F0", 3, "780", 32)
    chkShl("F000", 3, "78000", 32)
    chkShl("F0000000", 3, "80000000", 32)
    chkShl("0F", 31, "80000000", 32)

    chkShl("0F", 4, "F0", 64)
    chkShl("F0", 4, "F00", 64)
    chkShl("F0", 3, "780", 64)
    chkShl("F000", 3, "78000", 64)
    chkShl("F0000000", 3, "780000000", 64)
    chkShl("F000000000000000", 3, "8000000000000000", 64)
    chkShl("0F", 63, "8000000000000000", 64)

    chkShl("0F", 5, "1E0", 64)
    chkShl("0F", 9, "1E00", 64)
    chkShl("0F", 17, "1E0000", 64)
    chkShl("0F", 33, "1E00000000", 64)]#

    chkShl("0F", 4, "F0", 128)
    chkShl("F0", 4, "F00", 128)
    chkShl("F0", 3, "780", 128)
    chkShl("F000", 3, "78000", 128)
    chkShl("F0000000", 3, "780000000", 128)
    chkShl("F000000000000000", 3, "78000000000000000", 128)
    chkShl("F0000000000000000000000000000000", 3, "80000000000000000000000000000000", 128)

    chkShl("0F", 33, "1E00000000", 128)
    chkShl("0F", 65, "1E0000000000000000", 128)
    chkShl("0F", 97, "1E000000000000000000000000", 128)
    chkShl("0F", 127, "80000000000000000000000000000000", 128)

    chkShl("0F", 4, "F0", 256)
    chkShl("F0", 4, "F00", 256)
    chkShl("F0", 3, "780", 256)
    chkShl("F000", 3, "78000", 256)
    chkShl("F0000000", 3, "780000000", 256)
    chkShl("F000000000000000", 3, "78000000000000000", 256)
    chkShl("F0000000000000000000000000000000", 3, "780000000000000000000000000000000", 256)

    chkShl("0F", 33, "1E00000000", 256)
    chkShl("0F", 65, "1E0000000000000000", 256)
    chkShl("0F", 97, "1E000000000000000000000000", 256)
    chkShl("0F", 128, "0F00000000000000000000000000000000", 256)
    chkShl("0F", 129, "1E00000000000000000000000000000000", 256)
    chkShl("0F", 255, "8000000000000000000000000000000000000000000000000000000000000000", 256)

  test "operator `shr`":
    #[chkShr("0F", 4, "00", 8)
    chkShr("F0", 4, "0F", 8)
    chkShr("F0", 3, "1E", 8)
    chkShr("F0", 7, "01", 8)

    chkShr("0F", 4, "00", 16)
    chkShr("F0", 4, "0F", 16)
    chkShr("F000", 3, "1E00", 16)
    chkShr("F000", 15, "0001", 16)

    chkShr("0F", 4, "00", 32)
    chkShr("F0", 4, "0F", 32)
    chkShr("F0", 3, "1E", 32)
    chkShr("F0000000", 3, "1E000000", 32)
    chkShr("F0000000", 31, "00000001", 32)

    chkShr("0F", 4, "00", 64)
    chkShr("F0", 4, "0F", 64)
    chkShr("F0", 3, "1E", 64)
    chkShr("F000", 3, "1E00", 64)
    chkShr("F0000000", 3, "1E000000", 64)
    chkShr("F000000000000000", 63, "0000000000000001", 64)]#

    chkShr("0F", 4, "00", 128)
    chkShr("F0", 4, "0F", 128)
    chkShr("F0", 3, "1E", 128)
    chkShr("F000", 3, "1E00", 128)
    chkShr("F0000000", 3, "1E000000", 128)
    chkShr("F000000000000000", 3, "1E00000000000000", 128)
    chkShr("F0000000000000000000000000000000", 127, "00000000000000000000000000000001", 128)

    chkShr("F0000000000000000000000000000000", 33, "00000000780000000000000000000000", 128)
    chkShr("F0000000000000000000000000000000", 65, "00000000000000007800000000000000", 128)
    chkShr("F0000000000000000000000000000000", 97, "00000000000000000000000078000000", 128)

    chkShr("0F", 4, "00", 256)
    chkShr("F0", 4, "0F", 256)
    chkShr("F0", 3, "1E", 256)
    chkShr("F000", 3, "1E00", 256)
    chkShr("F0000000", 3, "1E000000", 256)
    chkShr("F000000000000000", 3, "1E00000000000000", 256)
    chkShr("F000000000000000000000000000000000000000000000000000000000000000", 255, "1", 256)

    chkShr("F000000000000000000000000000000000000000000000000000000000000000", 33, "0000000078000000000000000000000000000000000000000000000000000000", 256)
    chkShr("F000000000000000000000000000000000000000000000000000000000000000", 65, "0000000000000000780000000000000000000000000000000000000000000000", 256)
    chkShr("F000000000000000000000000000000000000000000000000000000000000000", 129, "0000000000000000000000000000000078000000000000000000000000000000", 256)
    chkShr("F000000000000000000000000000000000000000000000000000000000000000", 233, "780000", 256)

#[
suite "Testing unsigned int bitwise operations":
  let a = 100'i16.stuint(16)

  let b = a * a
  let z = 10000'u16
  doAssert cast[uint16](b) == z, "Test cannot proceed, something is wrong with the multiplication implementation"


  let u = 10000.stuint(64)
  let v = 10000'u64
  let clz = 30

  test "Shift left - by less than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shl 2) == z shl 2

  test "Shift left - by more than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shl 10) == z shl 10

    check: cast[uint64](u shl clz) == v shl clz

  test "Shift left - by half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shl 8) == z shl 8

  test "Shift right - by less than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 2) == z shr 2

  test "Shift right - by more than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 10) == z shr 10

  test "Shift right - by half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 8) == z shr 8
]#
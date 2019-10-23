# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, test_helpers

template chkNot(chk: untyped, a, b: distinct SomeInteger, bits: int) =
  chk stuint(a, bits).not() == stuint(b, bits)

template chkNot(chk: untyped, a, b: string, bits: int) =
  chk fromHex(Stuint[bits], a).not() == fromHex(Stuint[bits], b)

template chkOr(chk: untyped, a, b, c: string, bits: int) =
  chk (fromHex(Stuint[bits], a) or fromHex(Stuint[bits], b)) == fromHex(Stuint[bits], c)

template chkAnd(chk: untyped, a, b, c: string, bits: int) =
  chk (fromHex(Stuint[bits], a) and fromHex(Stuint[bits], b)) == fromHex(Stuint[bits], c)

template chkXor(chk: untyped, a, b, c: string, bits: int) =
  chk (fromHex(Stuint[bits], a) xor fromHex(Stuint[bits], b)) == fromHex(Stuint[bits], c)

template chkShl(chk: untyped, a: string, b: SomeInteger, c: string, bits: int) =
  chk (fromHex(Stuint[bits], a) shl b) == fromHex(Stuint[bits], c)

template chkShr(chk: untyped, a: string, b: SomeInteger, c: string, bits: int) =
  chk (fromHex(Stuint[bits], a) shr b) == fromHex(Stuint[bits], c)

template testBitwise(chk, tst: untyped) =

  # TODO: see issue #95
  #chkShl(chk, "0F", 8, "00", 8)
  #chkShl(chk, "0F", 16, "00", 16)
  #chkShl(chk, "0F", 32, "00", 32)
  #chkShl(chk, "0F", 64, "00", 64)
  #chkShl(chk, "0F", 128, "00", 128)
  #chkShl(chk, "0F", 256, "00", 256)
  #
  #chkShr(chk, "F0", 8, "00", 8)
  #chkShr(chk, "F000", 16, "00", 16)
  #chkShr(chk, "F0000000", 32, "00", 32)
  #chkShr(chk, "F000000000000000", 64, "00", 64)
  #chkShr(chk, "F0000000000000000000000000000000", 128, "00", 128)

  tst "operator `not`":
    chkNot(chk, 0'u8, not 0'u8, 8)
    chkNot(chk, high(uint8), not high(uint8), 8)
    chkNot(chk, "F0", "0F", 8)
    chkNot(chk, "0F", "F0", 8)

    chkNot(chk, 0'u8, not 0'u16, 16)
    chkNot(chk, 0'u16, not 0'u16, 16)
    chkNot(chk, high(uint8), not uint16(high(uint8)), 16)
    chkNot(chk, high(uint16), not high(uint16), 16)
    chkNot(chk, "F0", "FF0F", 16)
    chkNot(chk, "0F", "FFF0", 16)
    chkNot(chk, "FF00", "00FF", 16)
    chkNot(chk, "00FF", "FF00", 16)
    chkNot(chk, "0FF0", "F00F", 16)

    chkNot(chk, 0'u8, not 0'u32, 32)
    chkNot(chk, 0'u16, not 0'u32, 32)
    chkNot(chk, 0'u32, not 0'u32, 32)
    chkNot(chk, high(uint8), not uint32(high(uint8)), 32)
    chkNot(chk, high(uint16), not uint32(high(uint16)), 32)
    chkNot(chk, high(uint32), not high(uint32), 32)
    chkNot(chk, "F0", "FFFFFF0F", 32)
    chkNot(chk, "0F", "FFFFFFF0", 32)
    chkNot(chk, "FF00", "FFFF00FF", 32)
    chkNot(chk, "00FF", "FFFFFF00", 32)
    chkNot(chk, "0000FFFF", "FFFF0000", 32)
    chkNot(chk, "00FFFF00", "FF0000FF", 32)
    chkNot(chk, "0F0F0F0F", "F0F0F0F0", 32)

    chkNot(chk, 0'u8, not 0'u64, 64)
    chkNot(chk, 0'u16, not 0'u64, 64)
    chkNot(chk, 0'u32, not 0'u64, 64)
    chkNot(chk, 0'u64, not 0'u64, 64)
    chkNot(chk, high(uint8), not uint64(high(uint8)), 64)
    chkNot(chk, high(uint16), not uint64(high(uint16)), 64)
    chkNot(chk, high(uint32), not uint64(high(uint32)), 64)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkNot(chk, high(uint64), not high(uint64), 64)

    chkNot(chk, "0", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNot(chk, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "0", 128)
    chkNot(chk, "F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0", "0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F", 128)
    chkNot(chk, "FFFFFFFFFFFF00000000000000000000", "000000000000FFFFFFFFFFFFFFFFFFFF", 128)

  tst "operator `or`":
    chkOr(chk, "00", "FF", "FF", 8)
    chkOr(chk, "FF", "00", "FF", 8)
    chkOr(chk, "F0", "0F", "FF", 8)
    chkOr(chk, "00", "00", "00", 8)

    chkOr(chk, "00", "FF", "00FF", 16)
    chkOr(chk, "FF", "00", "00FF", 16)
    chkOr(chk, "F0", "0F", "00FF", 16)
    chkOr(chk, "00", "00", "0000", 16)
    chkOr(chk, "FF00", "0F00", "FF00", 16)

    chkOr(chk, "00", "FF", "000000FF", 32)
    chkOr(chk, "FF", "00", "000000FF", 32)
    chkOr(chk, "F0", "0F", "000000FF", 32)
    chkOr(chk, "00", "00", "00000000", 32)
    chkOr(chk, "FF00", "0F00", "0000FF00", 32)
    chkOr(chk, "00FF00FF", "000F000F", "00FF00FF", 32)

    chkOr(chk, "00", "FF", "00000000000000FF", 64)
    chkOr(chk, "FF", "00", "00000000000000FF", 64)
    chkOr(chk, "F0", "0F", "00000000000000FF", 64)
    chkOr(chk, "00", "00", "0000000000000000", 64)
    chkOr(chk, "FF00", "0F00", "000000000000FF00", 64)
    chkOr(chk, "00FF00FF", "000F000F", "0000000000FF00FF", 64)

    chkOr(chk, "00", "FF", "000000000000000000000000000000FF", 128)
    chkOr(chk, "FF", "00", "000000000000000000000000000000FF", 128)
    chkOr(chk, "F0", "0F", "000000000000000000000000000000FF", 128)
    chkOr(chk, "00", "00", "00000000000000000000000000000000", 128)
    chkOr(chk, "FF00", "0F00", "0000000000000000000000000000FF00", 128)
    chkOr(chk, "00FF00FF", "000F000F", "00000000000000000000000000FF00FF", 128)
    chkOr(chk, "00000000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", 128)

  tst "operator `and`":
    chkAnd(chk, "00", "FF", "00", 8)
    chkAnd(chk, "FF", "00", "00", 8)
    chkAnd(chk, "F0", "0F", "00", 8)
    chkAnd(chk, "00", "00", "00", 8)
    chkAnd(chk, "0F", "0F", "0F", 8)
    chkAnd(chk, "FF", "FF", "FF", 8)

    chkAnd(chk, "00", "FF", "0000", 16)
    chkAnd(chk, "FF", "00", "0000", 16)
    chkAnd(chk, "F0", "0F", "0000", 16)
    chkAnd(chk, "00", "00", "0000", 16)
    chkAnd(chk, "FF00", "0F00", "0F00", 16)

    chkAnd(chk, "00", "FF", "00000000", 32)
    chkAnd(chk, "FF", "00", "00000000", 32)
    chkAnd(chk, "F0", "0F", "00000000", 32)
    chkAnd(chk, "00", "00", "00000000", 32)
    chkAnd(chk, "FF00", "0F00", "00000F00", 32)
    chkAnd(chk, "00FF00FF", "000F000F", "000F000F", 32)

    chkAnd(chk, "00", "FF", "0000000000000000", 64)
    chkAnd(chk, "FF", "00", "0000000000000000", 64)
    chkAnd(chk, "F0", "0F", "0000000000000000", 64)
    chkAnd(chk, "00", "00", "0000000000000000", 64)
    chkAnd(chk, "FF00", "0F00", "0000000000000F00", 64)
    chkAnd(chk, "00FF00FF", "000F000F", "00000000000F000F", 64)

    chkAnd(chk, "00", "FF", "00000000000000000000000000000000", 128)
    chkAnd(chk, "FF", "00", "00000000000000000000000000000000", 128)
    chkAnd(chk, "F0", "0F", "00000000000000000000000000000000", 128)
    chkAnd(chk, "00", "00", "00000000000000000000000000000000", 128)
    chkAnd(chk, "FF00", "0F00", "00000000000000000000000000000F00", 128)
    chkAnd(chk, "00FF00FF", "000F000F", "000000000000000000000000000F000F", 128)
    chkAnd(chk, "F0000000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", "F0000000000000000000000000FF00FF", 128)

  tst "operator `xor`":
    chkXor(chk, "00", "FF", "FF", 8)
    chkXor(chk, "FF", "00", "FF", 8)
    chkXor(chk, "F0", "0F", "FF", 8)
    chkXor(chk, "00", "00", "00", 8)
    chkXor(chk, "0F", "0F", "00", 8)
    chkXor(chk, "FF", "FF", "00", 8)

    chkXor(chk, "00", "FF", "00FF", 16)
    chkXor(chk, "FF", "00", "00FF", 16)
    chkXor(chk, "F0", "0F", "00FF", 16)
    chkXor(chk, "00", "00", "0000", 16)
    chkXor(chk, "FF00", "0F00", "F000", 16)

    chkXor(chk, "00", "FF", "000000FF", 32)
    chkXor(chk, "FF", "00", "000000FF", 32)
    chkXor(chk, "F0", "0F", "000000FF", 32)
    chkXor(chk, "00", "00", "00000000", 32)
    chkXor(chk, "FF00", "0F00", "0000F000", 32)
    chkXor(chk, "00FF00FF", "000F000F", "00F000F0", 32)

    chkXor(chk, "00", "FF", "00000000000000FF", 64)
    chkXor(chk, "FF", "00", "00000000000000FF", 64)
    chkXor(chk, "F0", "0F", "00000000000000FF", 64)
    chkXor(chk, "00", "00", "0000000000000000", 64)
    chkXor(chk, "FF00", "0F00", "000000000000F000", 64)
    chkXor(chk, "00FF00FF", "000F000F", "0000000000F000F0", 64)

    chkXor(chk, "00", "FF", "000000000000000000000000000000FF", 128)
    chkXor(chk, "FF", "00", "000000000000000000000000000000FF", 128)
    chkXor(chk, "F0", "0F", "000000000000000000000000000000FF", 128)
    chkXor(chk, "00", "00", "00000000000000000000000000000000", 128)
    chkXor(chk, "FF00", "0F00", "0000000000000000000000000000F000", 128)
    chkXor(chk, "00FF00FF", "000F000F", "00000000000000000000000000F000F0", 128)
    chkXor(chk, "F0000000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", "0F0F0000000000000000000000000000", 128)

  tst "operator `shl`":
    chkShl(chk, "0F", 4, "F0", 8)
    chkShl(chk, "F0", 4, "00", 8)
    chkShl(chk, "F0", 3, "80", 8)
    chkShl(chk, "0F", 7, "80", 8)

    chkShl(chk, "0F", 4, "F0", 16)
    chkShl(chk, "F0", 4, "F00", 16)
    chkShl(chk, "F0", 3, "780", 16)
    chkShl(chk, "F000", 3, "8000", 16)
    chkShl(chk, "0F", 15, "8000", 16)

    chkShl(chk, "0F", 4, "F0", 32)
    chkShl(chk, "F0", 4, "F00", 32)
    chkShl(chk, "F0", 3, "780", 32)
    chkShl(chk, "F000", 3, "78000", 32)
    chkShl(chk, "F0000000", 3, "80000000", 32)
    chkShl(chk, "0F", 31, "80000000", 32)

    chkShl(chk, "0F", 4, "F0", 64)
    chkShl(chk, "F0", 4, "F00", 64)
    chkShl(chk, "F0", 3, "780", 64)
    chkShl(chk, "F000", 3, "78000", 64)
    chkShl(chk, "F0000000", 3, "780000000", 64)
    chkShl(chk, "F000000000000000", 3, "8000000000000000", 64)
    chkShl(chk, "0F", 63, "8000000000000000", 64)

    chkShl(chk, "0F", 5, "1E0", 64)
    chkShl(chk, "0F", 9, "1E00", 64)
    chkShl(chk, "0F", 17, "1E0000", 64)
    chkShl(chk, "0F", 33, "1E00000000", 64)

    chkShl(chk, "0F", 4, "F0", 128)
    chkShl(chk, "F0", 4, "F00", 128)
    chkShl(chk, "F0", 3, "780", 128)
    chkShl(chk, "F000", 3, "78000", 128)
    chkShl(chk, "F0000000", 3, "780000000", 128)
    chkShl(chk, "F000000000000000", 3, "78000000000000000", 128)
    chkShl(chk, "F0000000000000000000000000000000", 3, "80000000000000000000000000000000", 128)

    chkShl(chk, "0F", 33, "1E00000000", 128)
    chkShl(chk, "0F", 65, "1E0000000000000000", 128)
    chkShl(chk, "0F", 97, "1E000000000000000000000000", 128)
    chkShl(chk, "0F", 127, "80000000000000000000000000000000", 128)

    chkShl(chk, "0F", 4, "F0", 256)
    chkShl(chk, "F0", 4, "F00", 256)
    chkShl(chk, "F0", 3, "780", 256)
    chkShl(chk, "F000", 3, "78000", 256)
    chkShl(chk, "F0000000", 3, "780000000", 256)
    chkShl(chk, "F000000000000000", 3, "78000000000000000", 256)
    chkShl(chk, "F0000000000000000000000000000000", 3, "780000000000000000000000000000000", 256)

    chkShl(chk, "0F", 33, "1E00000000", 256)
    chkShl(chk, "0F", 65, "1E0000000000000000", 256)
    chkShl(chk, "0F", 97, "1E000000000000000000000000", 256)
    chkShl(chk, "0F", 128, "0F00000000000000000000000000000000", 256)
    chkShl(chk, "0F", 129, "1E00000000000000000000000000000000", 256)
    chkShl(chk, "0F", 255, "8000000000000000000000000000000000000000000000000000000000000000", 256)

  tst "operator `shr`":
    chkShr(chk, "0F", 4, "00", 8)
    chkShr(chk, "F0", 4, "0F", 8)
    chkShr(chk, "F0", 3, "1E", 8)
    chkShr(chk, "F0", 7, "01", 8)

    chkShr(chk, "0F", 4, "00", 16)
    chkShr(chk, "F0", 4, "0F", 16)
    chkShr(chk, "F000", 3, "1E00", 16)
    chkShr(chk, "F000", 15, "0001", 16)

    chkShr(chk, "0F", 4, "00", 32)
    chkShr(chk, "F0", 4, "0F", 32)
    chkShr(chk, "F0", 3, "1E", 32)
    chkShr(chk, "F0000000", 3, "1E000000", 32)
    chkShr(chk, "F0000000", 31, "00000001", 32)

    chkShr(chk, "0F", 4, "00", 64)
    chkShr(chk, "F0", 4, "0F", 64)
    chkShr(chk, "F0", 3, "1E", 64)
    chkShr(chk, "F000", 3, "1E00", 64)
    chkShr(chk, "F0000000", 3, "1E000000", 64)
    chkShr(chk, "F000000000000000", 63, "0000000000000001", 64)

    chkShr(chk, "0F", 4, "00", 128)
    chkShr(chk, "F0", 4, "0F", 128)
    chkShr(chk, "F0", 3, "1E", 128)
    chkShr(chk, "F000", 3, "1E00", 128)
    chkShr(chk, "F0000000", 3, "1E000000", 128)
    chkShr(chk, "F000000000000000", 3, "1E00000000000000", 128)
    chkShr(chk, "F0000000000000000000000000000000", 127, "00000000000000000000000000000001", 128)

    chkShr(chk, "F0000000000000000000000000000000", 33, "00000000780000000000000000000000", 128)
    chkShr(chk, "F0000000000000000000000000000000", 65, "00000000000000007800000000000000", 128)
    chkShr(chk, "F0000000000000000000000000000000", 97, "00000000000000000000000078000000", 128)

    chkShr(chk, "0F", 4, "00", 256)
    chkShr(chk, "F0", 4, "0F", 256)
    chkShr(chk, "F0", 3, "1E", 256)
    chkShr(chk, "F000", 3, "1E00", 256)
    chkShr(chk, "F0000000", 3, "1E000000", 256)
    chkShr(chk, "F000000000000000", 3, "1E00000000000000", 256)
    chkShr(chk, "F000000000000000000000000000000000000000000000000000000000000000", 255, "1", 256)

    chkShr(chk, "F000000000000000000000000000000000000000000000000000000000000000", 33, "0000000078000000000000000000000000000000000000000000000000000000", 256)
    chkShr(chk, "F000000000000000000000000000000000000000000000000000000000000000", 65, "0000000000000000780000000000000000000000000000000000000000000000", 256)
    chkShr(chk, "F000000000000000000000000000000000000000000000000000000000000000", 129, "0000000000000000000000000000000078000000000000000000000000000000", 256)
    chkShr(chk, "F000000000000000000000000000000000000000000000000000000000000000", 233, "780000", 256)

static:
  testBitwise(ctCheck, ctTest)

suite "Wider unsigned int bitwise coverage":
  testBitwise(check, test)

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

    block: # Testing shl for nested UintImpl
      let p2_64 = UintImpl[uint64](hi:1, lo:0)
      let p = 1.stuint(128) shl 64

      check: p == cast[StUint[128]](p2_64)

  test "Shift right - by less than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 2) == z shr 2

  test "Shift right - by more than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 10) == z shr 10

  test "Shift right - by half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 8) == z shr 8

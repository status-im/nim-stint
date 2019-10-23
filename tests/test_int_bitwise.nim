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
  chk stint(a, bits).not() == stint(b, bits)

template chkNot(chk: untyped, a, b: string, bits: int) =
  chk fromHex(Stint[bits], a).not() == fromHex(Stint[bits], b)

template chkOr(chk: untyped, a, b, c: string, bits: int) =
  chk (fromHex(Stint[bits], a) or fromHex(Stint[bits], b)) == fromHex(Stint[bits], c)

template chkAnd(chk: untyped, a, b, c: string, bits: int) =
  chk (fromHex(Stint[bits], a) and fromHex(Stint[bits], b)) == fromHex(Stint[bits], c)

template chkXor(chk: untyped, a, b, c: string, bits: int) =
  chk (fromHex(Stint[bits], a) xor fromHex(Stint[bits], b)) == fromHex(Stint[bits], c)

template chkShl(chk: untyped, a: string, b: SomeInteger, c: string, bits: int) =
  chk (fromHex(Stint[bits], a) shl b) == fromHex(Stint[bits], c)

template chkShr(chk: untyped, a: string, b: SomeInteger, c: string, bits: int) =
  chk (fromHex(Stint[bits], a) shr b) == fromHex(Stint[bits], c)

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
    chkNot(chk, 0'i8, not 0'i8, 8)
    chkNot(chk, high(int8), not high(int8), 8)
    chkNot(chk, "0F", "F0", 8)
    chkNot(chk, "F0", "0F", 8)

    chkNot(chk, 0'i8, not 0'i16, 16)
    chkNot(chk, 0'i16, not 0'i16, 16)
    chkNot(chk, high(int8), not int16(high(int8)), 16)
    chkNot(chk, high(int16), not high(int16), 16)
    chkNot(chk, "F0", "FF0F", 16)
    chkNot(chk, "0F", "FFF0", 16)
    chkNot(chk, "FF00", "00FF", 16)
    chkNot(chk, "00FF", "FF00", 16)
    chkNot(chk, "0FF0", "F00F", 16)

    chkNot(chk, 0'i8, not 0'i32, 32)
    chkNot(chk, 0'i16, not 0'i32, 32)
    chkNot(chk, 0'i32, not 0'i32, 32)
    chkNot(chk, high(int8), not int32(high(int8)), 32)
    chkNot(chk, high(int16), not int32(high(int16)), 32)
    chkNot(chk, high(int32), not high(int32), 32)
    chkNot(chk, "F0", "FFFFFF0F", 32)
    chkNot(chk, "0F", "FFFFFFF0", 32)
    chkNot(chk, "FF00", "FFFF00FF", 32)
    chkNot(chk, "00FF", "FFFFFF00", 32)
    chkNot(chk, "0000FFFF", "FFFF0000", 32)
    chkNot(chk, "00FFFF00", "FF0000FF", 32)
    chkNot(chk, "0F0F0F0F", "F0F0F0F0", 32)

    chkNot(chk, 0'i8, not 0'i64, 64)
    chkNot(chk, 0'i16, not 0'i64, 64)
    chkNot(chk, 0'i32, not 0'i64, 64)
    chkNot(chk, 0'i64, not 0'i64, 64)
    chkNot(chk, high(int8), not int64(high(int8)), 64)
    chkNot(chk, high(int16), not int64(high(int16)), 64)
    chkNot(chk, high(int32), not int64(high(int32)), 64)
    chkNot(chk, high(int64), not high(int64), 64)

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
    chkShr(chk, "F0", 4, "FF", 8)
    chkShr(chk, "F0", 3, "FE", 8)
    chkShr(chk, "F0", 7, "FF", 8)

    chkShr(chk, "0F", 4, "00", 16)
    chkShr(chk, "F0", 4, "0F", 16)
    chkShr(chk, "F000", 3, "FE00", 16)
    chkShr(chk, "F000", 15, "FFFF", 16)

    chkShr(chk, "0F", 4, "00", 32)
    chkShr(chk, "F0", 4, "0F", 32)
    chkShr(chk, "F0", 3, "1E", 32)
    chkShr(chk, "F0000000", 3, "FE000000", 32)
    chkShr(chk, "F0000000", 31, "FFFFFFFF", 32)

    chkShr(chk, "0F", 4, "00", 64)
    chkShr(chk, "F0", 4, "0F", 64)
    chkShr(chk, "F0", 3, "1E", 64)
    chkShr(chk, "F000", 3, "1E00", 64)
    chkShr(chk, "F0000000", 3, "1E000000", 64)
    chkShr(chk, "F000000000000000", 63, "FFFFFFFFFFFFFFFF", 64)

    chkShr(chk, "0F", 4, "00", 128)
    chkShr(chk, "F0", 4, "0F", 128)
    chkShr(chk, "F0", 3, "1E", 128)
    chkShr(chk, "F000", 3, "1E00", 128)
    chkShr(chk, "F0000000", 3, "1E000000", 128)
    chkShr(chk, "F000000000000000", 3, "1E00000000000000", 128)
    chkShr(chk, "F0000000000000000000000000000000", 127, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)

    chkShr(chk, "F0000000000000000000000000000000", 33, "FFFFFFFFF80000000000000000000000", 128)
    chkShr(chk, "F0000000000000000000000000000000", 65, "FFFFFFFFFFFFFFFFF800000000000000", 128)
    chkShr(chk, "F0000000000000000000000000000000", 97, "FFFFFFFFFFFFFFFFFFFFFFFFF8000000", 128)

    chkShr(chk, "0F", 4, "00", 256)
    chkShr(chk, "F0", 4, "0F", 256)
    chkShr(chk, "F0", 3, "1E", 256)
    chkShr(chk, "F000", 3, "1E00", 256)
    chkShr(chk, "F0000000", 3, "1E000000", 256)
    chkShr(chk, "F000000000000000", 3, "1E00000000000000", 256)
    chkShr(chk, "F000000000000000000000000000000000000000000000000000000000000000", 255, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 256)

    chkShr(chk, "F000000000000000000000000000000000000000000000000000000000000000", 33, "FFFFFFFFF8000000000000000000000000000000000000000000000000000000", 256)
    chkShr(chk, "F000000000000000000000000000000000000000000000000000000000000000", 65, "FFFFFFFFFFFFFFFFF80000000000000000000000000000000000000000000000", 256)
    chkShr(chk, "F000000000000000000000000000000000000000000000000000000000000000", 129, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8000000000000000000000000000000", 256)
    chkShr(chk, "F000000000000000000000000000000000000000000000000000000000000000", 233, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF80000", 256)

static:
  testBitwise(ctCheck, ctTest)

suite "Wider signed int bitwise coverage":
  testBitwise(check, test)

when defined(cpp):
  import quicktest, ttmath_compat

func high(T: typedesc[SomeUnsignedInt]): T =
  not T(0)

suite "Testing signed int bitwise operations":
  const
    hi = high(int64)
    lo = low(int64)
    itercount = 1000

  test "Shift Left":
    var y = 1.u256
    for i in 1..255:
      let x = 1.i256 shl i
      y = y shl 1
      check cast[stint.Uint256](x) == y

  test "Shift Right on positive int":
    const leftMost = 1.i256 shl 254
    var y = 1.u256 shl 254
    for i in 1..255:
      let x = leftMost shr i
      y = y shr 1
      check x == cast[stint.Int256](y)

  test "Shift Right on negative int":
    const
      leftMostU = 1.u256 shl 255
      leftMostI = 1.i256 shl 255
    var y = leftMostU
    for i in 1..255:
      let x = leftMostI shr i
      y = (y shr 1) or leftMostU
      check x == cast[stint.Int256](y)

  test "Compile time shift":
    const
      # set all bits
      x = high(stint.Int256) or (1.i256 shl 255)
      y = not 0.i256

    check x == y

    const
      a = (high(stint.Int256) shl 10) shr 10
      b = (high(stint.Uint256) shl 10) shr 10
      c = (high(stint.Int256) shl 10) shr 10

    check a != cast[stint.Int256](b)
    check c != cast[stint.Int256](b)
    check c == a

  when defined(cpp):
    quicktest "signed int `shl` vs ttmath", itercount do(x0: int64(min=lo, max=hi),
                                  x1: int64(min=0, max=hi),
                                  x2: int64(min=0, max=hi),
                                  x3: int64(min=0, max=hi),
                                  y: int(min=0, max=(255))):

      let
        x = [x0, x1, x2, x3]

        ttm_x = x.asTT
        mp_x  = cast[stint.Int256](x)

      let
        ttm_z = ttm_x shl y
        mp_z  = mp_x  shl y

      check ttm_z.asSt == mp_z

    quicktest "arithmetic shift right vs ttmath", itercount do(x0: int64(min=lo, max=hi),
                                  x1: int64(min=0, max=hi),
                                  x2: int64(min=0, max=hi),
                                  x3: int64(min=0, max=hi),
                                  y: int(min=0, max=(255))):

      let
        x = [x0, x1, x2, x3]

        ttm_x = x.asTT
        mp_x  = cast[stint.Int256](x)

      let
        ttm_z = ttm_x shr y # C/CPP usually implement `shr` as `ashr` a.k.a. `sar`
        mp_z  = mp_x shr y

      check ttm_z.asSt == mp_z

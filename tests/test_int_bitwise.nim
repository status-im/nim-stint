# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template chkNot(a, b: string, bits: int) =
  check fromHex(StInt[bits], a).not() == fromHex(StInt[bits], b)

template chkOr(a, b, c: string, bits: int) =
  check (fromHex(StInt[bits], a) or fromHex(StInt[bits], b)) == fromHex(StInt[bits], c)

template chkAnd(a, b, c: string, bits: int) =
  check (fromHex(StInt[bits], a) and fromHex(StInt[bits], b)) == fromHex(StInt[bits], c)

template chkXor(a, b, c: string, bits: int) =
  check (fromHex(StInt[bits], a) xor fromHex(StInt[bits], b)) == fromHex(StInt[bits], c)

template chkShl(a: string, b: SomeInteger, c: string, bits: int) =
  check (fromHex(StInt[bits], a) shl b) == fromHex(StInt[bits], c)

template chkShr(a: string, b: SomeInteger, c: string, bits: int) =
  check (fromHex(StInt[bits], a) shr b) == fromHex(StInt[bits], c)

suite "Wider signed int bitwise coverage":
  # TODO: see issue #95
  #chkShl("0F", 128, "00", 128)
  #chkShl("0F", 256, "00", 256)
  #chkShr("F0000000000000000000000000000000", 128, "00", 128)

  test "operator `not`":
    chkNot("0", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)
    chkNot("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", "0", 128)
    chkNot("F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0", "0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F", 128)
    chkNot("FFFFFFFFFFFF00000000000000000000", "000000000000FFFFFFFFFFFFFFFFFFFF", 128)

  test "operator `or`":
    chkOr("00", "FF", "000000000000000000000000000000FF", 128)
    chkOr("FF", "00", "000000000000000000000000000000FF", 128)
    chkOr("F0", "0F", "000000000000000000000000000000FF", 128)
    chkOr("00", "00", "00000000000000000000000000000000", 128)
    chkOr("FF00", "0F00", "0000000000000000000000000000FF00", 128)
    chkOr("00FF00FF", "000F000F", "00000000000000000000000000FF00FF", 128)
    chkOr("00000000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", 128)

  test "operator `and`":
    chkAnd("00", "FF", "00000000000000000000000000000000", 128)
    chkAnd("FF", "00", "00000000000000000000000000000000", 128)
    chkAnd("F0", "0F", "00000000000000000000000000000000", 128)
    chkAnd("00", "00", "00000000000000000000000000000000", 128)
    chkAnd("FF00", "0F00", "00000000000000000000000000000F00", 128)
    chkAnd("00FF00FF", "000F000F", "000000000000000000000000000F000F", 128)
    chkAnd("F0000000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", "F0000000000000000000000000FF00FF", 128)

  test "operator `xor`":
    chkXor("00", "FF", "000000000000000000000000000000FF", 128)
    chkXor("FF", "00", "000000000000000000000000000000FF", 128)
    chkXor("F0", "0F", "000000000000000000000000000000FF", 128)
    chkXor("00", "00", "00000000000000000000000000000000", 128)
    chkXor("FF00", "0F00", "0000000000000000000000000000F000", 128)
    chkXor("00FF00FF", "000F000F", "00000000000000000000000000F000F0", 128)
    chkXor("F0000000000000000000000000FF00FF", "FF0F0000000000000000000000FF00FF", "0F0F0000000000000000000000000000", 128)

  test "operator `shl`":
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
    chkShr("0F", 4, "00", 128)
    chkShr("F0", 4, "0F", 128)
    chkShr("F0", 3, "1E", 128)
    chkShr("F000", 3, "1E00", 128)
    chkShr("F0000000", 3, "1E000000", 128)
    chkShr("F000000000000000", 3, "1E00000000000000", 128)
    chkShr("F0000000000000000000000000000000", 127, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 128)

    chkShr("F0000000000000000000000000000000", 33, "FFFFFFFFF80000000000000000000000", 128)
    chkShr("F0000000000000000000000000000000", 65, "FFFFFFFFFFFFFFFFF800000000000000", 128)
    chkShr("F0000000000000000000000000000000", 97, "FFFFFFFFFFFFFFFFFFFFFFFFF8000000", 128)

    chkShr("0F", 4, "00", 256)
    chkShr("F0", 4, "0F", 256)
    chkShr("F0", 3, "1E", 256)
    chkShr("F000", 3, "1E00", 256)
    chkShr("F0000000", 3, "1E000000", 256)
    chkShr("F000000000000000", 3, "1E00000000000000", 256)
    chkShr("F000000000000000000000000000000000000000000000000000000000000000", 255, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 256)

    chkShr("F000000000000000000000000000000000000000000000000000000000000000", 33, "FFFFFFFFF8000000000000000000000000000000000000000000000000000000", 256)
    chkShr("F000000000000000000000000000000000000000000000000000000000000000", 65, "FFFFFFFFFFFFFFFFF80000000000000000000000000000000000000000000000", 256)
    chkShr("F000000000000000000000000000000000000000000000000000000000000000", 129, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8000000000000000000000000000000", 256)
    chkShr("F000000000000000000000000000000000000000000000000000000000000000", 233, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF80000", 256)

suite "Testing signed int bitwise operations":
  test "Shift Left":
    var y = 1.u256
    for i in 1..255:
      let x = 1.i256 shl i
      y = y shl 1
      check x.toBytesLE() == y.toBytesLE()

  test "Shift Right on positive int":
    const leftMost = 1.i256 shl 254
    var y = 1.u256 shl 254
    for i in 1..255:
      let x = leftMost shr i
      y = y shr 1
      check x.toBytesLE() == y.toBytesLE()

  test "Shift Right on negative int":
    const
      leftMostU = 1.u256 shl 255
      leftMostI = 1.i256 shl 255
    var y = leftMostU
    for i in 1..255:
      let x = leftMostI shr i
      y = (y shr 1) or leftMostU
      check x.toBytesLE() == y.toBytesLE()

  test "Compile time shift":
    const
      # set all bits
      x = high(stint.Int256) or (1.i256 shl 255)
      y = not 0.i256

    check x == y

    const
      a = (high(stint.Int256) shl 10) shr 10
      b = (high(stint.UInt256) shl 10) shr 10
      c = (high(stint.Int256) shl 10) shr 10

    check a.toBytesLE() != b.toBytesLE()
    check c.toBytesLE() != b.toBytesLE()
    check c == a

#[

when defined(cpp):
  import quicktest, ttmath_compat

  func high(T: typedesc[SomeUnsignedInt]): T =
    not T(0)

  when defined(cpp):
    const
      hi = high(int64)
      lo = low(int64)
      itercount = 1000

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
]#

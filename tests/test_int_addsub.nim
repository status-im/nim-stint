# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, test_helpers

template chkAddition(chk, a, b, c, bits: untyped) =
  block:
    let x = stint(a, bits)
    let y = stint(b, bits)
    chk x + y == stint(c, bits)

template chkInplaceAddition(chk, a, b, c, bits: untyped) =
  block:
    var x = stint(a, bits)
    x += stint(b, bits)
    chk x == stint(c, bits)

template chkSubstraction(chk, a, b, c, bits: untyped) =
  block:
    let x = stint(a, bits)
    let y = stint(b, bits)
    chk x - y == stint(c, bits)

template chkInplaceSubstraction(chk, a, b, c, bits: untyped) =
  block:
    var x = stint(a, bits)
    x -= stint(b, bits)
    chk x == stint(c, bits)

template chkNegation(chk, a, b, bits: untyped) =
  chk -stint(a, bits) == stint(b, bits)

template chkAbs(chk, a, b, bits: untyped) =
  chk stint(a, bits).abs() == stint(b, bits)

template testAddSub(chk, tst: untyped) =
  tst "addition":
    chkAddition(chk, 0'i8, 0'i8, 0'i8, 8)
    chkAddition(chk, high(int8) - 17'i8, 17'i8, high(int8), 8)
    chkAddition(chk, low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 8)

    chkAddition(chk, 0'i8, 0'i8, 0'i8, 16)
    chkAddition(chk, high(int8) - 17'i8, 17'i8, high(int8), 16)
    chkAddition(chk, low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 16)
    chkAddition(chk, high(int16) - 17'i16, 17'i16, high(int16), 16)
    chkAddition(chk, low(int16) + 17'i16, 17'i16, low(int16) + 34'i16, 16)

    chkAddition(chk, 0'i8, 0'i8, 0'i8, 32)
    chkAddition(chk, high(int8) - 17'i8, 17'i8, high(int8), 32)
    chkAddition(chk, low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 32)
    chkAddition(chk, high(int16) - 17'i16, 17'i16, high(int16), 32)
    chkAddition(chk, low(int16) + 17'i16, 17'i16, low(int16) + 34'i16, 32)
    chkAddition(chk, high(int32) - 17'i32, 17'i32, high(int32), 32)
    chkAddition(chk, low(int32) + 17'i32, 17'i32, low(int32) + 34'i32, 32)

    chkAddition(chk, 0'i8, 0'i8, 0'i8, 64)
    chkAddition(chk, high(int8) - 17'i8, 17'i8, high(int8), 64)
    chkAddition(chk, low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 64)
    chkAddition(chk, high(int16) - 17'i16, 17'i16, high(int16), 64)
    chkAddition(chk, low(int16) + 17'i16, 17'i16, low(int16) + 34'i16, 64)
    chkAddition(chk, high(int32) - 17'i32, 17'i32, high(int32), 64)
    chkAddition(chk, low(int32) + 17'i32, 17'i32, low(int32) + 34'i32, 64)
    chkAddition(chk, high(int64) - 17'i64, 17'i64, high(int64), 64)
    chkAddition(chk, low(int64) + 17'i64, 17'i64, low(int64) + 34'i64, 64)

    chkAddition(chk, 0'i8, 0'i8, 0'i8, 128)
    chkAddition(chk, high(int8) - 17'i8, 17'i8, high(int8), 128)
    chkAddition(chk, low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 128)
    chkAddition(chk, high(int16) - 17'i16, 17'i16, high(int16), 128)
    chkAddition(chk, low(int16) + 17'i16, 17'i16, low(int16) + 34'i16, 128)
    chkAddition(chk, high(int32) - 17'i32, 17'i32, high(int32), 128)
    chkAddition(chk, low(int32) + 17'i32, 17'i32, low(int32) + 34'i32, 128)
    chkAddition(chk, high(int64) - 17'i64, 17'i64, high(int64), 128)
    chkAddition(chk, low(int64) + 17'i64, 17'i64, low(int64) + 34'i64, 128)

  tst "inplace addition":
    chkInplaceAddition(chk, 0'i8, 0'i8, 0'i8, 8)
    chkInplaceAddition(chk, high(int8) - 17'i8, 17'i8, high(int8), 8)
    chkInplaceAddition(chk, low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 8)

    chkInplaceAddition(chk, 0'i8, 0'i8, 0'i8, 16)
    chkInplaceAddition(chk, high(int8) - 17'i8, 17'i8, high(int8), 16)
    chkInplaceAddition(chk, low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 16)
    chkInplaceAddition(chk, high(int16) - 17'i16, 17'i16, high(int16), 16)
    chkInplaceAddition(chk, low(int16) + 17'i16, 17'i16, low(int16) + 34'i16, 16)

    chkInplaceAddition(chk, 0'i8, 0'i8, 0'i8, 32)
    chkInplaceAddition(chk, high(int8) - 17'i8, 17'i8, high(int8), 32)
    chkInplaceAddition(chk, low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 32)
    chkInplaceAddition(chk, high(int16) - 17'i16, 17'i16, high(int16), 32)
    chkInplaceAddition(chk, low(int16) + 17'i16, 17'i16, low(int16) + 34'i16, 32)
    chkInplaceAddition(chk, high(int32) - 17'i32, 17'i32, high(int32), 32)
    chkInplaceAddition(chk, low(int32) + 17'i32, 17'i32, low(int32) + 34'i32, 32)

    chkInplaceAddition(chk, 0'i8, 0'i8, 0'i8, 64)
    chkInplaceAddition(chk, high(int8) - 17'i8, 17'i8, high(int8), 64)
    chkInplaceAddition(chk, low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 64)
    chkInplaceAddition(chk, high(int16) - 17'i16, 17'i16, high(int16), 64)
    chkInplaceAddition(chk, low(int16) + 17'i16, 17'i16, low(int16) + 34'i16, 64)
    chkInplaceAddition(chk, high(int32) - 17'i32, 17'i32, high(int32), 64)
    chkInplaceAddition(chk, low(int32) + 17'i32, 17'i32, low(int32) + 34'i32, 64)
    chkInplaceAddition(chk, high(int64) - 17'i64, 17'i64, high(int64), 64)
    chkInplaceAddition(chk, low(int64) + 17'i64, 17'i64, low(int64) + 34'i64, 64)

    chkInplaceAddition(chk, 0'i8, 0'i8, 0'i8, 128)
    chkInplaceAddition(chk, high(int8) - 17'i8, 17'i8, high(int8), 128)
    chkInplaceAddition(chk, low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 128)
    chkInplaceAddition(chk, high(int16) - 17'i16, 17'i16, high(int16), 128)
    chkInplaceAddition(chk, low(int16) + 17'i16, 17'i16, low(int16) + 34'i16, 128)
    chkInplaceAddition(chk, high(int32) - 17'i32, 17'i32, high(int32), 128)
    chkInplaceAddition(chk, low(int32) + 17'i32, 17'i32, low(int32) + 34'i32, 128)
    chkInplaceAddition(chk, high(int64) - 17'i64, 17'i64, high(int64), 128)
    chkInplaceAddition(chk, low(int64) + 17'i64, 17'i64, low(int64) + 34'i64, 128)

  tst "substraction":
    chkSubstraction(chk, 0'i8, 0'i8, 0'i8, 8)
    chkSubstraction(chk, high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 8)
    chkSubstraction(chk, low(int8) + 17'i8, 17'i8, low(int8), 8)

    chkSubstraction(chk, 0'i8, 0'i8, 0'i8, 16)
    chkSubstraction(chk, high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 16)
    chkSubstraction(chk, low(int8) + 17'i8, 17'i8, low(int8), 16)
    chkSubstraction(chk, high(int16) - 17'i16, 17'i16, high(int16) - 34'i16, 16)
    chkSubstraction(chk, low(int16) + 17'i16, 17'i16, low(int16), 16)

    chkSubstraction(chk, 0'i8, 0'i8, 0'i8, 32)
    chkSubstraction(chk, high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 32)
    chkSubstraction(chk, low(int8) + 17'i8, 17'i8, low(int8), 32)
    chkSubstraction(chk, high(int16) - 17'i16, 17'i16, high(int16) - 34'i16, 32)
    chkSubstraction(chk, low(int16) + 17'i16, 17'i16, low(int16), 32)
    chkSubstraction(chk, high(int32) - 17'i32, 17'i32, high(int32) - 34'i32, 32)
    chkSubstraction(chk, low(int32) + 17'i32, 17'i32, low(int32), 32)

    chkSubstraction(chk, 0'i8, 0'i8, 0'i8, 64)
    chkSubstraction(chk, high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 64)
    chkSubstraction(chk, low(int8) + 17'i8, 17'i8, low(int8), 64)
    chkSubstraction(chk, high(int16) - 17'i16, 17'i16, high(int16) - 34'i16, 64)
    chkSubstraction(chk, low(int16) + 17'i16, 17'i16, low(int16), 64)
    chkSubstraction(chk, high(int32) - 17'i32, 17'i32, high(int32) - 34'i32, 64)
    chkSubstraction(chk, low(int32) + 17'i32, 17'i32, low(int32), 64)
    chkSubstraction(chk, high(int64) - 17'i64, 17'i64, high(int64) - 34'i64, 64)
    chkSubstraction(chk, low(int64) + 17'i64, 17'i64, low(int64), 64)

    chkSubstraction(chk, 0'i8, 0'i8, 0'i8, 128)
    chkSubstraction(chk, high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 128)
    chkSubstraction(chk, -high(int8), -high(int8), 0'i8, 128)
    chkSubstraction(chk, high(int16) - 17'i16, 17'i16, high(int16) - 34'i16, 128)
    chkSubstraction(chk, -high(int16), -high(int16), 0'i16, 128)
    chkSubstraction(chk, high(int32) - 17'i32, 17'i32, high(int32) - 34'i32, 128)
    chkSubstraction(chk, -high(int32), -high(int32), 0'i32, 128)
    chkSubstraction(chk, high(int64) - 17'i64, 17'i64, high(int64) - 34'i64, 128)
    chkSubstraction(chk, -high(int64), -high(int64), 0'i64, 128)

  tst "inplace substraction":
    chkInplaceSubstraction(chk, 0'i8, 0'i8, 0'i8, 8)
    chkInplaceSubstraction(chk, high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 8)
    chkInplaceSubstraction(chk, low(int8) + 17'i8, 17'i8, low(int8), 8)

    chkInplaceSubstraction(chk, 0'i8, 0'i8, 0'i8, 16)
    chkInplaceSubstraction(chk, high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 16)
    chkInplaceSubstraction(chk, low(int8) + 17'i8, 17'i8, low(int8), 16)
    chkInplaceSubstraction(chk, high(int16) - 17'i16, 17'i16, high(int16) - 34'i16, 16)
    chkInplaceSubstraction(chk, low(int16) + 17'i16, 17'i16, low(int16), 16)

    chkInplaceSubstraction(chk, 0'i8, 0'i8, 0'i8, 32)
    chkInplaceSubstraction(chk, high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 32)
    chkInplaceSubstraction(chk, low(int8) + 17'i8, 17'i8, low(int8), 32)
    chkInplaceSubstraction(chk, high(int16) - 17'i16, 17'i16, high(int16) - 34'i16, 32)
    chkInplaceSubstraction(chk, low(int16) + 17'i16, 17'i16, low(int16), 32)
    chkInplaceSubstraction(chk, high(int32) - 17'i32, 17'i32, high(int32) - 34'i32, 32)
    chkInplaceSubstraction(chk, low(int32) + 17'i32, 17'i32, low(int32), 32)

    chkInplaceSubstraction(chk, 0'i8, 0'i8, 0'i8, 64)
    chkInplaceSubstraction(chk, high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 64)
    chkInplaceSubstraction(chk, low(int8) + 17'i8, 17'i8, low(int8), 64)
    chkInplaceSubstraction(chk, high(int16) - 17'i16, 17'i16, high(int16) - 34'i16, 64)
    chkInplaceSubstraction(chk, low(int16) + 17'i16, 17'i16, low(int16), 64)
    chkInplaceSubstraction(chk, high(int32) - 17'i32, 17'i32, high(int32) - 34'i32, 64)
    chkInplaceSubstraction(chk, low(int32) + 17'i32, 17'i32, low(int32), 64)
    chkInplaceSubstraction(chk, high(int64) - 17'i64, 17'i64, high(int64) - 34'i64, 64)
    chkInplaceSubstraction(chk, low(int64) + 17'i64, 17'i64, low(int64), 64)

    chkInplaceSubstraction(chk, 0'i8, 0'i8, 0'i8, 128)
    chkInplaceSubstraction(chk, high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 128)
    chkInplaceSubstraction(chk, -high(int8), -high(int8), 0'i8, 128)
    chkInplaceSubstraction(chk, high(int16) - 17'i16, 17'i16, high(int16) - 34'i16, 128)
    chkInplaceSubstraction(chk, -high(int16), -high(int16), 0'i16, 128)
    chkInplaceSubstraction(chk, high(int32) - 17'i32, 17'i32, high(int32) - 34'i32, 128)
    chkInplaceSubstraction(chk, -high(int32), -high(int32), 0'i32, 128)
    chkInplaceSubstraction(chk, high(int64) - 17'i64, 17'i64, high(int64) - 34'i64, 128)
    chkInplaceSubstraction(chk, -high(int64), -high(int64), 0'i64, 128)

  tst "negation":
    chkNegation(chk, 0, 0, 8)
    # chkNegation(chk, 128, -128, 8) # TODO: bug #92
    chkNegation(chk, 127, -127, 8)

    chkNegation(chk, 0, 0, 16)
    chkNegation(chk, 128, -128, 16)
    chkNegation(chk, 127, -127, 16)
    #chkNegation(chk, 32768, -32768, 16) # TODO: bug #92
    chkNegation(chk, 32767, -32767, 16)

    chkNegation(chk, 0, 0, 32)
    chkNegation(chk, 128, -128, 32)
    chkNegation(chk, 127, -127, 32)
    chkNegation(chk, 32768, -32768, 32)
    chkNegation(chk, 32767, -32767, 32)
    #chkNegation(chk, high(int32)+1, low(int32), 32) # TODO: bug #92

    chkNegation(chk, 0, 0, 64)
    chkNegation(chk, 128, -128, 64)
    chkNegation(chk, 127, -127, 64)
    chkNegation(chk, 32768, -32768, 64)
    chkNegation(chk, 32767, -32767, 64)
    chkNegation(chk, 2147483648, -2147483648, 64)
    chkNegation(chk, 2147483647, -2147483647, 64)
    #chkNegation(chk, 9223372036854775808, -9223372036854775808, 64) # TODO: bug #92

    chkNegation(chk, 0, 0, 128)
    chkNegation(chk, 128, -128, 128)
    chkNegation(chk, 127, -127, 128)
    chkNegation(chk, 32768, -32768, 128)
    chkNegation(chk, 32767, -32767, 128)
    # With Nim 1.6, it seems like https://github.com/status-im/nim-stint/issues/92
    # can now happen on 32-bit platforms.
    when (NimMajor,NimMinor,NimPatch) < (1,6,0):
      chkNegation(chk, 2147483648, -2147483648, 128)
    chkNegation(chk, 2147483647, -2147483647, 128)
    #chkNegation(chk, 9223372036854775808, -9223372036854775808, 128) # TODO: bug #92

  tst "absolute integer":
    chkAbs(chk, 0, 0, 8)
    chkAbs(chk, -127, 127, 8)
    chkAbs(chk, -1, 1, 8)
    chkAbs(chk, 1, 1, 8)
    chkAbs(chk, 127, 127, 8)

    chkAbs(chk, 0, 0, 16)
    chkAbs(chk, -127, 127, 16)
    chkAbs(chk, -32767, 32767, 16)
    chkAbs(chk, -1, 1, 16)
    chkAbs(chk, 1, 1, 16)
    chkAbs(chk, 127, 127, 16)
    chkAbs(chk, 32767, 32767, 16)

    chkAbs(chk, 0, 0, 32)
    chkAbs(chk, -127, 127, 32)
    chkAbs(chk, -32767, 32767, 32)
    chkAbs(chk, -1, 1, 32)
    chkAbs(chk, 1, 1, 32)
    chkAbs(chk, 127, 127, 32)
    chkAbs(chk, 32767, 32767, 32)
    chkAbs(chk, -2147483647, 2147483647, 32)
    chkAbs(chk, 2147483647, 2147483647, 32)

    chkAbs(chk, 0, 0, 64)
    chkAbs(chk, -127, 127, 64)
    chkAbs(chk, -32767, 32767, 64)
    chkAbs(chk, -1, 1, 64)
    chkAbs(chk, 1, 1, 64)
    chkAbs(chk, 127, 127, 64)
    chkAbs(chk, 32767, 32767, 64)
    chkAbs(chk, -2147483647, 2147483647, 64)
    chkAbs(chk, 2147483647, 2147483647, 64)
    chkAbs(chk, -9223372036854775807, 9223372036854775807, 64)
    chkAbs(chk, 9223372036854775807, 9223372036854775807, 64)

    chkAbs(chk, 0, 0, 128)
    chkAbs(chk, -127, 127, 128)
    chkAbs(chk, -32767, 32767, 128)
    chkAbs(chk, -1, 1, 128)
    chkAbs(chk, 1, 1, 128)
    chkAbs(chk, 127, 127, 128)
    chkAbs(chk, 32767, 32767, 128)
    chkAbs(chk, -2147483647, 2147483647, 128)
    chkAbs(chk, 2147483647, 2147483647, 128)
    chkAbs(chk, -9223372036854775807, 9223372036854775807, 128)
    chkAbs(chk, 9223372036854775807, 9223372036854775807, 128)

static:
  testAddSub(ctCheck, ctTest)

proc main() =
  # Nim GC protests we are using too much global variables
  # so put it in a proc
  suite "Wider signed int addsub coverage":
    testAddSub(check, test)

  suite "Testing signed addition implementation":
    test "In-place addition gives expected result":

      var a = 20182018.stint(64)
      let b = 20172017.stint(64)

      a += b

      check: cast[int64](a) == 20182018'i64 + 20172017'i64

    test "Addition gives expected result":

      let a = 20182018.stint(64)
      let b = 20172017.stint(64)

      check: cast[int64](a+b) == 20182018'i64 + 20172017'i64

    test "When the low half overflows, it is properly carried":
      # uint8 (low half) overflow at 255
      let a = 100'i16.stint(16)
      let b = 100'i16.stint(16)

      check: cast[int16](a+b) == 200

  suite "Testing signed substraction implementation":
    test "In-place substraction gives expected result":

      var a = 20182018.stint(64)
      let b = 20172017.stint(64)

      a -= b

      check: cast[int64](a) == 20182018'i64 - 20172017'i64

    test "Substraction gives expected result":

      let a = 20182018.stint(64)
      let b = 20172017.stint(64)

      check: cast[int64](a-b) == 20182018'i64 - 20172017'i64

main()

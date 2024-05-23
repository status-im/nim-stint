# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template checkAddition(a, b, c, bits: untyped) =
  block:
    let x = stint(a, bits)
    let y = stint(b, bits)
    check x + y == stint(c, bits)

template checkInplaceAddition(a, b, c, bits: untyped) =
  block:
    var x = stint(a, bits)
    x += stint(b, bits)
    check x == stint(c, bits)

template checkSubstraction(a, b, c, bits: untyped) =
  block:
    let x = stint(a, bits)
    let y = stint(b, bits)
    check x - y == stint(c, bits)

template checkInplaceSubstraction(a, b, c, bits: untyped) =
  block:
    var x = stint(a, bits)
    x -= stint(b, bits)
    check x == stint(c, bits)

template checkNegation(a, b, bits: untyped) =
  check -stint(a, bits) == stint(b, bits)

template checkAbs(a, b, bits: untyped) =
  check stint(a, bits).abs() == stint(b, bits)

suite "Wider signed int addsub coverage":
  test "addition":
    checkAddition(0'i8, 0'i8, 0'i8, 128)
    checkAddition(high(int8) - 17'i8, 17'i8, high(int8), 128)
    checkAddition(low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 128)
    checkAddition(high(int16) - 17'i16, 17'i16, high(int16), 128)
    checkAddition(low(int16) + 17'i16, 17'i16, low(int16) + 34'i16, 128)
    checkAddition(high(int32) - 17'i32, 17'i32, high(int32), 128)
    checkAddition(low(int32) + 17'i32, 17'i32, low(int32) + 34'i32, 128)
    checkAddition(high(int64) - 17'i64, 17'i64, high(int64), 128)
    checkAddition(low(int64) + 17'i64, 17'i64, low(int64) + 34'i64, 128)

  test "inplace addition":
    checkInplaceAddition(0'i8, 0'i8, 0'i8, 128)
    checkInplaceAddition(high(int8) - 17'i8, 17'i8, high(int8), 128)
    checkInplaceAddition(low(int8) + 17'i8, 17'i8, low(int8) + 34'i8, 128)
    checkInplaceAddition(high(int16) - 17'i16, 17'i16, high(int16), 128)
    checkInplaceAddition(low(int16) + 17'i16, 17'i16, low(int16) + 34'i16, 128)
    checkInplaceAddition(high(int32) - 17'i32, 17'i32, high(int32), 128)
    checkInplaceAddition(low(int32) + 17'i32, 17'i32, low(int32) + 34'i32, 128)
    checkInplaceAddition(high(int64) - 17'i64, 17'i64, high(int64), 128)
    checkInplaceAddition(low(int64) + 17'i64, 17'i64, low(int64) + 34'i64, 128)

  test "substraction":
    checkSubstraction(0'i8, 0'i8, 0'i8, 128)
    checkSubstraction(high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 128)
    checkSubstraction(-high(int8), -high(int8), 0'i8, 128)
    checkSubstraction(high(int16) - 17'i16, 17'i16, high(int16) - 34'i16, 128)
    checkSubstraction(-high(int16), -high(int16), 0'i16, 128)
    checkSubstraction(high(int32) - 17'i32, 17'i32, high(int32) - 34'i32, 128)
    checkSubstraction(-high(int32), -high(int32), 0'i32, 128)
    checkSubstraction(high(int64) - 17'i64, 17'i64, high(int64) - 34'i64, 128)
    checkSubstraction(-high(int64), -high(int64), 0'i64, 128)

  test "inplace substraction":
    checkInplaceSubstraction(0'i8, 0'i8, 0'i8, 128)
    checkInplaceSubstraction(high(int8) - 17'i8, 17'i8, high(int8) - 34'i8, 128)
    checkInplaceSubstraction(-high(int8), -high(int8), 0'i8, 128)
    checkInplaceSubstraction(high(int16) - 17'i16, 17'i16, high(int16) - 34'i16, 128)
    checkInplaceSubstraction(-high(int16), -high(int16), 0'i16, 128)
    checkInplaceSubstraction(high(int32) - 17'i32, 17'i32, high(int32) - 34'i32, 128)
    checkInplaceSubstraction(-high(int32), -high(int32), 0'i32, 128)
    checkInplaceSubstraction(high(int64) - 17'i64, 17'i64, high(int64) - 34'i64, 128)
    checkInplaceSubstraction(-high(int64), -high(int64), 0'i64, 128)

  test "negation":
    checkNegation(0, 0, 128)
    checkNegation(128, -128, 128)
    checkNegation(127, -127, 128)
    checkNegation(32768, -32768, 128)
    checkNegation(32767, -32767, 128)
    checkNegation(2147483648, -2147483648, 128)
    checkNegation(2147483647, -2147483647, 128)

    let x = int64.high.i128
    check -x == -9223372036854775807'i64.i128

    let y = int64.low.i128
    let z = int64.high.i128 + 1.i128
    check -y == z

  test "absolute integer":
    checkAbs(0, 0, 128)
    checkAbs(-127, 127, 128)
    checkAbs(-32767, 32767, 128)
    checkAbs(-1, 1, 128)
    checkAbs(1, 1, 128)
    checkAbs(127, 127, 128)
    checkAbs(32767, 32767, 128)
    checkAbs(-2147483647, 2147483647, 128)
    checkAbs(2147483647, 2147483647, 128)
    checkAbs(-9223372036854775807, 9223372036854775807, 128)
    checkAbs(9223372036854775807, 9223372036854775807, 128)

suite "Testing signed addition implementation":
  test "In-place addition gives expected result":

    var a = 20182018.stint(256)
    let b = 20172017.stint(256)

    a += b

    check a == (20182018'i64 + 20172017'i64).i256

  test "Addition gives expected result":

    let a = 20182018.stint(256)
    let b = 20172017.stint(256)

    check a+b == (20182018'i64 + 20172017'i64).i256

  test "When the low half overflows, it is properly carried":
    # uint8 (low half) overflow at 255
    let a = 100.stint(256)
    let b = 100.stint(256)

    check a+b == 200.i256

suite "Testing signed substraction implementation":
  test "In-place substraction gives expected result":

    var a = 20182018.stint(256)
    let b = 20172017.stint(256)

    a -= b

    check a == (20182018'i64 - 20172017'i64).i256

  test "Substraction gives expected result":

    let a = 20182018.stint(256)
    let b = 20172017.stint(256)

    check: a-b == (20182018'i64 - 20172017'i64).i256

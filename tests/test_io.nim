# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, strutils, math, test_helpers, tables, std/strformat

template nativeStuint(chk, nint: untyped, bits: int) =
  chk $(nint.stuint(bits)) == $(nint)

template nativeStint(chk, nint: untyped, bits: int) =
  chk $(nint.stint(bits)) == $(nint)

template chkTruncateStuint(chk, number, toType: untyped, bits: int) =
  chk (number.stuint(bits)).truncate(toType) == toType(number)

template chkTruncateStint(chk, number, toType: untyped, bits: int) =
  chk (number.stint(bits)).truncate(toType) == toType(number)

template chkTruncateStint(chk, number, toType: untyped, res: string, bits: int) =
  block:
    let x = (number.stint(bits)).truncate(toType).toHex()
    chk "0x" & x == res

template chkRoundTripStuint(chk: untyped, prefix, str: string, bits, radix: int) =
  block:
    let data = prefix & str
    let x = parse(data, StUint[bits], radix)
    let y = x.toString(radix)
    chk y == str

template chkRoundTripStuint(chk: untyped, str: string, bits, radix: int) =
  chkRoundTripStuint(chk, "", str, bits, radix)

template chkRoundTripStint(chk: untyped, prefix, str: string, bits, radix: int) =
  block:
    let data = prefix & str
    let x = parse(data, StInt[bits], radix)
    let y = x.toString(radix)
    chk y == str

template chkRoundTripStint(chk: untyped, str: string, bits, radix: int) =
  chkRoundTripStint(chk, "", str, bits, radix)

template chkRoundTripBin(chk, chkProc: untyped, bits, rep: int) =
  chkProc(chk, "0", bits, 2)
  chkProc(chk, repeat("1", rep), bits, 2)
  chkProc(chk, repeat("1010", rep), bits, 2)
  chkProc(chk, repeat("1111", rep), bits, 2)
  chkProc(chk, repeat("11110000", rep), bits, 2)
  chkProc(chk, repeat("10101010", rep), bits, 2)
  chkProc(chk, repeat("1010101", rep), bits, 2)
  chkProc(chk, repeat("11111111", rep), bits, 2)

template chkRoundTripHex(chk, chkProc: untyped, bits, rep: int) =
  chkProc(chk, "0", bits, 16)
  chkProc(chk, repeat("1", rep), bits, 16)
  chkProc(chk, repeat("7", rep), bits, 16)
  chkProc(chk, repeat("f", rep), bits, 16)
  chkProc(chk, repeat("aa", rep), bits, 16)
  chkProc(chk, repeat("ff", rep), bits, 16)
  chkProc(chk, repeat("f0", rep), bits, 16)

template chkRoundTripOct(chk, chkProc: untyped, bits, rep: int) =
  chkProc(chk, "0", bits, 8)
  chkProc(chk, repeat("1", rep), bits, 8)
  chkProc(chk, repeat("7", rep), bits, 8)
  chkProc(chk, repeat("177", rep), bits, 8)

template chkRoundTripDec(chk, chkProc: untyped, bits, rep: int) =
  chkProc(chk, "0", bits, 10)
  chkProc(chk, repeat("1", rep), bits, 10)
  chkProc(chk, repeat("9", rep), bits, 10)

func toByteArray(x: static[string]): auto {.compileTime.} =
  var ret: array[x.len, byte]
  for i, b in x: ret[i] = byte(b)
  ret

template chkRoundtripBE(chk: untyped, str: string, bits: int) =
  block:
    const data = toByteArray(str)
    var x: StUint[bits]
    initFromBytesBE(x, data)
    let y = toByteArrayBE(x)
    chk y == data

template chkCTvsRT(chk: untyped, num: untyped, bits: int) =
  block:
    let x = stuint(num, bits)
    let y = toByteArrayBE(x)
    const xx = stuint(num, bits)
    const yy = toByteArrayBE(xx)
    chk y == yy

template chkDumpHexStuint(chk: untyped, BE, LE: string, bits: int) =
  block:
    let data = BE
    let x = fromHex(StUint[bits], data)
    chk dumpHex(x, bigEndian) == data
    chk dumpHex(x, littleEndian) == LE

template chkDumpHexStint(chk: untyped, BE, LE: string, bits: int) =
  block:
    let data = BE
    let x = fromHex(StInt[bits], data)
    chk dumpHex(x, bigEndian) == data
    chk dumpHex(x, littleEndian) == LE

template testIO(chk, tst: untyped) =
  tst "[stuint] Creation from native ints":
    nativeStuint(chk, 0, 8)
    nativeStuint(chk, 0'u8, 8)
    nativeStuint(chk, 0xFF'u16, 8)
    nativeStuint(chk, 0xFF'u32, 8)
    nativeStuint(chk, 0xFF'u64, 8)
    nativeStuint(chk, 0'i8, 8)
    nativeStuint(chk, 0xFF'i16, 8)
    nativeStuint(chk, 0xFF'i32, 8)
    nativeStuint(chk, 0xFF'i64, 8)
    nativeStuint(chk, high(uint8), 8)
    nativeStuint(chk, low(uint8), 8)
    nativeStuint(chk, high(int8), 8)

    nativeStuint(chk, 0, 16)
    nativeStuint(chk, 0'u8, 16)
    nativeStuint(chk, 0xFFFF'u32, 16)
    nativeStuint(chk, 0xFFFF'u64, 16)
    nativeStuint(chk, 0xFFFF'i32, 16)
    nativeStuint(chk, 0xFFFF'i64, 16)
    nativeStuint(chk, high(uint8), 16)
    nativeStuint(chk, low(uint8), 16)
    nativeStuint(chk, high(int8), 16)
    nativeStuint(chk, 0'u16, 16)
    nativeStuint(chk, high(uint16), 16)
    nativeStuint(chk, low(uint16), 16)
    nativeStuint(chk, high(int16), 16)

    nativeStuint(chk, 0, 32)
    nativeStuint(chk, 0'u8, 32)
    nativeStuint(chk, 0xFFFFFFFF'u64, 32)
    nativeStuint(chk, 0xFFFFFFFF'i64, 32)
    nativeStuint(chk, high(uint8), 32)
    nativeStuint(chk, low(uint8), 32)
    nativeStuint(chk, high(int8), 32)
    nativeStuint(chk, 0'u16, 32)
    nativeStuint(chk, high(uint16), 32)
    nativeStuint(chk, low(uint16), 32)
    nativeStuint(chk, high(int16), 32)
    nativeStuint(chk, 0'u32, 32)
    nativeStuint(chk, high(uint32), 32)
    nativeStuint(chk, low(uint32), 32)
    nativeStuint(chk, high(int32), 32)

    nativeStuint(chk, 0, 64)
    nativeStuint(chk, 0'u8, 64)
    nativeStuint(chk, high(uint8), 64)
    nativeStuint(chk, low(uint8), 64)
    nativeStuint(chk, high(int8), 64)
    nativeStuint(chk, 0'u16, 64)
    nativeStuint(chk, high(uint16), 64)
    nativeStuint(chk, low(uint16), 64)
    nativeStuint(chk, high(int16), 64)
    nativeStuint(chk, 0'u32, 64)
    nativeStuint(chk, high(uint32), 64)
    nativeStuint(chk, low(uint32), 64)
    nativeStuint(chk, high(int32), 64)
    nativeStuint(chk, 0'u64, 64)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      nativeStuint(chk, high(uint64), 64)
      nativeStuint(chk, low(uint64), 64)
    nativeStuint(chk, high(int64), 64)

    when sizeof(uint) == 4:
      when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
        nativeStuint(chk, high(uint), 32)
        nativeStuint(chk, low(uint), 32)
      nativeStuint(chk, high(int), 32)
    else:
      when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
        nativeStuint(chk, high(uint), 64)
        nativeStuint(chk, low(uint), 64)
      nativeStuint(chk, high(int), 64)

    nativeStuint(chk, 0, 128)
    nativeStuint(chk, 0'u8, 128)
    nativeStuint(chk, high(uint8), 128)
    nativeStuint(chk, low(uint8), 128)
    nativeStuint(chk, high(int8), 128)
    nativeStuint(chk, 0'u16, 128)
    nativeStuint(chk, high(uint16), 128)
    nativeStuint(chk, low(uint16), 128)
    nativeStuint(chk, high(int16), 128)
    nativeStuint(chk, 0'u32, 128)
    nativeStuint(chk, high(uint32), 128)
    nativeStuint(chk, low(uint32), 128)
    nativeStuint(chk, high(int32), 128)
    nativeStuint(chk, 0'u64, 128)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      nativeStuint(chk, high(uint64), 128)
      nativeStuint(chk, low(uint64), 128)
    nativeStuint(chk, high(int64), 128)

  tst "[stint] Creation from native ints":
    nativeStint(chk, 0, 8)
    nativeStint(chk, 0'u8, 8)
    nativeStint(chk, high(int8), 8)
    nativeStint(chk, low(int8), 8)
    nativeStint(chk, low(uint8), 8)

    nativeStint(chk, 0, 16)
    nativeStint(chk, 0'u8, 16)
    nativeStint(chk, high(int8), 16)
    nativeStint(chk, low(int8), 16)
    nativeStint(chk, low(uint8), 16)
    nativeStint(chk, 0'u16, 16)
    nativeStint(chk, high(int16), 16)
    nativeStint(chk, low(int16), 16)
    nativeStint(chk, low(uint16), 16)

    nativeStint(chk, 0, 32)
    nativeStint(chk, 0'u8, 32)
    nativeStint(chk, high(int8), 32)
    nativeStint(chk, low(int8), 32)
    nativeStint(chk, low(uint8), 32)
    nativeStint(chk, 0'u16, 32)
    nativeStint(chk, high(int16), 32)
    nativeStint(chk, low(int16), 32)
    nativeStint(chk, low(uint16), 32)
    nativeStint(chk, 0'u32, 32)
    nativeStint(chk, high(int32), 32)
    nativeStint(chk, low(int32), 32)
    nativeStint(chk, low(uint32), 32)

    nativeStint(chk, 0, 64)
    nativeStint(chk, 0'u8, 64)
    nativeStint(chk, high(int8), 64)
    nativeStint(chk, low(int8), 64)
    nativeStint(chk, low(uint8), 64)
    nativeStint(chk, 0'u16, 64)
    nativeStint(chk, high(int16), 64)
    nativeStint(chk, low(int16), 64)
    nativeStint(chk, low(uint16), 64)
    nativeStint(chk, 0'u32, 64)
    nativeStint(chk, high(int32), 64)
    nativeStint(chk, low(int32), 64)
    nativeStint(chk, low(uint32), 64)
    nativeStint(chk, 0'u64, 64)
    nativeStint(chk, high(int64), 64)
    nativeStint(chk, low(int64), 64)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      nativeStint(chk, low(uint64), 64)

    when sizeof(uint) == 4:
      nativeStint(chk, high(int), 32)
      nativeStint(chk, low(int), 32)
      when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
        nativeStint(chk, low(uint), 32)
    else:
      nativeStint(chk, high(int), 64)
      nativeStint(chk, low(int), 64)
      when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
        nativeStint(chk, low(uint), 64)

    nativeStint(chk, 0, 128)
    nativeStint(chk, 0'u8, 128)
    nativeStint(chk, high(int8), 128)
    nativeStint(chk, low(uint8), 128)
    nativeStint(chk, 0'u16, 128)
    nativeStint(chk, high(int16), 128)
    nativeStint(chk, low(uint16), 128)
    nativeStint(chk, 0'u32, 128)
    nativeStint(chk, high(int32), 128)
    nativeStint(chk, low(uint32), 128)
    nativeStint(chk, 0'u64, 128)
    nativeStint(chk, high(int64), 128)
    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      nativeStint(chk, low(uint64), 128)

    # TODO: bug #92
    #nativeStint(chk, low(int8), 128)
    #nativeStint(chk, low(int16), 128)
    #nativeStint(chk, low(int32), 128)
    #nativeStint(chk, low(int64), 128)

  tst "[stuint] truncate":
    chkTruncateStuint(chk, low(uint8), uint8, 8)
    chkTruncateStuint(chk, high(uint8), uint8, 8)
    chkTruncateStuint(chk, high(int8), uint8, 8)
    chkTruncateStuint(chk, high(int8), int8, 8)

    chkTruncateStuint(chk, low(uint8), uint8, 16)
    chkTruncateStuint(chk, high(uint8), uint8, 16)
    chkTruncateStuint(chk, high(int8), uint8, 16)
    chkTruncateStuint(chk, high(int8), int8, 16)

    chkTruncateStuint(chk, low(uint8), uint16, 16)
    chkTruncateStuint(chk, high(uint8), uint16, 16)
    chkTruncateStuint(chk, high(int8), uint16, 16)
    chkTruncateStuint(chk, high(int8), int16, 16)

    chkTruncateStuint(chk, low(uint16), uint16, 16)
    chkTruncateStuint(chk, high(uint16), uint16, 16)
    chkTruncateStuint(chk, high(int16), uint16, 16)
    chkTruncateStuint(chk, high(int16), int16, 16)

    chkTruncateStuint(chk, low(uint8), uint8, 32)
    chkTruncateStuint(chk, high(uint8), uint8, 32)
    chkTruncateStuint(chk, high(int8), uint8, 32)
    chkTruncateStuint(chk, high(int8), int8, 32)

    chkTruncateStuint(chk, low(uint8), uint16, 32)
    chkTruncateStuint(chk, high(uint8), uint16, 32)
    chkTruncateStuint(chk, high(int8), uint16, 32)
    chkTruncateStuint(chk, high(int8), int16, 32)

    chkTruncateStuint(chk, low(uint16), uint16, 32)
    chkTruncateStuint(chk, high(uint16), uint16, 32)
    chkTruncateStuint(chk, high(int16), uint16, 32)
    chkTruncateStuint(chk, high(int16), int16, 32)

    chkTruncateStuint(chk, low(uint8), uint32, 32)
    chkTruncateStuint(chk, high(uint8), uint32, 32)
    chkTruncateStuint(chk, high(int8), uint32, 32)
    chkTruncateStuint(chk, high(int8), int32, 32)

    chkTruncateStuint(chk, low(uint16), uint32, 32)
    chkTruncateStuint(chk, high(uint16), uint32, 32)
    chkTruncateStuint(chk, high(int16), uint32, 32)
    chkTruncateStuint(chk, high(int16), int32, 32)

    chkTruncateStuint(chk, low(uint32), uint32, 32)
    chkTruncateStuint(chk, high(uint32), uint32, 32)
    chkTruncateStuint(chk, high(int32), uint32, 32)
    chkTruncateStuint(chk, high(int32), int32, 32)

    chkTruncateStuint(chk, low(uint8), uint8, 64)
    chkTruncateStuint(chk, high(uint8), uint8, 64)
    chkTruncateStuint(chk, high(int8), uint8, 64)
    chkTruncateStuint(chk, high(int8), int8, 64)

    chkTruncateStuint(chk, low(uint8), uint16, 64)
    chkTruncateStuint(chk, high(uint8), uint16, 64)
    chkTruncateStuint(chk, high(int8), uint16, 64)
    chkTruncateStuint(chk, high(int8), int16, 64)

    chkTruncateStuint(chk, low(uint16), uint16, 64)
    chkTruncateStuint(chk, high(uint16), uint16, 64)
    chkTruncateStuint(chk, high(int16), uint16, 64)
    chkTruncateStuint(chk, high(int16), int16, 64)

    chkTruncateStuint(chk, low(uint8), uint32, 64)
    chkTruncateStuint(chk, high(uint8), uint32, 64)
    chkTruncateStuint(chk, high(int8), uint32, 64)
    chkTruncateStuint(chk, high(int8), int32, 64)

    chkTruncateStuint(chk, low(uint16), uint32, 64)
    chkTruncateStuint(chk, high(uint16), uint32, 64)
    chkTruncateStuint(chk, high(int16), uint32, 64)
    chkTruncateStuint(chk, high(int16), int32, 64)

    chkTruncateStuint(chk, low(uint32), uint32, 64)
    chkTruncateStuint(chk, high(uint32), uint32, 64)
    chkTruncateStuint(chk, high(int32), uint32, 64)
    chkTruncateStuint(chk, high(int32), int32, 64)

    chkTruncateStuint(chk, low(uint8), uint64, 64)
    chkTruncateStuint(chk, high(uint8), uint64, 64)
    chkTruncateStuint(chk, high(int8), uint64, 64)
    chkTruncateStuint(chk, high(int8), int64, 64)

    chkTruncateStuint(chk, low(uint16), uint64, 64)
    chkTruncateStuint(chk, high(uint16), uint64, 64)
    chkTruncateStuint(chk, high(int16), uint64, 64)
    chkTruncateStuint(chk, high(int16), int64, 64)

    chkTruncateStuint(chk, low(uint32), uint64, 64)
    chkTruncateStuint(chk, high(uint32), uint64, 64)
    chkTruncateStuint(chk, high(int32), uint64, 64)
    chkTruncateStuint(chk, high(int32), int64, 64)

    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkTruncateStuint(chk, low(uint64), uint64, 64)
      chkTruncateStuint(chk, high(uint64), uint64, 64)
    chkTruncateStuint(chk, high(int64), uint64, 64)
    chkTruncateStuint(chk, high(int64), int64, 64)

    chkTruncateStuint(chk, low(uint8), uint8, 128)
    chkTruncateStuint(chk, high(uint8), uint8, 128)
    chkTruncateStuint(chk, high(int8), uint8, 128)
    chkTruncateStuint(chk, high(int8), int8, 128)

    chkTruncateStuint(chk, low(uint8), uint16, 128)
    chkTruncateStuint(chk, high(uint8), uint16, 128)
    chkTruncateStuint(chk, high(int8), uint16, 128)
    chkTruncateStuint(chk, high(int8), int16, 128)

    chkTruncateStuint(chk, low(uint16), uint16, 128)
    chkTruncateStuint(chk, high(uint16), uint16, 128)
    chkTruncateStuint(chk, high(int16), uint16, 128)
    chkTruncateStuint(chk, high(int16), int16, 128)

    chkTruncateStuint(chk, low(uint8), uint32, 128)
    chkTruncateStuint(chk, high(uint8), uint32, 128)
    chkTruncateStuint(chk, high(int8), uint32, 128)
    chkTruncateStuint(chk, high(int8), int32, 128)

    chkTruncateStuint(chk, low(uint16), uint32, 128)
    chkTruncateStuint(chk, high(uint16), uint32, 128)
    chkTruncateStuint(chk, high(int16), uint32, 128)
    chkTruncateStuint(chk, high(int16), int32, 128)

    chkTruncateStuint(chk, low(uint32), uint32, 128)
    chkTruncateStuint(chk, high(uint32), uint32, 128)
    chkTruncateStuint(chk, high(int32), uint32, 128)
    chkTruncateStuint(chk, high(int32), int32, 128)

    chkTruncateStuint(chk, low(uint8), uint64, 128)
    chkTruncateStuint(chk, high(uint8), uint64, 128)
    chkTruncateStuint(chk, high(int8), uint64, 128)
    chkTruncateStuint(chk, high(int8), int64, 128)

    chkTruncateStuint(chk, low(uint16), uint64, 128)
    chkTruncateStuint(chk, high(uint16), uint64, 128)
    chkTruncateStuint(chk, high(int16), uint64, 128)
    chkTruncateStuint(chk, high(int16), int64, 128)

    chkTruncateStuint(chk, low(uint32), uint64, 128)
    chkTruncateStuint(chk, high(uint32), uint64, 128)
    chkTruncateStuint(chk, high(int32), uint64, 128)
    chkTruncateStuint(chk, high(int32), int64, 128)

    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkTruncateStuint(chk, low(uint64), uint64, 128)
      chkTruncateStuint(chk, high(uint64), uint64, 128)
    chkTruncateStuint(chk, high(int64), uint64, 128)
    chkTruncateStuint(chk, high(int64), int64, 128)

  tst "[stint] truncate":
    chkTruncateStint(chk, low(uint8), uint8, 8)
    chkTruncateStint(chk, low(int8), int8, 8)
    chkTruncateStint(chk, high(int8), uint8, 8)
    chkTruncateStint(chk, high(int8), int8, 8)
    chkTruncateStint(chk, low(int8), uint8, "0x80", 8)

    chkTruncateStint(chk, low(uint8), uint8, 16)
    chkTruncateStint(chk, low(int8), int8, 16)
    chkTruncateStint(chk, high(int8), uint8, 16)
    chkTruncateStint(chk, high(int8), int8, 16)
    chkTruncateStint(chk, low(int8), uint8, "0x80", 16)

    chkTruncateStint(chk, low(uint8), uint16, 16)
    chkTruncateStint(chk, low(int8), int16, 16)
    chkTruncateStint(chk, high(int8), uint16, 16)
    chkTruncateStint(chk, high(int8), int16, 16)
    chkTruncateStint(chk, low(int8), uint16, "0xFF80", 16)

    chkTruncateStint(chk, low(uint16), uint16, 16)
    chkTruncateStint(chk, low(int16), int16, 16)
    chkTruncateStint(chk, high(int16), uint16, 16)
    chkTruncateStint(chk, high(int16), int16, 16)
    chkTruncateStint(chk, low(int16), uint16, "0x8000", 16)

    chkTruncateStint(chk, low(uint8), uint8, 32)
    chkTruncateStint(chk, low(int8), int8, 32)
    chkTruncateStint(chk, high(int8), uint8, 32)
    chkTruncateStint(chk, high(int8), int8, 32)
    chkTruncateStint(chk, low(int8), uint8, "0x80", 32)

    chkTruncateStint(chk, low(uint8), uint16, 32)
    chkTruncateStint(chk, low(int8), int16, 32)
    chkTruncateStint(chk, high(int8), uint16, 32)
    chkTruncateStint(chk, high(int8), int16, 32)
    chkTruncateStint(chk, low(int8), uint16, "0xFF80", 32)

    chkTruncateStint(chk, low(uint16), uint16, 32)
    chkTruncateStint(chk, low(int16), int16, 32)
    chkTruncateStint(chk, high(int16), uint16, 32)
    chkTruncateStint(chk, high(int16), int16, 32)
    chkTruncateStint(chk, low(int16), uint16, "0x8000", 32)

    chkTruncateStint(chk, low(uint8), uint32, 32)
    chkTruncateStint(chk, low(int8), int32, 32)
    chkTruncateStint(chk, high(int8), uint32, 32)
    chkTruncateStint(chk, high(int8), int32, 32)
    chkTruncateStint(chk, low(int8), uint32, "0xFFFFFF80", 32)

    chkTruncateStint(chk, low(uint16), uint32, 32)
    chkTruncateStint(chk, low(int16), int32, 32)
    chkTruncateStint(chk, high(int16), uint32, 32)
    chkTruncateStint(chk, high(int16), int32, 32)
    chkTruncateStint(chk, low(int16), uint32, "0xFFFF8000", 32)

    chkTruncateStint(chk, low(uint32), uint32, 32)
    chkTruncateStint(chk, low(int32), int32, 32)
    chkTruncateStint(chk, high(int32), uint32, 32)
    chkTruncateStint(chk, high(int32), int32, 32)
    chkTruncateStint(chk, low(int32), uint32, "0x80000000", 32)

    chkTruncateStint(chk, low(uint8), uint8, 64)
    chkTruncateStint(chk, low(int8), int8, 64)
    chkTruncateStint(chk, high(int8), uint8, 64)
    chkTruncateStint(chk, high(int8), int8, 64)
    chkTruncateStint(chk, low(int8), uint8, "0x80", 64)

    chkTruncateStint(chk, low(uint8), uint16, 64)
    chkTruncateStint(chk, low(int8), int16, 64)
    chkTruncateStint(chk, high(int8), uint16, 64)
    chkTruncateStint(chk, high(int8), int16, 64)
    chkTruncateStint(chk, low(int8), uint16, "0xFF80", 64)

    chkTruncateStint(chk, low(uint16), uint16, 64)
    chkTruncateStint(chk, low(int16), int16, 64)
    chkTruncateStint(chk, high(int16), uint16, 64)
    chkTruncateStint(chk, high(int16), int16, 64)
    chkTruncateStint(chk, low(int16), uint16, "0x8000", 64)

    chkTruncateStint(chk, low(uint8), uint32, 64)
    chkTruncateStint(chk, low(int8), int32, 64)
    chkTruncateStint(chk, high(int8), uint32, 64)
    chkTruncateStint(chk, high(int8), int32, 64)
    chkTruncateStint(chk, low(int8), uint32, "0xFFFFFF80", 64)

    chkTruncateStint(chk, low(uint16), uint32, 64)
    chkTruncateStint(chk, low(int16), int32, 64)
    chkTruncateStint(chk, high(int16), uint32, 64)
    chkTruncateStint(chk, high(int16), int32, 64)
    chkTruncateStint(chk, low(int16), uint32, "0xFFFF8000", 64)

    chkTruncateStint(chk, low(uint32), uint32, 64)
    chkTruncateStint(chk, low(int32), int32, 64)
    chkTruncateStint(chk, high(int32), uint32, 64)
    chkTruncateStint(chk, high(int32), int32, 64)
    chkTruncateStint(chk, low(int32), uint32, "0x80000000", 64)

    chkTruncateStint(chk, low(uint8), uint64, 64)
    chkTruncateStint(chk, low(int8), int64, 64)
    chkTruncateStint(chk, high(int8), uint64, 64)
    chkTruncateStint(chk, high(int8), int64, 64)
    chkTruncateStint(chk, low(int8), uint64, "0xFFFFFFFFFFFFFF80", 64)

    chkTruncateStint(chk, low(uint16), uint64, 64)
    chkTruncateStint(chk, low(int16), int64, 64)
    chkTruncateStint(chk, high(int16), uint64, 64)
    chkTruncateStint(chk, high(int16), int64, 64)
    chkTruncateStint(chk, low(int16), uint64, "0xFFFFFFFFFFFF8000", 64)

    chkTruncateStint(chk, low(uint32), uint64, 64)
    chkTruncateStint(chk, low(int32), int64, 64)
    chkTruncateStint(chk, high(int32), uint64, 64)
    chkTruncateStint(chk, high(int32), int64, 64)
    chkTruncateStint(chk, low(int32), uint64, "0xFFFFFFFF80000000", 64)

    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkTruncateStint(chk, low(uint64), uint64, 64)
    chkTruncateStint(chk, low(int64), int64, 64)
    chkTruncateStint(chk, high(int64), uint64, 64)
    chkTruncateStint(chk, high(int64), int64, 64)
    chkTruncateStint(chk, low(int64), uint64, "0x8000000000000000", 64)

    chkTruncateStint(chk, low(uint8), uint8, 128)
    #chkTruncateStint(chk, low(int8), int8, 128) # TODO: bug #92
    chkTruncateStint(chk, high(int8), uint8, 128)
    chkTruncateStint(chk, high(int8), int8, 128)
    #chkTruncateStint(chk, low(int8), uint8, "0x80", 128) # TODO: bug #92

    chkTruncateStint(chk, low(uint8), uint16, 128)
    #chkTruncateStint(chk, low(int8), int16, 128) # TODO: bug #92
    chkTruncateStint(chk, high(int8), uint16, 128)
    chkTruncateStint(chk, high(int8), int16, 128)
    #chkTruncateStint(chk, low(int8), uint16, "0xFF80", 128) # TODO: bug #92

    chkTruncateStint(chk, low(uint16), uint16, 128)
    #chkTruncateStint(chk, low(int16), int16, 128) # TODO: bug #92
    chkTruncateStint(chk, high(int16), uint16, 128)
    chkTruncateStint(chk, high(int16), int16, 128)
    #chkTruncateStint(chk, low(int16), uint16, "0x8000", 128) # TODO: bug #92

    chkTruncateStint(chk, low(uint8), uint32, 128)
    #chkTruncateStint(chk, low(int8), int32, 128) # TODO: bug #92
    chkTruncateStint(chk, high(int8), uint32, 128)
    chkTruncateStint(chk, high(int8), int32, 128)
    #chkTruncateStint(chk, low(int8), uint32, "0xFFFFFF80", 128) # TODO: bug #92

    chkTruncateStint(chk, low(uint16), uint32, 128)
    #chkTruncateStint(chk, low(int16), int32, 128) # TODO: bug #92
    chkTruncateStint(chk, high(int16), uint32, 128)
    chkTruncateStint(chk, high(int16), int32, 128)
    #chkTruncateStint(chk, low(int16), uint32, "0xFFFF8000", 128) # TODO: bug #92

    chkTruncateStint(chk, low(uint32), uint32, 128)
    #chkTruncateStint(chk, low(int32), int32, 128) # TODO: bug #92
    chkTruncateStint(chk, high(int32), uint32, 128)
    chkTruncateStint(chk, high(int32), int32, 128)
    #chkTruncateStint(chk, low(int32), uint32, "0x80000000", 128) # TODO: bug #92

    chkTruncateStint(chk, low(uint8), uint64, 128)
    #chkTruncateStint(chk, low(int8), int64, 128) # TODO: bug #92
    chkTruncateStint(chk, high(int8), uint64, 128)
    chkTruncateStint(chk, high(int8), int64, 128)
    #chkTruncateStint(chk, low(int8), uint64, "0xFFFFFFFFFFFFFF80", 128) # TODO: bug #92

    chkTruncateStint(chk, low(uint16), uint64, 128)
    #chkTruncateStint(chk, low(int16), int64, 128) # TODO: bug #92
    chkTruncateStint(chk, high(int16), uint64, 128)
    chkTruncateStint(chk, high(int16), int64, 128)
    #chkTruncateStint(chk, low(int16), uint64, "0xFFFFFFFFFFFF8000", 128) # TODO: bug #92

    chkTruncateStint(chk, low(uint32), uint64, 128)
    #chkTruncateStint(chk, low(int32), int64, 128) # TODO: bug #92
    chkTruncateStint(chk, high(int32), uint64, 128)
    chkTruncateStint(chk, high(int32), int64, 128)
    #chkTruncateStint(chk, low(int32), uint64, "0xFFFFFFFF80000000", 128) # TODO: bug #92

    when (NimMajor, NimMinor, NimPatch) >= (1, 0, 0):
      chkTruncateStint(chk, low(uint64), uint64, 128)
    #chkTruncateStint(chk, low(int64), int64, 128) # TODO: bug #92
    chkTruncateStint(chk, high(int64), uint64, 128)
    chkTruncateStint(chk, high(int64), int64, 128)
    #chkTruncateStint(chk, low(int64), uint64, "0x8000000000000000", 128) # TODO: bug #92

  tst "[stuint] parse - toString roundtrip":
    chkRoundTripBin(chk, chkRoundTripStuint, 8, 1)

    chkRoundTripBin(chk, chkRoundTripStuint, 16, 1)
    chkRoundTripBin(chk, chkRoundTripStuint, 16, 2)

    chkRoundTripBin(chk, chkRoundTripStuint, 32, 1)
    chkRoundTripBin(chk, chkRoundTripStuint, 32, 2)
    chkRoundTripBin(chk, chkRoundTripStuint, 32, 3)
    chkRoundTripBin(chk, chkRoundTripStuint, 32, 4)

    chkRoundTripBin(chk, chkRoundTripStuint, 64, 1)
    chkRoundTripBin(chk, chkRoundTripStuint, 64, 2)
    chkRoundTripBin(chk, chkRoundTripStuint, 64, 3)
    chkRoundTripBin(chk, chkRoundTripStuint, 64, 4)
    chkRoundTripBin(chk, chkRoundTripStuint, 64, 5)
    chkRoundTripBin(chk, chkRoundTripStuint, 64, 6)
    chkRoundTripBin(chk, chkRoundTripStuint, 64, 7)
    chkRoundTripBin(chk, chkRoundTripStuint, 64, 8)

    chkRoundTripBin(chk, chkRoundTripStuint, 128, 1)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 2)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 3)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 4)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 5)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 6)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 7)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 8)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 9)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 10)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 11)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 12)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 13)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 14)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 15)
    chkRoundTripBin(chk, chkRoundTripStuint, 128, 16)

    chkRoundTripHex(chk, chkRoundTripStuint, 8, 1)

    chkRoundTripHex(chk, chkRoundTripStuint, 16, 1)
    chkRoundTripHex(chk, chkRoundTripStuint, 16, 2)

    chkRoundTripHex(chk, chkRoundTripStuint, 32, 1)
    chkRoundTripHex(chk, chkRoundTripStuint, 32, 2)
    chkRoundTripHex(chk, chkRoundTripStuint, 32, 3)
    chkRoundTripHex(chk, chkRoundTripStuint, 32, 4)

    chkRoundTripHex(chk, chkRoundTripStuint, 64, 1)
    chkRoundTripHex(chk, chkRoundTripStuint, 64, 2)
    chkRoundTripHex(chk, chkRoundTripStuint, 64, 3)
    chkRoundTripHex(chk, chkRoundTripStuint, 64, 4)
    chkRoundTripHex(chk, chkRoundTripStuint, 64, 5)
    chkRoundTripHex(chk, chkRoundTripStuint, 64, 6)
    chkRoundTripHex(chk, chkRoundTripStuint, 64, 7)
    chkRoundTripHex(chk, chkRoundTripStuint, 64, 8)

    chkRoundTripHex(chk, chkRoundTripStuint, 128, 1)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 2)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 3)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 4)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 5)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 6)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 7)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 8)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 9)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 10)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 11)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 12)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 13)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 14)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 15)
    chkRoundTripHex(chk, chkRoundTripStuint, 128, 16)

    chkRoundTripOct(chk, chkRoundTripStuint, 8, 1)
    chkRoundTripStuint(chk, "377", 8, 8)

    chkRoundTripOct(chk, chkRoundTripStuint, 16, 1)
    chkRoundTripOct(chk, chkRoundTripStuint, 16, 2)
    chkRoundTripStuint(chk, "377", 16, 8)
    chkRoundTripStuint(chk, "177777", 16, 8)

    chkRoundTripOct(chk, chkRoundTripStuint, 32, 1)
    chkRoundTripOct(chk, chkRoundTripStuint, 32, 2)
    chkRoundTripOct(chk, chkRoundTripStuint, 32, 3)
    chkRoundTripStuint(chk, "377", 32, 8)
    chkRoundTripStuint(chk, "177777", 32, 8)
    chkRoundTripStuint(chk, "37777777777", 32, 8)

    chkRoundTripOct(chk, chkRoundTripStuint, 64, 1)
    chkRoundTripOct(chk, chkRoundTripStuint, 64, 2)
    chkRoundTripOct(chk, chkRoundTripStuint, 64, 3)
    chkRoundTripOct(chk, chkRoundTripStuint, 64, 4)
    chkRoundTripOct(chk, chkRoundTripStuint, 64, 5)
    chkRoundTripOct(chk, chkRoundTripStuint, 64, 6)
    chkRoundTripOct(chk, chkRoundTripStuint, 64, 7)
    chkRoundTripStuint(chk, "377", 64, 8)
    chkRoundTripStuint(chk, "177777", 64, 8)
    chkRoundTripStuint(chk, "37777777777", 64, 8)
    chkRoundTripStuint(chk, "1777777777777777777777", 64, 8)

    chkRoundTripOct(chk, chkRoundTripStuint, 128, 1)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 2)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 3)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 4)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 5)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 6)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 7)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 8)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 9)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 10)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 11)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 12)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 13)
    chkRoundTripOct(chk, chkRoundTripStuint, 128, 14)
    chkRoundTripStuint(chk, "377", 128, 8)
    chkRoundTripStuint(chk, "177777", 128, 8)
    chkRoundTripStuint(chk, "37777777777", 128, 8)
    chkRoundTripStuint(chk, "1777777777777777777777", 128, 8)
    chkRoundTripStuint(chk, "3777777777777777777777777777777777777777777", 128, 8)

    chkRoundTripDec(chk, chkRoundTripStuint, 8, 1)
    chkRoundTripStuint(chk, "255", 8, 10)

    chkRoundTripDec(chk, chkRoundTripStuint, 16, 1)
    chkRoundTripDec(chk, chkRoundTripStuint, 16, 2)
    chkRoundTripStuint(chk, "255", 16, 10)
    chkRoundTripStuint(chk, "65535", 16, 10)

    chkRoundTripDec(chk, chkRoundTripStuint, 32, 1)
    chkRoundTripDec(chk, chkRoundTripStuint, 32, 2)
    chkRoundTripDec(chk, chkRoundTripStuint, 32, 3)
    chkRoundTripStuint(chk, "255", 32, 10)
    chkRoundTripStuint(chk, "65535", 32, 10)
    chkRoundTripStuint(chk, "4294967295", 32, 10)

    chkRoundTripDec(chk, chkRoundTripStuint, 64, 1)
    chkRoundTripDec(chk, chkRoundTripStuint, 64, 2)
    chkRoundTripDec(chk, chkRoundTripStuint, 64, 3)
    chkRoundTripDec(chk, chkRoundTripStuint, 64, 4)
    chkRoundTripDec(chk, chkRoundTripStuint, 64, 5)
    chkRoundTripDec(chk, chkRoundTripStuint, 64, 6)
    chkRoundTripDec(chk, chkRoundTripStuint, 64, 7)
    chkRoundTripStuint(chk, "255", 64, 10)
    chkRoundTripStuint(chk, "65535", 64, 10)
    chkRoundTripStuint(chk, "4294967295", 64, 10)
    chkRoundTripStuint(chk, "18446744073709551615", 64, 10)

    chkRoundTripDec(chk, chkRoundTripStuint, 128, 1)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 2)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 3)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 4)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 5)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 6)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 7)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 8)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 9)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 10)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 11)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 12)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 13)
    chkRoundTripDec(chk, chkRoundTripStuint, 128, 14)
    chkRoundTripStuint(chk, "255", 128, 10)
    chkRoundTripStuint(chk, "65535", 128, 10)
    chkRoundTripStuint(chk, "4294967295", 128, 10)
    chkRoundTripStuint(chk, "18446744073709551615", 128, 10)
    chkRoundTripStuint(chk, "340282366920938463463374607431768211455", 128, 10)

  tst "[stint] parse - toString roundtrip":
    chkRoundTripBin(chk, chkRoundTripStint, 8, 1)
    chkRoundTripStint(chk, "1" & repeat('0', 7), 8, 2)

    chkRoundTripBin(chk, chkRoundTripStint, 16, 1)
    chkRoundTripBin(chk, chkRoundTripStint, 16, 2)
    chkRoundTripStint(chk, "1" & repeat('0', 15), 16, 2)

    chkRoundTripBin(chk, chkRoundTripStint, 32, 1)
    chkRoundTripBin(chk, chkRoundTripStint, 32, 2)
    chkRoundTripBin(chk, chkRoundTripStint, 32, 3)
    chkRoundTripBin(chk, chkRoundTripStint, 32, 4)
    chkRoundTripStint(chk, "1" & repeat('0', 31), 32, 2)

    chkRoundTripBin(chk, chkRoundTripStint, 64, 1)
    chkRoundTripBin(chk, chkRoundTripStint, 64, 2)
    chkRoundTripBin(chk, chkRoundTripStint, 64, 3)
    chkRoundTripBin(chk, chkRoundTripStint, 64, 4)
    chkRoundTripBin(chk, chkRoundTripStint, 64, 5)
    chkRoundTripBin(chk, chkRoundTripStint, 64, 6)
    chkRoundTripBin(chk, chkRoundTripStint, 64, 7)
    chkRoundTripBin(chk, chkRoundTripStint, 64, 8)
    chkRoundTripStint(chk, "1" & repeat('0', 63), 64, 2)

    chkRoundTripBin(chk, chkRoundTripStint, 128, 1)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 2)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 3)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 4)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 5)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 6)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 7)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 8)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 9)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 10)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 11)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 12)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 13)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 14)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 15)
    chkRoundTripBin(chk, chkRoundTripStint, 128, 16)
    chkRoundTripStint(chk, "1" & repeat('0', 127), 128, 2)

    chkRoundTripHex(chk, chkRoundTripStint, 8, 1)
    chkRoundTripStint(chk, "8" & repeat('0', 1), 8, 16)

    chkRoundTripHex(chk, chkRoundTripStint, 16, 1)
    chkRoundTripHex(chk, chkRoundTripStint, 16, 2)
    chkRoundTripStint(chk, "8" & repeat('0', 3), 16, 16)

    chkRoundTripHex(chk, chkRoundTripStint, 32, 1)
    chkRoundTripHex(chk, chkRoundTripStint, 32, 2)
    chkRoundTripHex(chk, chkRoundTripStint, 32, 3)
    chkRoundTripHex(chk, chkRoundTripStint, 32, 4)
    chkRoundTripStint(chk, "8" & repeat('0', 7), 32, 16)

    chkRoundTripHex(chk, chkRoundTripStint, 64, 1)
    chkRoundTripHex(chk, chkRoundTripStint, 64, 2)
    chkRoundTripHex(chk, chkRoundTripStint, 64, 3)
    chkRoundTripHex(chk, chkRoundTripStint, 64, 4)
    chkRoundTripHex(chk, chkRoundTripStint, 64, 5)
    chkRoundTripHex(chk, chkRoundTripStint, 64, 6)
    chkRoundTripHex(chk, chkRoundTripStint, 64, 7)
    chkRoundTripHex(chk, chkRoundTripStint, 64, 8)
    chkRoundTripStint(chk, "8" & repeat('0', 15), 64, 16)

    chkRoundTripHex(chk, chkRoundTripStint, 128, 1)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 2)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 3)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 4)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 5)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 6)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 7)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 8)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 9)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 10)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 11)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 12)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 13)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 14)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 15)
    chkRoundTripHex(chk, chkRoundTripStint, 128, 16)
    chkRoundTripStint(chk, "8" & repeat('0', 31), 128, 16)

    chkRoundTripOct(chk, chkRoundTripStint, 8, 1)
    chkRoundTripStint(chk, "377", 8, 8)
    chkRoundTripStint(chk, "200", 8, 8)

    chkRoundTripOct(chk, chkRoundTripStint, 16, 1)
    chkRoundTripOct(chk, chkRoundTripStint, 16, 2)
    chkRoundTripStint(chk, "377", 16, 8)
    chkRoundTripStint(chk, "200", 16, 8)
    chkRoundTripStint(chk, "177777", 16, 8)
    chkRoundTripStint(chk, "100000", 16, 8)

    chkRoundTripOct(chk, chkRoundTripStint, 32, 1)
    chkRoundTripOct(chk, chkRoundTripStint, 32, 2)
    chkRoundTripOct(chk, chkRoundTripStint, 32, 3)
    chkRoundTripStint(chk, "377", 32, 8)
    chkRoundTripStint(chk, "200", 32, 8)
    chkRoundTripStint(chk, "177777", 32, 8)
    chkRoundTripStint(chk, "100000", 32, 8)
    chkRoundTripStint(chk, "37777777777", 32, 8)
    chkRoundTripStint(chk, "20000000000", 32, 8)

    chkRoundTripOct(chk, chkRoundTripStint, 64, 1)
    chkRoundTripOct(chk, chkRoundTripStint, 64, 2)
    chkRoundTripOct(chk, chkRoundTripStint, 64, 3)
    chkRoundTripOct(chk, chkRoundTripStint, 64, 4)
    chkRoundTripOct(chk, chkRoundTripStint, 64, 5)
    chkRoundTripOct(chk, chkRoundTripStint, 64, 6)
    chkRoundTripOct(chk, chkRoundTripStint, 64, 7)
    chkRoundTripStint(chk, "377", 64, 8)
    chkRoundTripStint(chk, "200", 64, 8)
    chkRoundTripStint(chk, "177777", 64, 8)
    chkRoundTripStint(chk, "100000", 64, 8)
    chkRoundTripStint(chk, "37777777777", 64, 8)
    chkRoundTripStint(chk, "20000000000", 64, 8)
    chkRoundTripStint(chk, "1777777777777777777777", 64, 8)
    chkRoundTripStint(chk, "1000000000000000000000", 64, 8)

    chkRoundTripOct(chk, chkRoundTripStint, 128, 1)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 2)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 3)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 4)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 5)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 6)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 7)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 8)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 9)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 10)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 11)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 12)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 13)
    chkRoundTripOct(chk, chkRoundTripStint, 128, 14)
    chkRoundTripStint(chk, "377", 128, 8)
    chkRoundTripStint(chk, "200", 128, 8)
    chkRoundTripStint(chk, "177777", 128, 8)
    chkRoundTripStint(chk, "100000", 128, 8)
    chkRoundTripStint(chk, "37777777777", 128, 8)
    chkRoundTripStint(chk, "20000000000", 128, 8)
    chkRoundTripStint(chk, "1777777777777777777777", 128, 8)
    chkRoundTripStint(chk, "1000000000000000000000", 128, 8)
    chkRoundTripStint(chk, "3777777777777777777777777777777777777777777", 128, 8)
    chkRoundTripStint(chk, "2000000000000000000000000000000000000000000", 128, 8)

    chkRoundTripDec(chk, chkRoundTripStint, 8, 1)
    chkRoundTripStint(chk, "127", 8, 10)
    chkRoundTripStint(chk, "-127", 8, 10)
    # chkRoundTripStint(chk, "-128", 8, 10) # TODO: not supported yet

    chkRoundTripDec(chk, chkRoundTripStint, 16, 1)
    chkRoundTripDec(chk, chkRoundTripStint, 16, 2)
    chkRoundTripStint(chk, "255", 16, 10)
    chkRoundTripStint(chk, "127", 16, 10)
    chkRoundTripStint(chk, "-128", 16, 10)
    chkRoundTripStint(chk, "32767", 16, 10)
    chkRoundTripStint(chk, "-32767", 16, 10)
    #chkRoundTripStint(chk, "-32768", 16, 10) # TODO: not supported yet

    chkRoundTripDec(chk, chkRoundTripStint, 32, 1)
    chkRoundTripDec(chk, chkRoundTripStint, 32, 2)
    chkRoundTripDec(chk, chkRoundTripStint, 32, 3)
    chkRoundTripStint(chk, "255", 32, 10)
    chkRoundTripStint(chk, "127", 32, 10)
    chkRoundTripStint(chk, "-128", 32, 10)
    chkRoundTripStint(chk, "32767", 32, 10)
    chkRoundTripStint(chk, "-32768", 32, 10)
    chkRoundTripStint(chk, "65535", 32, 10)
    chkRoundTripStint(chk, "-2147483647", 32, 10)
    #chkRoundTripStint(chk, "-2147483648", 32, 10) # TODO: not supported yet

    chkRoundTripDec(chk, chkRoundTripStint, 64, 1)
    chkRoundTripDec(chk, chkRoundTripStint, 64, 2)
    chkRoundTripDec(chk, chkRoundTripStint, 64, 3)
    chkRoundTripDec(chk, chkRoundTripStint, 64, 4)
    chkRoundTripDec(chk, chkRoundTripStint, 64, 5)
    chkRoundTripDec(chk, chkRoundTripStint, 64, 6)
    chkRoundTripDec(chk, chkRoundTripStint, 64, 7)
    chkRoundTripStint(chk, "255", 64, 10)
    chkRoundTripStint(chk, "65535", 64, 10)
    chkRoundTripStint(chk, "127", 64, 10)
    chkRoundTripStint(chk, "-128", 64, 10)
    chkRoundTripStint(chk, "32767", 64, 10)
    chkRoundTripStint(chk, "-32768", 64, 10)
    chkRoundTripStint(chk, "65535", 64, 10)
    chkRoundTripStint(chk, "-2147483648", 64, 10)
    chkRoundTripStint(chk, "4294967295", 64, 10)
    chkRoundTripStint(chk, "-9223372036854775807", 64, 10)
    #chkRoundTripStint(chk, "-9223372036854775808", 64, 10) # TODO: not supported yet

    chkRoundTripDec(chk, chkRoundTripStint, 128, 1)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 2)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 3)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 4)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 5)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 6)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 7)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 8)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 9)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 10)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 11)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 12)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 13)
    chkRoundTripDec(chk, chkRoundTripStint, 128, 14)
    chkRoundTripStint(chk, "255", 128, 10)
    chkRoundTripStint(chk, "65535", 128, 10)
    chkRoundTripStint(chk, "4294967295", 128, 10)
    chkRoundTripStint(chk, "18446744073709551615", 128, 10)
    chkRoundTripStint(chk, "-170141183460469231731687303715884105727", 128, 10)
    #chkRoundTripStint(chk, "-170141183460469231731687303715884105728", 128, 10) # TODO: not supported yet

  tst "roundtrip initFromBytesBE and toByteArrayBE":
    chkRoundtripBE(chk, "x", 8)
    chkRoundtripBE(chk, "xy", 16)
    chkRoundtripBE(chk, "xyzw", 32)
    chkRoundtripBE(chk, "xyzwabcd", 64)
    chkRoundtripBE(chk, "xyzwabcd12345678", 128)
    chkRoundtripBE(chk, "xyzwabcd12345678kilimanjarohello", 256)

  tst "[stuint] dumpHex":
    chkDumpHexStuint(chk, "ab", "ab", 8)

    chkDumpHexStuint(chk, "00ab", "ab00", 16)
    chkDumpHexStuint(chk, "abcd", "cdab", 16)

    chkDumpHexStuint(chk, "000000ab", "ab000000", 32)
    chkDumpHexStuint(chk, "3412abcd", "cdab1234", 32)

    chkDumpHexStuint(chk, "00000000000000ab", "ab00000000000000", 64)
    chkDumpHexStuint(chk, "abcdef0012345678", "7856341200efcdab", 64)

    chkDumpHexStuint(chk, "abcdef0012345678abcdef1122334455", "5544332211efcdab7856341200efcdab", 128)

  tst "[stint] dumpHex":
    chkDumpHexStint(chk, "ab", "ab", 8)

    chkDumpHexStint(chk, "00ab", "ab00", 16)
    chkDumpHexStint(chk, "abcd", "cdab", 16)

    chkDumpHexStint(chk, "000000ab", "ab000000", 32)
    chkDumpHexStint(chk, "3412abcd", "cdab1234", 32)

    chkDumpHexStint(chk, "00000000000000ab", "ab00000000000000", 64)
    chkDumpHexStint(chk, "abcdef0012345678", "7856341200efcdab", 64)

    chkDumpHexStint(chk, "abcdef0012345678abcdef1122334455", "5544332211efcdab7856341200efcdab", 128)

static:
  testIO(ctCheck, ctTest)

proc main() =
  # Nim GC protests we are using too much global variables
  # so put it in a proc
  suite "Testing input and output procedures":
    testIO(check, test)

    # dumpHex

    test "toByteArrayBE CT vs RT":
      chkCTvsRT(check, 0xab'u8, 8)

      chkCTvsRT(check, 0xab'u16, 16)
      chkCTvsRT(check, 0xabcd'u16, 16)

      chkCTvsRT(check, 0xab'u32, 32)
      chkCTvsRT(check, 0xabcd'u32, 32)
      chkCTvsRT(check, 0xabcdef12'u32, 32)

      chkCTvsRT(check, 0xab'u64, 64)
      chkCTvsRT(check, 0xabcd'u64, 64)
      chkCTvsRT(check, 0xabcdef12'u64, 64)
      chkCTvsRT(check, 0xabcdef12abcdef12'u64, 64)

      chkCTvsRT(check, 0xab'u64, 128)
      chkCTvsRT(check, 0xabcd'u64, 128)
      chkCTvsRT(check, 0xabcdef12'u64, 128)
      chkCTvsRT(check, 0xabcdef12abcdef12'u64, 128)

    test "Creation from decimal strings":
      block:
        let a = "123456789".parse(StInt[64])
        let b = 123456789.stint(64)

        check: a == b
        check: 123456789'i64 == cast[int64](a)

      block:
        let a = "123456789".parse(StUint[64])
        let b = 123456789.stuint(64)

        check: a == b
        check: 123456789'u64 == cast[uint64](a)

      block:
        let a = "-123456789".parse(StInt[64])
        let b = (-123456789).stint(64)

        check: a == b
        check: -123456789'i64 == cast[int64](a)

    test "Creation from binary strings":
      block:
        for i in 0..255:
          let a = fmt("{i:#b}").parse(StInt[64], radix = 2)
          let b = i.stint(64)

          check: a == b
          check: int64(i) == cast[int64](a)

      block:
        for i in 0..255:
          let a = fmt("{i:#b}").parse(StUint[64], radix = 2)
          let b = i.stuint(64)

          check: a == b
          check: uint64(i) == cast[uint64](a)

      block:
        let a = "0b1111111111111111".parse(StInt[16], 2)
        let b = (-1'i16).stint(16)

        check: a == b
        check: -1'i16 == cast[int16](a)

    test "Creation from octal strings":
      block:
        for i in 0..255:
          let a = fmt("{i:#o}").parse(StInt[64], radix = 8)
          let b = i.stint(64)

          check: a == b
          check: int64(i) == cast[int64](a)

      block:
        for i in 0..255:
          let a = fmt("{i:#o}").parse(StUint[64], radix = 8)
          let b = i.stuint(64)

          check: a == b
          check: uint64(i) == cast[uint64](a)

      block:
        let a = "0o177777".parse(StInt[16], 8)
        let b = (-1'i16).stint(16)

        check: a == b
        check: -1'i16 == cast[int16](a)

    test "Creation from hex strings":
      block:
        for i in 0..255:
          let a = fmt("{i:#x}").parse(StInt[64], radix = 16)
          let aUppercase = fmt("{i:#X}").parse(StInt[64], radix = 16)
          let b = i.stint(64)

          check: a == aUppercase
          check: a == b
          check: int64(i) == cast[int64](a)

      block:
        for i in 0..255:
          let a = fmt("{i:#x}").parse(StUint[64], radix = 16)
          let aUppercase = fmt("{i:#X}").parse(StUint[64], radix = 16)
          let b = i.stuint(64)

          check: a == aUppercase
          check: a == b
          check: uint64(i) == cast[uint64](a)

          let a2 = hexToUint[64](fmt("{i:#x}"))
          let a3 = hexToUint[64](fmt("{i:#X}"))
          check: a == a2
          check: a == a3

      block:
        let a = "0xFFFF".parse(StInt[16], 16)
        let b = (-1'i16).stint(16)

        check: a == b
        check: -1'i16 == cast[int16](a)

      block:
        let a = "0b1234abcdef".parse(StInt[64], 16)
        let b = "0x0b1234abcdef".parse(StInt[64], 16)
        let c = 0x0b1234abcdef.stint(64)

        check: a == b
        check: a == c
        
    test "Conversion to decimal strings":
      block:
        let a = 1234567891234567890.stint(128)
        check: a.toString == "1234567891234567890"
        check: $a == "1234567891234567890"

      block:
        let a = 1234567891234567890.stuint(128)
        check: a.toString == "1234567891234567890"
        check: $a == "1234567891234567890"

      block:
        let a = (-1234567891234567890).stint(128)
        check: a.toString == "-1234567891234567890"
        check: $a == "-1234567891234567890"

    test "Conversion to hex strings":
      block:
        let a = 0x1234567890ABCDEF.stint(128)
        check: a.toHex.toUpperAscii == "1234567890ABCDEF"

      block:
        let a = 0x1234567890ABCDEF.stuint(128)
        check: a.toHex.toUpperAscii == "1234567890ABCDEF"

      # TODO: negative hex

    test "Hex dump":
      block:
        let a = 0x1234'i32.stint(32)
        check: a.dumpHex(bigEndian).toUpperAscii == "00001234"

      block:
        let a = 0x1234'i32.stint(32)
        check: a.dumpHex(littleEndian).toUpperAscii == "34120000"

    test "Back and forth bigint conversion consistency":
      block:
        let s = "1234567890123456789012345678901234567890123456789"
        let a = parse(s, StInt[512])
        check: a.toString == s
        check: $a == s

      block:
        let s = "1234567890123456789012345678901234567890123456789"
        let a = parse(s, StUint[512])
        check: a.toString == s
        check: $a == s

    test "Truncate: int, int64, uint, uint64":
      block:
        let x = 100.stuint(128)
        check:
          x.truncate(int) == 100
          x.truncate(int64) == 100'i64
          x.truncate(uint64) == 100'u64
          x.truncate(uint) == 100'u
      block:
        let x = pow(2.stuint(128), 64) + 1
        check:
          # x.truncate(int) == 1 # This is undefined
          # x.truncate(int64) == 1'i64 # This is undefined
          x.truncate(uint64) == 1'u64
          x.truncate(uint) == 1'u

    test "toInt, toInt64, toUint, toUint64 - word size (32/64-it) specific":
      when not defined(stint_test):
        # stint_test forces word size of 32-bit
        # while stint uses uint64 by default.
        block:
          let x = pow(2.stuint(128), 32) + 1
          when sizeof(int) == 4: # 32-bit machines
            check:
              x.truncate(uint) == 1'u
              x.truncate(uint64) == 2'u64^32 + 1
          else:
            check:
              x.truncate(uint) == 2'u^32 + 1
              x.truncate(uint64) == 2'u64^32 + 1
      else:
        echo "Next test skipped when Stint forces uint32 backend in test mode"

    test "Parsing an unexpected 0x prefix for a decimal string is a CatchableError and not a defect":
      let s = "0x123456"

      expect(ValueError):
        let value = parse(s, StUint[256], 10)

  suite "Testing conversion functions: Hex, Bytes, Endianness using secp256k1 curve":

    let
      SECPK1_N_HEX = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141".toLowerAscii
      SECPK1_N = "115792089237316195423570985008687907852837564279074904382605163141518161494337".u256
      SECPK1_N_BYTES = [byte(255), 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 186, 174, 220, 230, 175, 72, 160, 59, 191, 210, 94, 140, 208, 54, 65, 65]

    test "explicit conversions from basic types":
      type
        UInt256 = StUint[256]
        Int128 = StInt[128]

      let x = 10.uint16

      check:
        x.to(UInt256).bits == 256
        x.to(Int128).bits == 128

    test "hex -> uint256":
      check: SECPK1_N_HEX.parse(StUint[256], radix = 16) == SECPK1_N

    test "uint256 -> hex":
      check: SECPK1_N.dumpHex == SECPK1_N_HEX

    test "hex -> big-endian array -> uint256":
      check: readUintBE[256](SECPK1_N_BYTES) == SECPK1_N

    test "uint256 -> minimal big-endian array -> uint256":
      # test drive the conversion logic by testing the first 25 factorials:
      var f = 1.stuint(256)
      for i in 2 .. 25:
        f = f * i.stuint(256)
        let
          bytes = f.toByteArrayBE
          nonZeroBytes = significantBytesBE(bytes)
          fRestored = UInt256.fromBytesBE(bytes.toOpenArray(bytes.len - nonZeroBytes,
                                                            bytes.len - 1))
        check f == fRestored

    test "uint256 -> big-endian array -> hex":
      check: SECPK1_N.toByteArrayBE == SECPK1_N_BYTES

    # This is a sample of signatures generated with a known-good implementation of the ECDSA
    # algorithm, which we use to test our ECC backends. If necessary, it can be generated from scratch
    # with the following code:
    #
    # """python
    # from devp2p import crypto
    # from eth_utils import encode_hex
    # msg = b'message'
    # msghash = crypto.sha3(b'message')
    # for secret in ['alice', 'bob', 'eve']:
    #     print("'{}': dict(".format(secret))
    #     privkey = crypto.mk_privkey(secret)
    #     pubkey = crypto.privtopub(privkey)
    #     print("    privkey='{}',".format(encode_hex(privkey)))
    #     print("    pubkey='{}',".format(encode_hex(crypto.privtopub(privkey))))
    #     ecc = crypto.ECCx(raw_privkey=privkey)
    #     sig = ecc.sign(msghash)
    #     print("    sig='{}',".format(encode_hex(sig)))
    #     print("    raw_sig='{}')".format(crypto._decode_sig(sig)))
    #     doAssert crypto.ecdsa_recover(msghash, sig) == pubkey
    # """

    type
      testKeySig = object
        privkey*: string
        pubkey*: string
        raw_sig*: tuple[v: int, r, s: string]
        serialized_sig*: string

    let
      alice = testKeySig(
        privkey: "9c0257114eb9399a2985f8e75dad7600c5d89fe3824ffa99ec1c3eb8bf3b0501",
        pubkey: "5eed5fa3a67696c334762bb4823e585e2ee579aba3558d9955296d6c04541b426078dbd48d74af1fd0c72aa1a05147cf17be6b60bdbed6ba19b08ec28445b0ca",
        raw_sig: (
          v: 1,
          r: "B20E2EA5D3CBAA83C1E0372F110CF12535648613B479B64C1A8C1A20C5021F38", # Decimal "80536744857756143861726945576089915884233437828013729338039544043241440681784",
          s: "0434D07EC5795E3F789794351658E80B7FAF47A46328F41E019D7B853745CDFD"  # Decimal "1902566422691403459035240420865094128779958320521066670269403689808757640701"
        ),
        serialized_sig: "b20e2ea5d3cbaa83c1e0372f110cf12535648613b479b64c1a8c1a20c5021f380434d07ec5795e3f789794351658e80b7faf47a46328f41e019d7b853745cdfd01"
      )

      bob = testKeySig(
        privkey: "38e47a7b719dce63662aeaf43440326f551b8a7ee198cee35cb5d517f2d296a2",
        pubkey: "347746ccb908e583927285fa4bd202f08e2f82f09c920233d89c47c79e48f937d049130e3d1c14cf7b21afefc057f71da73dec8e8ff74ff47dc6a574ccd5d570",
        raw_sig: (
          v: 1,
          r: "5C48EA4F0F2257FA23BD25E6FCB0B75BBE2FF9BBDA0167118DAB2BB6E31BA76E", # Decimal "41741612198399299636429810387160790514780876799439767175315078161978521003886",
          s: "691DBDAF2A231FC9958CD8EDD99507121F8184042E075CF10F98BA88ABFF1F36"  # Decimal "47545396818609319588074484786899049290652725314938191835667190243225814114102"
          ),
          serialized_sig: "5c48ea4f0f2257fa23bd25e6fcb0b75bbe2ff9bbda0167118dab2bb6e31ba76e691dbdaf2a231fc9958cd8edd99507121f8184042e075cf10f98ba88abff1f3601"
        )

      eve = testKeySig(
        privkey: "876be0999ed9b7fc26f1b270903ef7b0c35291f89407903270fea611c85f515c",
        pubkey: "c06641f0d04f64dba13eac9e52999f2d10a1ff0ca68975716b6583dee0318d91e7c2aed363ed22edeba2215b03f6237184833fd7d4ad65f75c2c1d5ea0abecc0",
        raw_sig: (
          v: 0,
          r: "BABEEFC5082D3CA2E0BC80532AB38F9CFB196FB9977401B2F6A98061F15ED603", # Decimal "84467545608142925331782333363288012579669270632210954476013542647119929595395",
          s: "603D0AF084BF906B2CDF6CDDE8B2E1C3E51A41AF5E9ADEC7F3643B3F1AA2AADF"  # Decimal "43529886636775750164425297556346136250671451061152161143648812009114516499167"
          ),
          serialized_sig: "babeefc5082d3ca2e0bc80532ab38f9cfb196fb9977401b2f6a98061f15ed603603d0af084bf906b2cdf6cdde8b2e1c3e51a41af5e9adec7f3643b3f1aa2aadf00"
      )

    test "Alice signature":
      check: alice.raw_sig.r.parse(StUint[256], 16) == "80536744857756143861726945576089915884233437828013729338039544043241440681784".u256
      check: alice.raw_sig.s.parse(StUint[256], 16) == "1902566422691403459035240420865094128779958320521066670269403689808757640701".u256

    test "Bob signature":
      check: bob.raw_sig.r.parse(StUint[256], 16) == "41741612198399299636429810387160790514780876799439767175315078161978521003886".u256
      check: bob.raw_sig.s.parse(StUint[256], 16) == "47545396818609319588074484786899049290652725314938191835667190243225814114102".u256

    test "Eve signature":
      check: eve.raw_sig.r.parse(StUint[256], 16) == "84467545608142925331782333363288012579669270632210954476013542647119929595395".u256
      check: eve.raw_sig.s.parse(StUint[256], 16) == "43529886636775750164425297556346136250671451061152161143648812009114516499167".u256

    test "Using stint values in a hash table":
      block:
        var t = initTable[UInt128, string]()

        var numbers = @[
          parse("0", UInt128),
          parse("122342408432", UInt128),
          parse("23853895230124238754328", UInt128),
          parse("4539086493082871342142388475734534753453", UInt128),
        ]

        for n in numbers:
          t[n] = $n

        for n in numbers:
          check t[n] == $n

      block:
        var t = initTable[Int256, string]()

        var numbers = @[
          parse("0", Int256),
          parse("-1", Int256),
          parse("-12315123298", Int256),
          parse("23853895230124238754328", Int256),
          parse("-3429023852897428742874325245342129842", Int256),
        ]

        for n in numbers:
          t[n] = $n

        for n in numbers:
          check t[n] == $n

main()

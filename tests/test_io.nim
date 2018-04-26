# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/stint, unittest, strutils

suite "Testing input and output procedures":
  test "Creation from decimal strings":
    block:
      let a = parse(Stint[64], "123456789")
      let b = 123456789.stint(64)

      check: a == b
      check: 123456789'i64 == cast[int64](a)

    block:
      let a = parse(Stuint[64], "123456789")
      let b = 123456789.stuint(64)

      check: a == b
      check: 123456789'u64 == cast[uint64](a)

    block:
      let a = parse(Stint[64], "-123456789")
      let b = (-123456789).stint(64)

      check: a == b
      check: -123456789'i64 == cast[int64](a)

  test "Creation from hex strings":
    block:
      let a = parse(Stint[64], "0xFF", 16)
      let b = 255.stint(64)

      check: a == b
      check: 255'i64 == cast[int64](a)

    block:
      let a = parse(Stuint[64], "0xFF", 16)
      let b = 255.stuint(64)

      check: a == b
      check: 255'u64 == cast[uint64](a)

    block:
      let a = parse(Stint[16], "0xFFFF", 16)
      let b = (-1'i16).stint(16)

      check: a == b
      check: -1'i16 == cast[int16](a)

  test "Conversion to decimal strings":
    block:
      let a = 1234567891234567890.stint(128)
      check: a.toString == "1234567891234567890"

    block:
      let a = 1234567891234567890.stuint(128)
      check: a.toString == "1234567891234567890"

    block:
      let a = (-1234567891234567890).stint(128)
      check: a.toString == "-1234567891234567890"

  test "Conversion to hex strings":
    block:
      let a = 0x1234567890ABCDEF.stint(128)
      check: a.toString(base = 16).toUpperAscii == "1234567890ABCDEF"

    block:
      let a = 0x1234567890ABCDEF.stuint(128)
      check: a.toString(base = 16).toUpperAscii == "1234567890ABCDEF"

    # TODO: negative hex

  test "Hex dump":
    block:
      let a = 0x1234'i32.stint(32)
      check: a.dumpHex(bigEndian).toUpperAscii == "00001234"

    block:
      let a = 0x1234'i32.stint(32)
      check: a.dumpHex(littleEndian).toUpperAscii == "34120000"

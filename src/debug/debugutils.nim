# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

# Utilities to debug MpInt

import
  strutils,
  ../private/[uint_type, size_mpuintimpl]

func tohexBE*[T: uint8 or uint16 or uint32 or uint64](x: T): string =
  ## Stringify an uint to hex, Most significant byte on the left
  ## i.e. a 1.uint64 will be 00000001

  let bytes = cast[ptr array[T.sizeof, byte]](x.unsafeaddr)

  result = ""
  when system.cpuEndian == littleEndian:
    for i in countdown(T.sizeof - 1, 0):
      result.add toHex(bytes[i])
  else:
    for i in 0 ..< T.sizeof:
      result.add toHex(bytes[i])

func tohexBE*(x: MpUintImpl): string =
  ## Stringify an uint to hex, Most significant byte on the left
  ## i.e. a (2.uint128)^64 + 1 will be 0000000100000001

  const size = size_mpuintimpl(x) div 8

  let bytes = cast[ptr array[size, byte]](x.unsafeaddr)

  result = ""
  when system.cpuEndian == littleEndian:
    for i in countdown(size - 1, 0):
      result.add toHex(bytes[i])
  else:
    for i in 0 ..< size:
      result.add toHex(bytes[i])

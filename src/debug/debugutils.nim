# Stint
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
  ../private/datatypes

func tohexBE*(x: UintImpl or IntImpl or SomeInteger): string =
  ## Stringify an uint to hex, Most significant byte on the left
  ## i.e.
  ## - 1.uint64 will be 00000001
  ## - (2.uint128)^64 + 1 will be 0000000100000001

  const size = getSize(x) div 8

  let bytes = cast[ptr array[size, byte]](x.unsafeaddr)

  result = ""
  when system.cpuEndian == littleEndian:
    for i in countdown(size - 1, 0):
      result.add toHex(bytes[i])
  else:
    for i in 0 ..< size:
      result.add toHex(bytes[i])

func tohexBE*(x: Stint or StUint): string {.inline.}=
  x.data.tohexBE

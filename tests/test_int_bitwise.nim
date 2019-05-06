# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest

suite "Testing signed int bitwise operations":
  test "Shift Left":
    var y = 1.u256
    var x = 1.i256
    for _ in 1..255:
      y = y shl 1
      x = x shl 1
      check cast[Uint256](x) == y

  test "Shift Right":
    var y = 1.u256 shl 255
    var x = 1.i256 shl 255
    for _ in 1..255:
      y = y shr 1
      x = x shr 1
      check cast[Uint256](x) == y

  test "ashr on positive int":
    var y = 1.u256 shl 254
    var x = cast[Int256](y)

    for _ in 1..255:
      x = ashr(x, 1)
      y = y shr 1
      check x == cast[Int256](y)

  test "ashr on negative int":
    const leftMost = 1.u256 shl 255
    var y = 1.u256 shl 255
    var x = cast[Int256](y)

    for _ in 1..255:
      x = ashr(x, 1)
      y = (y shr 1) or leftMost
      check x == cast[Int256](y)

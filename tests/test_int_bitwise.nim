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
    for i in 1..255:
      let x = 1.i256 shl i
      y = y shl 1
      check cast[Uint256](x) == y

  test "Shift Right":
    const leftMost = 1.i256 shl 255
    var y = 1.u256 shl 255
    for i in 1..255:
      let x = leftMost shr i
      y = y shr 1
      check cast[Uint256](x) == y

  test "ashr on positive int":
    const leftMost = 1.i256 shl 254
    var y = 1.u256 shl 254
    for i in 1..255:
      let x = ashr(leftMost, i)
      y = y shr 1
      check x == cast[Int256](y)

  test "ashr on negative int":
    const
      leftMostU = 1.u256 shl 255
      leftMostI = 1.i256 shl 255
    var y = leftMostU
    for i in 1..255:
      let x = ashr(leftMostI, i)
      y = (y shr 1) or leftMostU
      check x == cast[Int256](y)

  test "Compile time shift":
    const
      # set all bits
      x = high(Int256) or (1.i256 shl 255)
      y = not 0.i256

    check x == y

    const
      a = (high(Int256) shl 10) shr 10
      b = (high(Uint256) shl 10) shr 10
      c = ashr(high(Int256) shl 10, 10)

    check a == cast[Int256](b)
    check c != cast[Int256](b)
    check c != a

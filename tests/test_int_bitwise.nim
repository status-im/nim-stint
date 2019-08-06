# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest

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

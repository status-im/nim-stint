# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/mpint, unittest, quicktest, ttmath

const itercount = 1000

suite "Property-based testing (testing with random inputs) - uint64 on 64-bit / uint32 on 32-bit":

  when defined(release):
    echo "Testing in release mode"
  else:
    echo "Testing in normal (non-release) mode"

  let hi = 1'u shl (sizeof(uint)*7)

  quicktest "`or`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y0: uint(min=0, max=hi),
                                y1: uint(min=0, max=hi),
                                y2: uint(min=0, max=hi),
                                y3: uint(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = cast[ttmath.UInt256](x)
      ttm_y = cast[ttmath.UInt256](y)
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x or ttm_y
      mp_z  = mp_x  or mp_y

    check(cast[array[4, uint64]](ttm_z) == cast[array[4, uint64]](mp_z))


  quicktest "`and`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y0: uint(min=0, max=hi),
                                y1: uint(min=0, max=hi),
                                y2: uint(min=0, max=hi),
                                y3: uint(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = cast[ttmath.UInt256](x)
      ttm_y = cast[ttmath.UInt256](y)
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x and ttm_y
      mp_z  = mp_x  and mp_y

    check(cast[array[4, uint64]](ttm_z) == cast[array[4, uint64]](mp_z))

  quicktest "`xor`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y0: uint(min=0, max=hi),
                                y1: uint(min=0, max=hi),
                                y2: uint(min=0, max=hi),
                                y3: uint(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = cast[ttmath.UInt256](x)
      ttm_y = cast[ttmath.UInt256](y)
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x xor ttm_y
      mp_z  = mp_x  xor mp_y

    check(cast[array[4, uint64]](ttm_z) == cast[array[4, uint64]](mp_z))

  # Not defined for ttmath
  # quicktest "`not`", itercount do(x0: uint(min=0, max=hi),
  #                               x1: uint(min=0, max=hi),
  #                               x2: uint(min=0, max=hi),
  #                               x3: uint(min=0, max=hi):

  #   let
  #     x = [x0, x1, x2, x3]
  #     y = [y0, y1, y2, y3]

  #     ttm_x = cast[ttmath.UInt256](x)
  #     mp_x  = cast[StUint[256]](x)

  #   let
  #     ttm_z = not ttm_x
  #     mp_z  = not mp_x

  #   check(cast[array[4, uint64]](ttm_z) == cast[array[4, uint64]](mp_z))

  quicktest "`<`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y0: uint(min=0, max=hi),
                                y1: uint(min=0, max=hi),
                                y2: uint(min=0, max=hi),
                                y3: uint(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = cast[ttmath.UInt256](x)
      ttm_y = cast[ttmath.UInt256](y)
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x < ttm_y
      mp_z  = mp_x  < mp_y

    check(ttm_z == mp_z)


  quicktest "`<=`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y0: uint(min=0, max=hi),
                                y1: uint(min=0, max=hi),
                                y2: uint(min=0, max=hi),
                                y3: uint(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = cast[ttmath.UInt256](x)
      ttm_y = cast[ttmath.UInt256](y)
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x <= ttm_y
      mp_z  = mp_x  <= mp_y

    check(ttm_z == mp_z)

  quicktest "`+`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y0: uint(min=0, max=hi),
                                y1: uint(min=0, max=hi),
                                y2: uint(min=0, max=hi),
                                y3: uint(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = cast[ttmath.UInt256](x)
      ttm_y = cast[ttmath.UInt256](y)
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x + ttm_y
      mp_z  = mp_x  + mp_y

    check(cast[array[4, uint64]](ttm_z) == cast[array[4, uint64]](mp_z))

  quicktest "`-`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y0: uint(min=0, max=hi),
                                y1: uint(min=0, max=hi),
                                y2: uint(min=0, max=hi),
                                y3: uint(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = cast[ttmath.UInt256](x)
      ttm_y = cast[ttmath.UInt256](y)
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x - ttm_y
      mp_z  = mp_x  - mp_y

    check(cast[array[4, uint64]](ttm_z) == cast[array[4, uint64]](mp_z))

  quicktest "`*`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y0: uint(min=0, max=hi),
                                y1: uint(min=0, max=hi),
                                y2: uint(min=0, max=hi),
                                y3: uint(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = cast[ttmath.UInt256](x)
      ttm_y = cast[ttmath.UInt256](y)
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x * ttm_y
      mp_z  = mp_x  * mp_y

    check(cast[array[4, uint64]](ttm_z) == cast[array[4, uint64]](mp_z))

  quicktest "`shl`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y: int(min = 0, max=(255))):

    let
      x = [x0, x1, x2, x3]

      ttm_x = cast[ttmath.UInt256](x)
      mp_x  = cast[StUint[256]](x)

    let
      ttm_z = ttm_x shl y
      mp_z  = mp_x  shl y

    check(cast[array[4, uint64]](ttm_z) == cast[array[4, uint64]](mp_z))

  quicktest "`shr`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y: int(min = 0, max=(255))):

    let
      x = [x0, x1, x2, x3]

      ttm_x = cast[ttmath.UInt256](x)
      mp_x  = cast[StUint[256]](x)

    let
      ttm_z = ttm_x shr y
      mp_z  = mp_x  shr y

    check(cast[array[4, uint64]](ttm_z) == cast[array[4, uint64]](mp_z))

  quicktest "`mod`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y0: uint(min=0, max=hi),
                                y1: uint(min=0, max=hi),
                                y2: uint(min=0, max=hi),
                                y3: uint(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = cast[ttmath.UInt256](x)
      ttm_y = cast[ttmath.UInt256](y)
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x mod ttm_y
      mp_z  = mp_x  mod mp_y

  quicktest "`div`", itercount do(x0: uint(min=0, max=hi),
                                x1: uint(min=0, max=hi),
                                x2: uint(min=0, max=hi),
                                x3: uint(min=0, max=hi),
                                y0: uint(min=0, max=hi),
                                y1: uint(min=0, max=hi),
                                y2: uint(min=0, max=hi),
                                y3: uint(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = cast[ttmath.UInt256](x)
      ttm_y = cast[ttmath.UInt256](y)
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x div ttm_y
      mp_z  = mp_x  div mp_y
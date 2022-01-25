# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.


# Requires "https://github.com/status-im/nim-ttmath#master"
# Note that currently importing both Stint and TTMath will crash the compiler for unknown reason
import ../stint, unittest, quicktest, ttmath_compat

const itercount = 10_000

suite "Property-based testing (testing with random inputs) of Uint256":

  when defined(release):
    echo "Testing in release mode with " & $itercount & " random tests for each proc."
  else:
    echo "Testing in debug mode " & $itercount & " random tests for each proc. (StUint[64] = 2x uint32)"

  let hi = 1'u shl (sizeof(uint64)*7)

  quicktest "`or`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y0: uint64(min=0, max=hi),
                                y1: uint64(min=0, max=hi),
                                y2: uint64(min=0, max=hi),
                                y3: uint64(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = x.asTT
      ttm_y = y.asTT
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x or ttm_y
      mp_z  = mp_x  or mp_y

    check ttm_z.asSt == mp_z

  quicktest "`and`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y0: uint64(min=0, max=hi),
                                y1: uint64(min=0, max=hi),
                                y2: uint64(min=0, max=hi),
                                y3: uint64(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = x.asTT
      ttm_y = y.asTT
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x and ttm_y
      mp_z  = mp_x  and mp_y

    check ttm_z.asSt == mp_z

  quicktest "`xor`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y0: uint64(min=0, max=hi),
                                y1: uint64(min=0, max=hi),
                                y2: uint64(min=0, max=hi),
                                y3: uint64(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = x.asTT
      ttm_y = y.asTT
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x xor ttm_y
      mp_z  = mp_x  xor mp_y

    check ttm_z.asSt == mp_z

  # Not defined for ttmath
  # quicktest "`not`", itercount do(x0: uint64(min=0, max=hi),
  #                               x1: uint64(min=0, max=hi),
  #                               x2: uint64(min=0, max=hi),
  #                               x3: uint64(min=0, max=hi):

  #   let
  #     x = [x0, x1, x2, x3]
  #     y = [y0, y1, y2, y3]

  #     ttm_x = cast[ttmath.UInt256](x)
  #     mp_x  = cast[StUint[256]](x)

  #   let
  #     ttm_z = not ttm_x
  #     mp_z  = not mp_x

  #   check(cast[array[4, uint64]](ttm_z) == cast[array[4, uint64]](mp_z))

  quicktest "`<`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y0: uint64(min=0, max=hi),
                                y1: uint64(min=0, max=hi),
                                y2: uint64(min=0, max=hi),
                                y3: uint64(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = x.asTT
      ttm_y = y.asTT
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x < ttm_y
      mp_z  = mp_x  < mp_y

    check(ttm_z == mp_z)


  quicktest "`<=`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y0: uint64(min=0, max=hi),
                                y1: uint64(min=0, max=hi),
                                y2: uint64(min=0, max=hi),
                                y3: uint64(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = x.asTT
      ttm_y = y.asTT
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x <= ttm_y
      mp_z  = mp_x  <= mp_y

    check(ttm_z == mp_z)

  quicktest "`+`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y0: uint64(min=0, max=hi),
                                y1: uint64(min=0, max=hi),
                                y2: uint64(min=0, max=hi),
                                y3: uint64(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = x.asTT
      ttm_y = y.asTT
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x + ttm_y
      mp_z  = mp_x  + mp_y

    check ttm_z.asSt == mp_z

  quicktest "`-`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y0: uint64(min=0, max=hi),
                                y1: uint64(min=0, max=hi),
                                y2: uint64(min=0, max=hi),
                                y3: uint64(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = x.asTT
      ttm_y = y.asTT
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x - ttm_y
      mp_z  = mp_x  - mp_y

    check ttm_z.asSt == mp_z

  quicktest "`*`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y0: uint64(min=0, max=hi),
                                y1: uint64(min=0, max=hi),
                                y2: uint64(min=0, max=hi),
                                y3: uint64(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = x.asTT
      ttm_y = y.asTT
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x * ttm_y
      mp_z  = mp_x  * mp_y

    check ttm_z.asSt == mp_z

  quicktest "`shl`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y: int(min = 0, max=(255))):

    let
      x = [x0, x1, x2, x3]

      ttm_x = x.asTT
      mp_x  = cast[StUint[256]](x)

    let
      ttm_z = ttm_x shl y.uint
      mp_z  = mp_x  shl y

    check ttm_z.asSt == mp_z

  quicktest "`shr`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y: int(min = 0, max=(255))):

    let
      x = [x0, x1, x2, x3]

      ttm_x = x.asTT
      mp_x  = cast[StUint[256]](x)

    let
      ttm_z = ttm_x shr y.uint
      mp_z  = mp_x  shr y

    check ttm_z.asSt == mp_z

  quicktest "`mod`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y0: uint64(min=0, max=hi),
                                y1: uint64(min=0, max=hi),
                                y2: uint64(min=0, max=hi),
                                y3: uint64(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = x.asTT
      ttm_y = y.asTT
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x mod ttm_y
      mp_z  = mp_x  mod mp_y

    check ttm_z.asSt == mp_z

  quicktest "`div`", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y0: uint64(min=0, max=hi),
                                y1: uint64(min=0, max=hi),
                                y2: uint64(min=0, max=hi),
                                y3: uint64(min=0, max=hi)):

    let
      x = [x0, x1, x2, x3]
      y = [y0, y1, y2, y3]

      ttm_x = x.asTT
      ttm_y = y.asTT
      mp_x  = cast[StUint[256]](x)
      mp_y  = cast[StUint[256]](y)

    let
      ttm_z = ttm_x div ttm_y
      mp_z  = mp_x  div mp_y

    check ttm_z.asSt == mp_z

  quicktest "pow", itercount do(x0: uint64(min=0, max=hi),
                                x1: uint64(min=0, max=hi),
                                x2: uint64(min=0, max=hi),
                                x3: uint64(min=0, max=hi),
                                y : int(min=0, max=high(int))):

    let
      x = [x0, x1, x2, x3]
      ttm_x = x.asTT
      mp_x  = cast[StUint[256]](x)

    let
      ttm_z = ttm_x.pow(y.uint)
      mp_z  = mp_x.pow y

    check ttm_z.asSt == mp_z

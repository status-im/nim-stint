# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/mpint, unittest

suite "Testing comparison operators":
  let
    a = 10.initMpUint(16)
    b = 15.initMpUint(16)
    c = 150'u16
    d = 4.initMpUint(128) shl 64
    e = 4.initMpUint(128)
    f = 4.initMpUint(128) shl 65

  test "< operator":
    check:
      a < b
      not (a + b < b)
      not (a + a + a < b + b)
      not (a * b < cast[MpUint[16]](c))
      e < d
      d < f

  test "<= operator":
    check:
      a <= b
      not (a + b <= b)
      a + a + a <= b + b
      a * b <= cast[MpUint[16]](c)
      e <= d
      d <= f

  test "> operator":
    check:
      b > a
      not (b > a + b)
      not (b + b > a + a + a)
      not (cast[Mpuint[16]](c) > a * b)
      d > e
      f > d

  test ">= operator":
    check:
      b >= a
      not (b >= a + b)
      b + b >= a + a + a
      cast[MpUint[16]](c) >= a * b
      d >= e
      f >= d

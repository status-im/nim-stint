# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import ../src/mpint, unittest

suite "Testing comparison operators":
  let
    a = initMpUint(10, uint8)
    b = initMpUint(15, uint8)
    c = 150'u16

  test "< operator":
    check: a < b
    check: not (a + b < b)
    check: not (a + a + a < b + b)
    check: not (a * b < cast[Mpuint[uint8]](c))

  test "<= operator":
    check: a <= b
    check: not (a + b <= b)
    check: a + a + a <= b + b
    check: a * b <= cast[Mpuint[uint8]](c)

  test "> operator":
    check: b > a
    check: not (b > a + b)
    check: not (b + b > a + a + a)
    check: not (cast[Mpuint[uint8]](c) > a * b)

  test ">= operator":
    check: b >= a
    check: not (b >= a + b)
    check: b + b >= a + a + a
    check: cast[Mpuint[uint8]](c) >= a * b
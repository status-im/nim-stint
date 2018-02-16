# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import ../src/mpint, unittest

suite "Testing bitwise operations":
  let a = initMpUint(100, uint8)

  let b = a * a
  let z = 10000'u16

  test "Shift left - by less than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shl 2) == z shl 2

  test "Shift left - by more than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shl 10) == z shl 10

  test "Shift left - by half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shl 8) == z shl 8

  test "Shift right - by less than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 2) == z shr 2

  test "Shift right - by more than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 10) == z shr 10

  test "Shift right - by half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 8) == z shr 8

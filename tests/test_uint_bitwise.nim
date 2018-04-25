# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/stint, unittest

suite "Testing unsigned int bitwise operations":
  let a = 100'i16.stuint(16)

  let b = a * a
  let z = 10000'u16
  assert cast[uint16](b) == z, "Test cannot proceed, something is wrong with the multiplication implementation"


  let u = 10000.stuint(64)
  let v = 10000'u64
  let clz = 30

  test "Shift left - by less than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shl 2) == z shl 2

  test "Shift left - by more than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shl 10) == z shl 10

    check: cast[uint64](u shl clz) == v shl clz

  test "Shift left - by half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shl 8) == z shl 8

    block: # Testing shl for nested UintImpl
      let p2_64 = UintImpl[uint64](hi:1, lo:0)
      let p = 1.stuint(128) shl 64

      check: p == cast[StUint[128]](p2_64)

  test "Shift right - by less than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 2) == z shr 2

  test "Shift right - by more than half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 10) == z shr 10

  test "Shift right - by half the size of the integer":
    check: cast[uint16](b) == z # Sanity check
    check: cast[uint16](b shr 8) == z shr 8

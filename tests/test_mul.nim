# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import ../src/mpint, unittest

suite "Testing multiplication implementation":
  test "Multiplication with result fitting in low half":

    let a = initMpUint(10000, uint32)
    let b = initMpUint(10000, uint32)

    check: cast[uint64](a*b) == 100_000_000'u64 # need 27-bits

  test "Multiplication with result overflowing low half":

    let a = initMpUint(1_000_000, uint32)
    let b = initMpUint(1_000_000, uint32)

    check: cast[uint64](a*b) == 1_000_000_000_000'u64 # need 40 bits

  test "Full overflow is handled like native unsigned types":

    let a = initMpUint(1_000_000_000, uint32)
    let b = initMpUint(1_000_000_000, uint32)
    let c = initMpUint(1_000, uint32)

    check: cast[uint64](a*b*c) == 1_000_000_000_000_000_000_000'u64 # need 70-bits
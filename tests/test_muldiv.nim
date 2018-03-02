# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

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


suite "Testing division and modulo implementation":
  test "Divmod returns the correct result":

    let a = initMpUint(100, uint32)
    let b = initMpUint(13, uint32)
    let qr = a.divmod(b)

    check: cast[uint64](qr.quot) == 7'u64
    check: cast[uint64](qr.rem)  == 9'u64

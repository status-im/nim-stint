# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest

suite "Testing unsigned int multiplication implementation":
  test "Multiplication with result fitting in low half":

    let a = 10000.stuint(64)
    let b = 10000.stuint(64)

    check: cast[uint64](a*b) == 100_000_000'u64 # need 27-bits

  test "Multiplication with result overflowing low half":

    let a = 1_000_000.stuint(64)
    let b = 1_000_000.stuint(64)

    check: cast[uint64](a*b) == 1_000_000_000_000'u64 # need 40 bits

  test "Full overflow is handled like native unsigned types":

    let a = 1_000_000_000.stuint(64)
    let b = 1_000_000_000.stuint(64)
    let c = 1_000.stuint(64)

    let x = 1_000_000_000'u64
    let y = 1_000_000_000'u64
    let z = 1_000'u64

    {.push overflowChecks: off.}
    let w = x*y*z
    {.pop.}

    #check: cast[uint64](a*b*c) == 1_000_000_000_000_000_000_000'u64 # need 70-bits
    check: cast[uint64](a*b*c) == w

suite "Testing unsigned int division and modulo implementation":
  test "Divmod(100, 13) returns the correct result":

    let a = 100.stuint(64)
    let b = 13.stuint(64)
    let qr = divmod(a, b)

    check: cast[uint64](qr.quot) == 7'u64
    check: cast[uint64](qr.rem)  == 9'u64

  test "Divmod(2^64, 3) returns the correct result":
    let a = 1.stuint(128) shl 64
    let b = 3.stuint(128)

    let qr = divmod(a, b)

    let q = cast[UintImpl[uint64]](qr.quot)
    let r = cast[UintImpl[uint64]](qr.rem)

    check: q.lo == 6148914691236517205'u64
    check: q.hi == 0'u64
    check: r.lo == 1'u64
    check: r.hi == 0'u64

  test "Divmod(1234567891234567890, 10) returns the correct result":
    let a = cast[StUint[64]](1234567891234567890'u64)
    let b = cast[StUint[64]](10'u64)

    let qr = divmod(a, b)

    let q = cast[uint64](qr.quot)
    let r = cast[uint64](qr.rem)

    check: q == 123456789123456789'u64
    check: r == 0'u64

suite "Testing specific failures highlighted by property-based testing":
  test "Modulo: 65696211516342324 mod 174261910798982":

    let u = 65696211516342324'u64
    let v = 174261910798982'u64

    let a = cast[Stuint[64]](u)
    let b = cast[Stuint[64]](v)

    let z = u mod v
    let tz = cast[uint64](a mod b)

    check: z == tz

  test "Modulo: 15080397990160655 mod 600432699691":
    let u = 15080397990160655'u64
    let v = 600432699691'u64

    let a = cast[Stuint[64]](u)
    let b = cast[Stuint[64]](v)

    let z = u mod v
    let tz = cast[uint64](a mod b)

    check: z == tz

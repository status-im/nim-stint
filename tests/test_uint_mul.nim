# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

template chkMul(a, b, c: string, bits: int) =
  check (fromHex(StUint[bits], a) * fromHex(StUint[bits], b)) == fromHex(StUint[bits], c)

suite "Wider unsigned int muldiv coverage":
  test "operator `mul`":
    #[chkMul("0", "3", "0", 8)
    chkMul("1", "3", "3", 8)
    chkMul("64", "3", "2C", 8) # overflow

    chkMul("0", "3", "0", 16)
    chkMul("1", "3", "3", 16)
    chkMul("64", "3", "12C", 16)
    chkMul("1770", "46", "68A0", 16) # overflow

    chkMul("0", "3", "0", 32)
    chkMul("1", "3", "3", 32)
    chkMul("64", "3", "12C", 32)
    chkMul("1770", "46", "668A0", 32)
    chkMul("13880", "13880", "7D784000", 32) # overflow

    chkMul("0", "3", "0", 64)
    chkMul("1", "3", "3", 64)
    chkMul("64", "3", "12C", 64)
    chkMul("1770", "46", "668A0", 64)
    chkMul("13880", "13880", "17D784000", 64)
    chkMul("3B9ACA00", "E8D4A51000", "35C9ADC5DEA00000", 64) # overflow]#

    chkMul("0", "3", "0", 128)
    chkMul("1", "3", "3", 128)
    chkMul("64", "3", "12C", 128)
    chkMul("1770", "46", "668A0", 128)
    chkMul("13880", "13880", "17D784000", 128)
    chkMul("3B9ACA00", "E8D4A51000", "3635C9ADC5DEA00000", 128)
    chkMul("25295F0D1", "10", "25295F0D10", 128)
    chkMul("123456789ABCDEF00", "123456789ABCDEF00", "4b66dc33f6acdca5e20890f2a5210000", 128) # overflow

    chkMul("123456789ABCDEF00", "123456789ABCDEF00", "14b66dc33f6acdca5e20890f2a5210000", 256)

#[
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
    let w = x*y*z

    #check: cast[uint64](a*b*c) == 1_000_000_000_000_000_000_000'u64 # need 70-bits
    check: cast[uint64](a*b*c) == w

  test "Nim v1.0.2 32 bit type inference rule changed":
    let x = 9975492817.stuint(256)
    let y = 16.stuint(256)
    check x * y == 159607885072.stuint(256)
]#
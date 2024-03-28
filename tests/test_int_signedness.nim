# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

suite "Signed integer signedness":
  test "positive sign":
    let a = stint(1, 128)
    check a.sign > 0
    check a.isNegative == false

    let b = stint(uint32.high, 128)
    check b.sign > 0
    check b.isNegative == false

    let c = stint(uint64.high, 128)
    check c.sign > 0
    check c.isNegative == false

    let aa = stint(1, 256)
    check aa.sign > 0
    check aa.isNegative == false

    let bb = stint(uint32.high, 256)
    check bb.sign > 0
    check bb.isNegative == false

    let cc = stint(uint64.high, 256)
    check cc.sign > 0
    check cc.isNegative == false

    var zz: StInt[128]
    zz.setOne
    check zz.sign > 0
    check zz.isNegative == false

    let yy = StInt[128].one
    check yy.sign > 0
    check yy.isNegative == false

  test "zero sign":
    let a = stint(0, 128)
    check a.sign == 0
    check a.isNegative == false

    let aa = stint(0, 256)
    check aa.sign == 0
    check aa.isNegative == false

    var zz: StInt[128]
    zz.setZero
    check zz.sign == 0
    check zz.isNegative == false

    let yy = StInt[128].zero
    check yy.sign == 0
    check yy.isNegative == false

  test "negative sign":
    let a = stint(-1, 128)
    check a.sign < 0
    check a.isNegative == true

    let aa = stint(-1, 256)
    check aa.sign < 0
    check aa.isNegative == true

    let zz = -1.i128
    check zz.sign < 0
    check zz.isNegative == true

    let yy = -1.i256
    check yy.sign < 0
    check yy.isNegative == true

  test "abs":
    let a = -1.i128
    let aa = a.abs
    check aa == 1.i128

    let b = -1.i256
    let bb = b.abs
    check bb == 1.i256

  test "negate":
    var a = -1.i128
    a.negate
    check a == 1.i128

    var b = -1.i256
    b.negate
    check b == 1.i256

    let c = -1.i256
    let d = -c
    check d == 1.i256

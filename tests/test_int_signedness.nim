# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, test_helpers

#[
template chkAddition(chk, a, b, c, bits: untyped) =
  block:
    let x = stuint(a, bits)
    let y = stuint(b, bits)
    chk x + y == stuint(c, bits)
]#

template testSignedness(chk, tst: untyped) =
  tst "positive sign":
    let a = stint(1, 128)
    chk a.sign > 0
    chk a.isNegative == false

    let b = stint(uint32.high, 128)
    chk b.sign > 0
    chk b.isNegative == false

    let c = stint(uint64.high, 128)
    chk c.sign > 0
    chk c.isNegative == false

    let aa = stint(1, 256)
    chk aa.sign > 0
    chk aa.isNegative == false

    let bb = stint(uint32.high, 256)
    chk bb.sign > 0
    chk bb.isNegative == false

    let cc = stint(uint64.high, 256)
    chk cc.sign > 0
    chk cc.isNegative == false

    var zz: StInt[128]
    zz.setOne
    chk zz.sign > 0
    chk zz.isNegative == false

    let yy = StInt[128].one
    chk yy.sign > 0
    chk yy.isNegative == false

  tst "zero sign":
    let a = stint(0, 128)
    chk a.sign == 0
    chk a.isNegative == false

    let aa = stint(0, 256)
    chk aa.sign == 0
    chk aa.isNegative == false

    var zz: StInt[128]
    zz.setZero
    chk zz.sign == 0
    chk zz.isNegative == false

    let yy = StInt[128].zero
    chk yy.sign == 0
    chk yy.isNegative == false

  tst "negative sign":
    let a = stint(-1, 128)
    chk a.sign < 0
    chk a.isNegative == true

    let aa = stint(-1, 256)
    chk aa.sign < 0
    chk aa.isNegative == true

    let zz = -1.i128
    chk zz.sign < 0
    chk zz.isNegative == true

    let yy = -1.i256
    chk yy.sign < 0
    chk yy.isNegative == true

  tst "abs":
    let a = -1.i128
    let aa = a.abs
    chk aa == 1.i128

    let b = -1.i256
    let bb = b.abs
    chk bb == 1.i256

  tst "negate":
    var a = -1.i128
    a.negate
    chk a == 1.i128

    var b = -1.i256
    b.negate
    chk b == 1.i256

    let c = -1.i256
    let d = -c
    chk d == 1.i256

static:
  testSignedness(ctCheck, ctTest)

suite "Signed integer signedness":
  testSignedness(check, test)

# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, test_helpers

template testInitialization(chk, tst: untyped) =
  tst "zero one":
    var a: StInt[128]
    a.setZero
    chk a == 0.i128

    var b: StInt[256]
    b.setZero
    chk b == 0.i256

    var aa: StInt[128]
    aa.setOne
    chk aa == 1.i128

    var bb: StInt[256]
    bb.setOne
    chk bb == 1.i256

    var xx = StInt[128].zero
    chk xx == 0.i128

    var yy = StInt[256].zero
    chk yy == 0.i256

    var uu = StInt[128].one
    chk uu == 1.i128

    var vv = StInt[256].one
    chk vv == 1.i256

  tst "hi lo":
    let x = Int128.high
    var z = UInt128.high
    z.clearBit(10)
    debugEcho x.toHex
    debugEcho z.toHex
    chk x.imp == z

    let xx = Int128.low
    var zz = UInt128.low
    zz.setBit(z.bits - 1)
    chk xx.imp == zz

#static:
#  testInitialization(ctCheck, ctTest)

suite "Signed integer initialization":
  testInitialization(check, test)

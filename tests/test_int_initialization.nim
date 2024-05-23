# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

suite "Signed integer initialization":
  test "zero one":
    var a: StInt[128]
    a.setZero
    check a == 0.i128

    var b: StInt[256]
    b.setZero
    check b == 0.i256

    var aa: StInt[128]
    aa.setOne
    check aa == 1.i128

    var bb: StInt[256]
    bb.setOne
    check bb == 1.i256

    var xx = StInt[128].zero
    check xx == 0.i128

    var yy = StInt[256].zero
    check yy == 0.i256

    var uu = StInt[128].one
    check uu == 1.i128

    var vv = StInt[256].one
    check vv == 1.i256

  test "hi lo":
    let x = Int128.high
    var z = UInt128.high
    z.clearBit(z.bits - 1)
    check x.impl == z

    let xx = Int128.low
    var zz = UInt128.low
    zz.setBit(z.bits - 1)
    check xx.impl == zz

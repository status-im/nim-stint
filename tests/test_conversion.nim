# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2, strutils

template chkStuintToStuint(N, bits: static[int]) =
  block:
    let x = StUint[N].high
    let y = stuint(0, N)
    let z = stuint(1, N)

    let xx = stuint(x, bits)
    let yy = stuint(y, bits)
    let zz = stuint(z, bits)

    when N <= bits:
      check $x == $xx
    else:
      check $xx == $(StUint[bits].high)
    check $y == $yy
    check $z == $zz

template chkStintToStuint(N, bits: static[int]) =
  block:
    let w = StInt[N].low
    let x = StInt[N].high
    let y = stint(0, N)
    let z = stint(1, N)
    let v = stint(-1, N)

    expect OverflowDefect:
      discard stuint(w, bits)

    let xx = stuint(x, bits)
    let yy = stuint(y, bits)
    let zz = stuint(z, bits)

    expect OverflowDefect:
      discard stuint(v, bits)

    when N <= bits:
      check $x == $xx
    else:
      check $xx == $(StUint[bits].high)

    check $y == $yy
    check $z == $zz

template chkStintToStint(N, bits: static[int]) =
  block:
    let y = stint(0, N)
    let z = stint(1, N)
    let v = stint(-1, N)

    let yy = stint(y, bits)
    let zz = stint(z, bits)
    let vv = stint(v, bits)

    when bits >= N:
      let x = StInt[N].high
      let xx = stint(x, bits)
      check $x == $xx
    else:
      let x = fromHex(StInt[N], toHex(StInt[bits].high))
      let xx = stint(x, bits)
      check $x == $xx

    check $y == $yy
    check $z == $zz
    check $v == $vv

    let w = StInt[N].low

    when bits < N:
      expect RangeDefect:
        discard stint(w, bits)
    else:
      let ww = stint(w, bits)
      check $w == $ww

    let m = stint(int32.low, N)
    let n = stint(int64.low, N)

    let mm = stint(m, bits)
    let nn = stint(n, bits)

    check $m == $mm
    check $n == $nn

template chkStuintToStint(N, bits: static[int]) =
  block:
    let y = stuint(0, N)
    let z = stuint(1, N)
    let v = StUint[N].high

    let yy = stint(y, bits)
    let zz = stint(z, bits)

    when bits <= N:
      expect RangeDefect:
        discard stint(v, bits)
    else:
      let vv = stint(v, bits)
      check v.toHex == vv.toHex

    check $y == $yy
    check $z == $zz


suite "Testing conversion between big integers":
  test "stuint to stuint":
    chkStuintToStuint(64, 64)
    chkStuintToStuint(64, 128)
    chkStuintToStuint(64, 256)
    chkStuintToStuint(64, 512)

    chkStuintToStuint(128, 64)
    chkStuintToStuint(128, 128)
    chkStuintToStuint(128, 256)
    chkStuintToStuint(128, 512)

    chkStuintToStuint(256, 64)
    chkStuintToStuint(256, 128)
    chkStuintToStuint(256, 256)
    chkStuintToStuint(256, 512)

    chkStuintToStuint(512, 64)
    chkStuintToStuint(512, 128)
    chkStuintToStuint(512, 256)
    chkStuintToStuint(512, 512)

  test "stint to stuint":
    chkStintToStuint(64, 64)
    chkStintToStuint(64, 128)
    chkStintToStuint(64, 256)
    chkStintToStuint(64, 512)

    chkStintToStuint(128, 64)
    chkStintToStuint(128, 128)
    chkStintToStuint(128, 256)
    chkStintToStuint(128, 512)

    chkStintToStuint(256, 64)
    chkStintToStuint(256, 128)
    chkStintToStuint(256, 256)
    chkStintToStuint(256, 512)

    chkStintToStuint(512, 64)
    chkStintToStuint(512, 128)
    chkStintToStuint(512, 256)
    chkStintToStuint(512, 512)

  test "stint to stint":
    chkStintToStint(64, 64)
    chkStintToStint(64, 128)
    chkStintToStint(64, 256)
    chkStintToStint(64, 512)

    chkStintToStint(128, 64)
    chkStintToStint(128, 128)
    chkStintToStint(128, 256)
    chkStintToStint(128, 512)

    chkStintToStint(256, 64)
    chkStintToStint(256, 128)
    chkStintToStint(256, 256)
    chkStintToStint(256, 512)

    chkStintToStint(512, 64)
    chkStintToStint(512, 128)
    chkStintToStint(512, 256)
    chkStintToStint(512, 512)

  test "stuint to stint":
    chkStuintToStint(64, 64)
    chkStuintToStint(64, 128)
    chkStuintToStint(64, 256)
    chkStuintToStint(64, 512)

    chkStuintToStint(128, 64)
    chkStuintToStint(128, 128)
    chkStuintToStint(128, 256)
    chkStuintToStint(128, 512)

    chkStuintToStint(256, 64)
    chkStuintToStint(256, 128)
    chkStuintToStint(256, 256)
    chkStuintToStint(256, 512)

    chkStuintToStint(512, 64)
    chkStuintToStint(512, 128)
    chkStuintToStint(512, 256)
    chkStuintToStint(512, 512)

# static:
#   testConversion(ctCheck, ctTest, ctExpect)

# proc main() =
#   # Nim GC protests we are using too much global variables
#   # so put it in a proc
#   suite "Testing conversion between big integers":
#     testConversion(check, test, expect)

# main()

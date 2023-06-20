# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, strutils, test_helpers

template chkStuintToStuint(chk: untyped, N, bits: static[int]) =
  block:
    let x = StUint[N].high
    let y = stuint(0, N)
    let z = stuint(1, N)

    let xx = stuint(x, bits)
    let yy = stuint(y, bits)
    let zz = stuint(z, bits)

    when N <= bits:
      chk $x == $xx
    else:
      chk $xx == $(StUint[bits].high)
    chk $y == $yy
    chk $z == $zz

template chkStintToStuint(chk, handleErr: untyped, N, bits: static[int]) =
  block:
    let w = StInt[N].low
    let x = StInt[N].high
    let y = stint(0, N)
    let z = stint(1, N)
    let v = stint(-1, N)

    handleErr OverflowDefect:
      discard stuint(w, bits)

    let xx = stuint(x, bits)
    let yy = stuint(y, bits)
    let zz = stuint(z, bits)

    handleErr OverflowDefect:
      discard stuint(v, bits)

    when N <= bits:
      chk $x == $xx
    else:
      chk $xx == $(StUint[bits].high)

    chk $y == $yy
    chk $z == $zz

template chkStintToStint(chk, handleErr: untyped, N, bits: static[int]) =
  block:
    # TODO add low value tests if bug #92 fixed
    let y = stint(0, N)
    let z = stint(1, N)
    let v = stint(-1, N)

    let yy = stint(y, bits)
    let zz = stint(z, bits)
    let vv = stint(v, bits)

    when bits >= N:
      let x = StInt[N].high
      let xx = stint(x, bits)
      chk $x == $xx
    else:
      let x = fromHex(StInt[N], toHex(StInt[bits].high))
      let xx = stint(x, bits)
      chk $x == $xx

    chk $y == $yy
    chk $z == $zz
    chk $v == $vv

    let w = StInt[N].low

    when bits < N:
      handleErr RangeDefect:
        discard stint(w, bits)
    else:
      let ww = stint(w, bits)
      chk $w == $ww

    let m = stint(int32.low, N)
    let n = stint(int64.low, N)

    let mm = stint(m, bits)
    let nn = stint(n, bits)

    chk $m == $mm
    chk $n == $nn

template chkStuintToStint(chk, handleErr: untyped, N, bits: static[int]) =
  block:
    let y = stuint(0, N)
    let z = stuint(1, N)
    let v = StUint[N].high

    let yy = stint(y, bits)
    let zz = stint(z, bits)

    when bits <= N:
      handleErr RangeDefect:
        discard stint(v, bits)
    else:
      let vv = stint(v, bits)
      chk v.toHex == vv.toHex

    chk $y == $yy
    chk $z == $zz

template testConversion(chk, tst, handleErr: untyped) =
  tst "stuint to stuint":
    chkStuintToStuint(chk, 64, 64)
    chkStuintToStuint(chk, 64, 128)
    chkStuintToStuint(chk, 64, 256)
    chkStuintToStuint(chk, 64, 512)

    chkStuintToStuint(chk, 128, 64)
    chkStuintToStuint(chk, 128, 128)
    chkStuintToStuint(chk, 128, 256)
    chkStuintToStuint(chk, 128, 512)

    chkStuintToStuint(chk, 256, 64)
    chkStuintToStuint(chk, 256, 128)
    chkStuintToStuint(chk, 256, 256)
    chkStuintToStuint(chk, 256, 512)

    chkStuintToStuint(chk, 512, 64)
    chkStuintToStuint(chk, 512, 128)
    chkStuintToStuint(chk, 512, 256)
    chkStuintToStuint(chk, 512, 512)

  tst "stint to stuint":
    chkStintToStuint(chk, handleErr, 64, 64)
    chkStintToStuint(chk, handleErr, 64, 128)
    chkStintToStuint(chk, handleErr, 64, 256)
    chkStintToStuint(chk, handleErr, 64, 512)

    chkStintToStuint(chk, handleErr, 128, 64)
    chkStintToStuint(chk, handleErr, 128, 128)
    chkStintToStuint(chk, handleErr, 128, 256)
    chkStintToStuint(chk, handleErr, 128, 512)

    chkStintToStuint(chk, handleErr, 256, 64)
    chkStintToStuint(chk, handleErr, 256, 128)
    chkStintToStuint(chk, handleErr, 256, 256)
    chkStintToStuint(chk, handleErr, 256, 512)

    chkStintToStuint(chk, handleErr, 512, 64)
    chkStintToStuint(chk, handleErr, 512, 128)
    chkStintToStuint(chk, handleErr, 512, 256)
    chkStintToStuint(chk, handleErr, 512, 512)

  tst "stint to stint":
    chkStintToStint(chk, handleErr, 64, 64)
    chkStintToStint(chk, handleErr, 64, 128)
    chkStintToStint(chk, handleErr, 64, 256)
    chkStintToStint(chk, handleErr, 64, 512)

    chkStintToStint(chk, handleErr, 128, 64)
    chkStintToStint(chk, handleErr, 128, 128)
    chkStintToStint(chk, handleErr, 128, 256)
    chkStintToStint(chk, handleErr, 128, 512)

    chkStintToStint(chk, handleErr, 256, 64)
    chkStintToStint(chk, handleErr, 256, 128)
    chkStintToStint(chk, handleErr, 256, 256)
    chkStintToStint(chk, handleErr, 256, 512)

    chkStintToStint(chk, handleErr, 512, 64)
    chkStintToStint(chk, handleErr, 512, 128)
    chkStintToStint(chk, handleErr, 512, 256)
    chkStintToStint(chk, handleErr, 512, 512)

  tst "stuint to stint":
    chkStuintToStint(chk, handleErr, 64, 64)
    chkStuintToStint(chk, handleErr, 64, 128)
    chkStuintToStint(chk, handleErr, 64, 256)
    chkStuintToStint(chk, handleErr, 64, 512)

    chkStuintToStint(chk, handleErr, 128, 64)
    chkStuintToStint(chk, handleErr, 128, 128)
    chkStuintToStint(chk, handleErr, 128, 256)
    chkStuintToStint(chk, handleErr, 128, 512)

    chkStuintToStint(chk, handleErr, 256, 64)
    chkStuintToStint(chk, handleErr, 256, 128)
    chkStuintToStint(chk, handleErr, 256, 256)
    chkStuintToStint(chk, handleErr, 256, 512)

    chkStuintToStint(chk, handleErr, 512, 64)
    chkStuintToStint(chk, handleErr, 512, 128)
    chkStuintToStint(chk, handleErr, 512, 256)
    chkStuintToStint(chk, handleErr, 512, 512)

static:
  testConversion(ctCheck, ctTest, ctExpect)

proc main() =
  # Nim GC protests we are using too much global variables
  # so put it in a proc
  suite "Testing conversion between big integers":
    testConversion(check, test, expect)

main()

# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, quicktest, math

const itercount = 1000

suite "Property-based testing (testing with random inputs) - uint64 on 64-bit / uint32 on 32-bit":

  when defined(release):
    echo "Testing in release mode with " & $itercount & " random tests for each proc."
  else:
    echo "Testing in debug mode " & $itercount & " random tests for each proc. (StUint[64] = 2x uint32)"
  when defined(stint_test):
    echo "(StUint[64] = 2x uint32)"
  else:
    echo "(StUint[64] = uint64)"

  let hi = 1'u shl (sizeof(uint)*7)

  quicktest "`or`", itercount do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        ty = cast[StUint[64]](y)
        tz = tx or ty
    else:
      let
        tx = cast[StUint[32]](x)
        ty = cast[StUint[32]](y)
        tz = tx or ty


    check(cast[uint](tz) == (x or y))


  quicktest "`and`", itercount do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        ty = cast[StUint[64]](y)
        tz = tx and ty
    else:
      let
        tx = cast[StUint[32]](x)
        ty = cast[StUint[32]](y)
        tz = tx and ty

    check(cast[uint](tz) == (x and y))

  quicktest "`xor`", itercount do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        ty = cast[StUint[64]](y)
        tz = tx xor ty
    else:
      let
        tx = cast[StUint[32]](x)
        ty = cast[StUint[32]](y)
        tz = tx xor ty

    check(cast[uint](tz) == (x xor y))

  quicktest "`not`", itercount do(x: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        tz = not tx
    else:
      let
        tx = cast[StUint[32]](x)
        tz = not tx

    check(cast[uint](tz) == (not x))

  quicktest "`<`", itercount do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        ty = cast[StUint[64]](y)
        tz = tx < ty
    else:
      let
        tx = cast[StUint[32]](x)
        ty = cast[StUint[32]](y)
        tz = tx < ty

    check(tz == (x < y))


  quicktest "`<=`", itercount do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        ty = cast[StUint[64]](y)
        tz = tx <= ty
    else:
      let
        tx = cast[StUint[32]](x)
        ty = cast[StUint[32]](y)
        tz = tx <= ty

    check(tz == (x <= y))

  quicktest "`+`", itercount do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        ty = cast[StUint[64]](y)
        tz = tx + ty
    else:
      let
        tx = cast[StUint[32]](x)
        ty = cast[StUint[32]](y)
        tz = tx + ty

    check(cast[uint](tz) == x+y)


  quicktest "`-`", itercount do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        ty = cast[StUint[64]](y)
        tz = tx - ty
    else:
      let
        tx = cast[StUint[32]](x)
        ty = cast[StUint[32]](y)
        tz = tx - ty

    check(cast[uint](tz) == x-y)

  quicktest "`*`", itercount do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        ty = cast[StUint[64]](y)
        tz = tx * ty
    else:
      let
        tx = cast[StUint[32]](x)
        ty = cast[StUint[32]](y)
        tz = tx * ty

    check(cast[uint](tz) == x*y)

  quicktest "`shl`", itercount do(x: uint(min=0, max=hi), y: int(min = 0, max=(sizeof(int)*8-1))):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        tz = tx shl y
    else:
      let
        tx = cast[StUint[32]](x)
        tz = tx shl y

    check(cast[uint](tz) == x shl y)

  quicktest "`shr`", itercount do(x: uint(min=0, max=hi), y: int(min = 0, max=(sizeof(int)*8-1))):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        tz = tx shr y
    else:
      let
        tx = cast[StUint[32]](x)
        tz = tx shr y

    check(cast[uint](tz) == x shr y)

  quicktest "`mod`", itercount do(x: uint(min=0, max=hi), y: uint(min = 1, max = hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        ty = cast[StUint[64]](y)
        tz = tx mod ty
    else:
      let
        tx = cast[StUint[32]](x)
        ty = cast[StUint[32]](y)
        tz = tx mod ty

    check(cast[uint](tz) == x mod y)

  quicktest "`div`", itercount do(x: uint(min=0, max=hi), y: uint(min = 1, max = hi)):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        ty = cast[StUint[64]](y)
        tz = tx div ty
    else:
      let
        tx = cast[StUint[32]](x)
        ty = cast[StUint[32]](y)
        tz = tx div ty

    check(cast[uint](tz) == x div y)

  quicktest "pow", itercount do(x: uint(min=0, max=hi), y: int(min = 0, max = high(int))):

    when sizeof(int) == 8:
      let
        tx = cast[StUint[64]](x)
        tz = tx.pow(y)

        ty = cast[StUint[64]](y)
        tz2 = tx.pow(ty)
    else:
      let
        tx = cast[StUint[32]](x)
        tz = tx.pow(y)

        ty = cast[StUint[32]](y)
        tz2 = tx.pow(ty)

    check(cast[uint](tz) == x ^ y)
    check(cast[uint](tz2) == x ^ y)

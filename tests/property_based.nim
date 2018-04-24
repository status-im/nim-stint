# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/mpint, unittest, quicktest

suite "Property-based testing (testing with random inputs) - uint64 on 64-bit / uint32 on 32-bit":

  let hi = 1'u shl (sizeof(uint)*7)

  quicktest "`or`", 10_000 do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        ty = cast[MpUint[64]](y)
        tz = tx or ty
    else:
      let
        tx = cast[MpUint[32]](x)
        ty = cast[MpUint[32]](y)
        tz = tx or ty


    check(cast[uint](tz) == (x or y))


  quicktest "`and`", 10_000 do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        ty = cast[MpUint[64]](y)
        tz = tx and ty
    else:
      let
        tx = cast[MpUint[32]](x)
        ty = cast[MpUint[32]](y)
        tz = tx and ty

    check(cast[uint](tz) == (x and y))

  quicktest "`xor`", 10_000 do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        ty = cast[MpUint[64]](y)
        tz = tx xor ty
    else:
      let
        tx = cast[MpUint[32]](x)
        ty = cast[MpUint[32]](y)
        tz = tx xor ty

    check(cast[uint](tz) == (x xor y))

  quicktest "`not`", 10_000 do(x: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        tz = not tx
    else:
      let
        tx = cast[MpUint[32]](x)
        tz = not tx

    check(cast[uint](tz) == (not x))

  quicktest "`<`", 10_000 do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        ty = cast[MpUint[64]](y)
        tz = tx < ty
    else:
      let
        tx = cast[MpUint[32]](x)
        ty = cast[MpUint[32]](y)
        tz = tx < ty

    check(tz == (x < y))


  quicktest "`<=`", 10_000 do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        ty = cast[MpUint[64]](y)
        tz = tx <= ty
    else:
      let
        tx = cast[MpUint[32]](x)
        ty = cast[MpUint[32]](y)
        tz = tx <= ty

    check(tz == (x <= y))

  quicktest "`+`", 10_000 do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        ty = cast[MpUint[64]](y)
        tz = tx + ty
    else:
      let
        tx = cast[MpUint[32]](x)
        ty = cast[MpUint[32]](y)
        tz = tx + ty

    check(cast[uint](tz) == x+y)


  quicktest "`-`", 10_000 do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        ty = cast[MpUint[64]](y)
        tz = tx - ty
    else:
      let
        tx = cast[MpUint[32]](x)
        ty = cast[MpUint[32]](y)
        tz = tx - ty

    check(cast[uint](tz) == x-y)

  quicktest "`shl`", 10_000 do(x: uint(min=0, max=hi), y: int(min=0, max=high(int))):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        tz = tx shl y
    else:
      let
        tx = cast[MpUint[32]](x)
        tz = tx shl y

    check(cast[uint](tz) == x shl y)

  quicktest "`shr`", 10_000 do(x: uint(min=0, max=hi), y: int(min=0, max=high(int))):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        tz = tx shr y
    else:
      let
        tx = cast[MpUint[32]](x)
        tz = tx shr y

    check(cast[uint](tz) == x shr y)

  quicktest "`*`", 10_000 do(x: uint(min=0, max=hi), y: uint(min=0, max=hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        ty = cast[MpUint[64]](y)
        tz = tx * ty
    else:
      let
        tx = cast[MpUint[32]](x)
        ty = cast[MpUint[32]](y)
        tz = tx * ty

    check(cast[uint](tz) == x*y)

  quicktest "`mod`", 10_000 do(x: uint(min=0, max=hi), y: uint(min = 1, max = hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        ty = cast[MpUint[64]](y)
        tz = tx mod ty
    else:
      let
        tx = cast[MpUint[32]](x)
        ty = cast[MpUint[32]](y)
        tz = tx mod ty

    check(cast[uint](tz) == x mod y)

  quicktest "`div`", 10_000 do(x: uint(min=0, max=hi), y: uint(min = 1, max = hi)):

    when sizeof(int) == 8:
      let
        tx = cast[MpUint[64]](x)
        ty = cast[MpUint[64]](y)
        tz = tx div ty
    else:
      let
        tx = cast[MpUint[32]](x)
        ty = cast[MpUint[32]](y)
        tz = tx div ty

    check(cast[uint](tz) == x div y)

# suite "Property-based testing (testing with random inputs - uint256 (ttmath)":

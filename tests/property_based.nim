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
  quicktest "`+`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)
      yu = cast[uint](y)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        my = cast[MpUint[64]](y)
        z = mx + my
    else:
      let
        mx = cast[MpUint[32]](x)
        my = cast[MpUint[32]](y)
        z = mx + my

    check(cast[uint](z) == xu+yu)


  quicktest "`-`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)
      yu = cast[uint](y)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        my = cast[MpUint[64]](y)
        z = mx - my
    else:
      let
        mx = cast[MpUint[32]](x)
        my = cast[MpUint[32]](y)
        z = mx - my

    check(cast[uint](z) == xu-yu)

  quicktest "`*`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)
      yu = cast[uint](y)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        my = cast[MpUint[64]](y)
        z = mx * my
    else:
      let
        mx = cast[MpUint[32]](x)
        my = cast[MpUint[32]](y)
        z = mx * my

    check(cast[uint](z) == xu*yu)

  quicktest "`div`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min = 1, max = high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)
      yu = cast[uint](y)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        my = cast[MpUint[64]](y)
        z = mx div my
    else:
      let
        mx = cast[MpUint[32]](x)
        my = cast[MpUint[32]](y)
        z = mx div my

    check(cast[uint](z) == xu div yu)

  quicktest "`mod`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min = 1, max = high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)
      yu = cast[uint](y)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        my = cast[MpUint[64]](y)
        z = mx mod my
    else:
      let
        mx = cast[MpUint[32]](x)
        my = cast[MpUint[32]](y)
        z = mx mod my

    check(cast[uint](z) == xu mod yu)

  quicktest "`shl`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        z = mx shl y
    else:
      let
        mx = cast[MpUint[32]](x)
        z = mx shl y

    check(cast[uint](z) == xu shl y)

  quicktest "`shr`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        z = mx shr y
    else:
      let
        mx = cast[MpUint[32]](x)
        z = mx shr y

    check(cast[uint](z) == xu shr y)

  quicktest "`or`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)
      yu = cast[uint](y)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        my = cast[MpUint[64]](y)
        z = mx or my
    else:
      let
        mx = cast[MpUint[32]](x)
        my = cast[MpUint[32]](y)
        z = mx or my

    check(cast[uint](z) == (xu or yu))

  quicktest "`and`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)
      yu = cast[uint](y)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        my = cast[MpUint[64]](y)
        z = mx and my
    else:
      let
        mx = cast[MpUint[32]](x)
        my = cast[MpUint[32]](y)
        z = mx and my

    check(cast[uint](z) == (xu and yu))

  quicktest "`xor`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)
      yu = cast[uint](y)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        my = cast[MpUint[64]](y)
        z = mx xor my
    else:
      let
        mx = cast[MpUint[32]](x)
        my = cast[MpUint[32]](y)
        z = mx xor my

    check(cast[uint](z) == (xu xor yu))

  quicktest "`not`", 10_000 do(x: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        z = not mx
    else:
      let
        mx = cast[MpUint[32]](x)
        z = not mx

    check(cast[uint](z) == (not xu))

  quicktest "`<`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)
      yu = cast[uint](y)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        my = cast[MpUint[64]](y)
        z = mx < my
    else:
      let
        mx = cast[MpUint[32]](x)
        my = cast[MpUint[32]](y)
        z = mx < my

    check(z == (xu < yu))


  quicktest "`<=`", 10_000 do(x: int(min=low(int), max=high(int)), y: int(min=low(int), max=high(int))):

    let
      # Quicktest does not support uint at the moment
      xu = cast[uint](x)
      yu = cast[uint](y)

    when sizeof(int) == 8:
      let
        mx = cast[MpUint[64]](x)
        my = cast[MpUint[64]](y)
        z = mx <= my
    else:
      let
        mx = cast[MpUint[32]](x)
        my = cast[MpUint[32]](y)
        z = mx <= my

    check(z == (xu <= yu))

# suite "Property-based testing (testing with random inputs - uint256 (ttmath)":

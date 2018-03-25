# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./private/uint_type, macros
export MpUint, MpUintImpl, getMpUintImpl # TODO remove the need to export MpUintImpl and this macro

type
  UInt128* = MpUint[128]
  UInt256* = MpUint[256]

template make_unary(op, resultTy, importlib: untyped): untyped =
  proc op*(x: MpUint): resultTy {.noInit, inline, noSideEffect.} =
    when undistinct(x) is MpUintImpl:
      importlib.op(x)
    else:
      system.op(x)

template make_binary(op, resultTy, importlib: untyped): untyped =
  proc op*(x, y: MpUint): resultTy {.noInit, inline, noSideEffect.} =
    when undistinct(x) is MpUintImpl:
      importlib.op(x, y)
    else:
      system.op(x, y)

template make_binary_inplace(op, importlib: untyped): untyped =
  proc op*(x: var MpUint, y: MpUint) {.inline, noSideEffect.} =
    when undistinct(x) is MpUintImpl:
      importlib.op(x,y)
    else:
      system.op(x,y)

import ./private/uint_binary_ops as binops

make_binary(`+`, MpUint, binops)
make_binary_inplace(`+=`, binops)
make_binary(`-`, MpUint, binops)
make_binary_inplace(`-=`, binops)
make_binary(`*`, MpUint, binops)
make_binary(`div`, MpUint, binops)
make_binary(`mod`, MpUint, binops)
make_binary(`divmod`, MpUint, binops)

import ./private/uint_comparison as cmp

make_binary(`<`, bool, cmp)
make_binary(`<=`, bool, cmp)
proc isZero*(x: MpUint): bool {.inline, noSideEffect.} = cmp.isZero x

import ./private/uint_bitwise_ops as bitops

make_unary(`not`, MpUint, bitops)
make_binary(`or`, MpUint, bitops)
make_binary(`and`, MpUint, bitops)
make_binary(`xor`, MpUint, bitops)
make_binary(`shr`, MpUint, bitops)
make_binary(`shl`, MpUint, bitops)



when isMainModule:

  var a: Uint256
  echo a.repr

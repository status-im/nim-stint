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

template make_conv(conv_name: untyped, size: int): untyped =
  proc `convname`*(n: SomeInteger): MpUint[size] {.noSideEffect, inline, noInit.}=
    n.initMpUint(size)

make_conv(u128, 128)
make_conv(u256, 256)

template make_unary(op, ResultTy): untyped =
  proc `op`*(x: MpUint): ResultTy {.noInit, inline, noSideEffect.} =
    when resultTy is MpUint:
      result.data = op(x.data)
    else:
      op(x.data)
  export op

template make_binary(op, ResultTy): untyped =
  proc `op`*(x, y: MpUint): ResultTy {.noInit, inline, noSideEffect.} =
    when ResultTy is MpUint:
      result.data = op(x.data, y.data)
    else:
      op(x.data, y.data)
  export `op`

template make_binary_inplace(op): untyped =
  proc `op`*(x: var MpUint, y: MpUint) {.inline, noSideEffect.} =
    op(x.data, y.data)
  export op

import ./private/uint_addsub

make_binary(`+`, MpUint)
make_binary_inplace(`+=`)
make_binary(`-`, MpUint)
make_binary_inplace(`-=`)

import ./private/uint_mul
make_binary(`*`, MpUint)

import ./private/uint_div

make_binary(`div`, MpUint)
make_binary(`mod`, MpUint)
proc divmod*(x, y: MpUint): tuple[quot, rem: MpUint] {.noInit, inline, noSideEffect.} =
  (result.quot.data, result.rem.data) = divmod(x.data, y.data)

import ./private/uint_comparison

make_binary(`<`, bool)
make_binary(`<=`, bool)
proc isZero*(x: MpUint): bool {.inline, noSideEffect.} = isZero x

import ./private/uint_bitwise_ops

make_unary(`not`, MpUint)
make_binary(`or`, MpUint)
make_binary(`and`, MpUint)
make_binary(`xor`, MpUint)
proc `shr`*(x: Mpuint, y: SomeInteger): MpUint {.noInit, inline, noSideEffect.} =
  result.data = x.data shr y
proc `shl`*(x: Mpuint, y: SomeInteger): MpUint {.noInit, inline, noSideEffect.} =
  result.data = x.data shl y

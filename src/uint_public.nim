# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./private/uint_type, macros
export StUint, UintImpl, getUintImpl # TODO remove the need to export UintImpl and this macro

type
  UInt128* = StUint[128]
  UInt256* = StUint[256]

template make_conv(conv_name: untyped, size: int): untyped =
  func `convname`*(n: SomeInteger): StUint[size] {.inline, noInit.}=
    n.stuint(size)

make_conv(u128, 128)
make_conv(u256, 256)

template make_unary(op, ResultTy): untyped =
  func `op`*(x: StUint): ResultTy {.noInit, inline.} =
    when ResultTy is StUint:
      result.data = op(x.data)
    else:
      op(x.data)
  export op

template make_binary(op, ResultTy): untyped =
  func `op`*(x, y: StUint): ResultTy {.noInit, inline.} =
    when ResultTy is StUint:
      result.data = op(x.data, y.data)
    else:
      op(x.data, y.data)
  export `op`

template make_binary_inplace(op): untyped =
  func `op`*(x: var StUint, y: StUint) {.inline.} =
    op(x.data, y.data)
  export op

import ./private/uint_addsub

make_binary(`+`, StUint)
make_binary_inplace(`+=`)
make_binary(`-`, StUint)
make_binary_inplace(`-=`)

import ./private/uint_mul
make_binary(`*`, StUint)

import ./private/uint_div

make_binary(`div`, StUint)
make_binary(`mod`, StUint)
func divmod*(x, y: StUint): tuple[quot, rem: StUint] {.noInit, inline.} =
  (result.quot.data, result.rem.data) = divmod(x.data, y.data)

import ./private/uint_comparison

make_binary(`<`, bool)
make_binary(`<=`, bool)
make_binary(`==`, bool)
func isZero*(x: StUint): bool {.inline.} = isZero x.data

import ./private/uint_bitwise_ops

make_unary(`not`, StUint)
make_binary(`or`, StUint)
make_binary(`and`, StUint)
make_binary(`xor`, StUint)
proc `shr`*(x: StUint, y: SomeInteger): StUint {.noInit, inline, noSideEffect.} =
  result.data = x.data shr y
proc `shl`*(x: StUint, y: SomeInteger): StUint {.noInit, inline, noSideEffect.} =
  result.data = x.data shl y

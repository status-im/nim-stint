# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./private/datatypes, macros
export StInt
export IntImpl, intImpl, bitsof # TODO remove the need to export these

template make_unary(op, ResultTy): untyped =
  func `op`*(x: Stint): ResultTy {.inline.} =
    when ResultTy is Stint:
      result.data = op(x.data)
    else:
      op(x.data)
  export op

template make_binary(op, ResultTy): untyped =
  func `op`*(x, y: Stint): ResultTy {.inline.} =
    when ResultTy is Stint:
      result.data = op(x.data, y.data)
    else:
      op(x.data, y.data)
  export `op`

template make_binary_inplace(op): untyped =
  func `op`*(x: var Stint, y: Stint) {.inline.} =
    op(x.data, y.data)
  export op

import ./private/int_addsub

make_binary(`+`, Stint)
make_binary_inplace(`+=`)
make_binary(`-`, Stint)
make_binary_inplace(`-=`)

import ./private/int_negabs
make_unary(`-`, Stint)
make_unary(abs, Stint)

import ./private/int_mul
make_binary(`*`, Stint)

import ./private/int_div

make_binary(`div`, Stint)
make_binary(`mod`, Stint)
func divmod*(x, y: Stint): tuple[quot, rem: Stint] {.inline.} =
  (result.quot.data, result.rem.data) = divmod(x.data, y.data)

import ./private/int_comparison

make_binary(`<`, bool)
make_binary(`<=`, bool)
make_binary(`==`, bool)
make_unary(isZero, bool)
make_unary(isNegative, bool)

func isOdd(x: SomeSignedInt): bool {.inline.}=
  # internal
  bool(x and 1)

func isEven(x: SomeSignedInt): bool {.inline.}=
  # internal
  not x.isOdd

make_unary(isOdd, bool)
make_unary(isEven, bool)

import ./private/int_bitwise_ops

make_unary(`not`, Stint)
make_binary(`or`, Stint)
make_binary(`and`, Stint)
make_binary(`xor`, Stint)
func `shr`*(x: Stint, y: SomeInteger): Stint {.inline.} =
  result.data = x.data shr y
func `shl`*(x: Stint, y: SomeInteger): Stint {.inline.} =
  result.data = x.data shl y
func ashr*(x: Stint, y: SomeInteger): Stint {.inline.} =
  result.data = ashr(x.data, y)

import ./private/int_highlow

func high*[bits: static[int]](_: typedesc[Stint[bits]]): Stint[bits] {.inline.} =
  result.data = high(type result.data)

func low*[bits: static[int]](_: typedesc[Stint[bits]]): Stint[bits] {.inline.} =
  result.data = low(type result.data)

# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./private/[bitops2_priv, datatypes]

export Stint, StUint
export IntImpl, intImpl, UintImpl, uintImpl, bitsof # TODO: remove the need to export those

type SomeBigInteger = Stuint|Stint

import ./private/initialization

func zero*[bits: static[int]](T: typedesc[Stuint[bits] or Stint[bits]]): T {.inline.} =
  ## Returns the zero of the input type
  discard

func one*[bits: static[int]](T: typedesc[Stuint[bits]]): T {.inline.} =
  ## Returns the one of the input type
  result.data = one(type result.data)

import ./private/[int_addsub, uint_addsub]

func `+`*(x, y: SomeBigInteger): SomeBigInteger {.inline.} =
  ## Integer addition
  result.data = x.data + y.data
func `+=`*(x: var SomeBigInteger, y: SomeBigInteger) {.inline.} =
  ## Integer addition
  x.data += y.data
func `-`*(x, y: SomeBigInteger): SomeBigInteger {.inline.} =
  ## Integer substraction
  result.data = x.data - y.data
func `-=`*(x: var SomeBigInteger, y: SomeBigInteger) {.inline.} =
  ## Integer substraction
  x.data -= y.data

import ./private/int_negabs

func `-`*(x: Stint): Stint {.inline.} =
  ## Returns true if input is zero
  ## false otherwise
  result.data = -x.data

func abs*(x: Stint): Stint {.inline.} =
  ## Returns true if input is zero
  ## false otherwise
  result.data = abs(x.data)

import ./private/[int_mul, uint_mul]

func `*`*(x, y: SomeBigInteger): SomeBigInteger {.inline.} =
  ## Integer multiplication
  result.data = x.data * y.data

import ./private/[int_div, uint_div]

func `div`*(x, y: SomeBigInteger): SomeBigInteger {.inline.} =
  ## Integer division
  result.data = x.data div y.data
func `mod`*(x, y: SomeBigInteger): SomeBigInteger {.inline.} =
  ## Integer modulo
  ## This returns the remainder of x / y.
  ## i.e. x = y * quotient + remainder
  result.data = x.data mod y.data
func divmod*(x, y: SomeBigInteger): tuple[quot, rem: SomeBigInteger] {.inline.} =
  ## Fused integer division and modulo
  ## Return both the quotient and remainder
  ## of x / y
  (result.quot.data, result.rem.data) = divmod(x.data, y.data)

import ./private/[int_comparison, uint_comparison]

func `<`*(x, y: SomeBigInteger): bool {.inline.} =
  ## Unsigned `less than` comparison
  x.data < y.data
func `<=`*(x, y: SomeBigInteger): bool {.inline.} =
  ## Unsigned `less or equal` comparison
  x.data <= y.data
func `==`*(x, y: SomeBigInteger): bool {.inline.} =
  ## Unsigned `equal` comparison
  x.data == y.data
export `<`, `<=`, `==` # Address Generic Instantiation too nested: https://github.com/status-im/nim-stint/pull/66#issuecomment-427557655

# TODO these exports are needed for the SomeInteger versions - move to stew?
export isZero, isOdd, isEven, isNegative

func isZero*(x: SomeBigInteger): bool {.inline.} =
  ## Returns true if input is zero
  ## false otherwise
  x.data.isZero

func isNegative*(x: Stint): bool {.inline.} =
  ## Returns true if input is negative (< 0)
  ## false otherwise
  x.data.isNegative

func isOdd*(x: SomeBigInteger): bool {.inline.} =
  ## Returns true if input is zero
  ## false otherwise
  x.data.isOdd

func isEven*(x: SomeBigInteger): bool {.inline.} =
  ## Returns true if input is zero
  ## false otherwise
  x.data.isEven

export isEven, isOdd

import ./private/[int_bitwise_ops, uint_bitwise_ops]

func `not`*(x: SomeBigInteger): SomeBigInteger {.inline.}=
  ## Bitwise `not` i.e. flips all bits of the input
  result.data = x.data.not
func `or`*(x, y: SomeBigInteger): SomeBigInteger {.inline.}=
  ## Bitwise `or`
  result.data = x.data or y.data
func `and`*(x, y: SomeBigInteger): SomeBigInteger {.inline.}=
  ## Bitwise `and`
  result.data = x.data and y.data
func `xor`*(x, y: SomeBigInteger): SomeBigInteger {.inline.}=
  ## Bitwise `xor`
  result.data = x.data xor y.data

func `shr`*(x: SomeBigInteger, y: SomeInteger): SomeBigInteger {.inline.} =
  when x.data is SomeSignedInt:
    when (NimMajor, NimMinor, NimPatch) >= (0, 20, 0):
      result.data = x.data shr y
    elif (NimMajor, NimMinor, NimPatch) < (0, 20, 0) and defined(nimAshr):
      result.data = ashr(x.data, y)
    else:
      {.error: "arithmetic right shift is not defined for this Nim version".}
  else:
    result.data = x.data shr y

func `shl`*(x: SomeBigInteger, y: SomeInteger): SomeBigInteger {.inline.} =
  result.data = x.data shl y

import ./private/[int_highlow, uint_highlow]

func high*[bits](_: typedesc[Stint[bits]]): Stint[bits] {.inline.} =
  result.data = high(type result.data)
func high*[bits](_: typedesc[Stuint[bits]]): Stuint[bits] {.inline.} =
  result.data = high(type result.data)

func low*[bits](_: typedesc[Stint[bits]]): Stint[bits] {.inline.} =
  result.data = low(type result.data)
func low*[bits](_: typedesc[Stuint[bits]]): Stuint[bits] {.inline.} =
  result.data = low(type result.data)

import ./private/uint_exp, math

func pow*(x: StUint, y: Natural): StUint {.inline.} =
  ## Returns x raised at the power of y
  when x.data is UintImpl:
    result.data = x.data.pow(y)
  else:
    result.data = x.data ^ y

func pow*(x: StUint, y: StUint): StUint {.inline.} =
  ## Returns x raised at the power of y
  when x.data is UintImpl:
    result.data = x.data.pow(y.data)
  else:
    result.data = x.data ^ y.data

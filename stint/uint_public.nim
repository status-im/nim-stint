# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./private/datatypes

export StUint
export UintImpl, uintImpl, bitsof # TODO: remove the need to export those

import ./private/uint_addsub

func `+`*(x, y: Stuint): Stuint {.inline.} =
  ## Unsigned integer addition
  result.data = x.data + y.data
func `+=`*(x: var Stuint, y: Stuint) {.inline.} =
  ## Unsigned integer addition
  x.data += y.data
func `-`*(x, y: Stuint): Stuint {.inline.} =
  ## Unsigned integer substraction
  result.data = x.data - y.data
func `-=`*(x: var Stuint, y: Stuint) {.inline.} =
  ## Unsigned integer substraction
  x.data -= y.data

import ./private/uint_mul

func `*`*(x, y: Stuint): Stuint {.inline.} =
  ## Unsigned integer multiplication
  result.data = x.data * y.data

import ./private/uint_div

func `div`*(x, y: Stuint): Stuint {.inline.} =
  ## Unsigned integer division
  result.data = x.data div y.data
func `mod`*(x, y: Stuint): Stuint {.inline.} =
  ## Unsigned integer modulo
  ## This returns the remainder of x / y.
  ## i.e. x = y * quotient + remainder
  result.data = x.data mod y.data
func divmod*(x, y: StUint): tuple[quot, rem: StUint] {.inline.} =
  ## Fused unsigned integer division and modulo
  ## Return both the quotient and remainder
  ## of x / y
  (result.quot.data, result.rem.data) = divmod(x.data, y.data)

import ./private/uint_comparison

func `<`*(x, y: Stuint): bool {.inline.} =
  ## Unsigned `less than` comparison
  x.data < y.data
func `<=`*(x, y: Stuint): bool {.inline.} =
  ## Unsigned `less or equal` comparison
  x.data <= y.data
func `==`*(x, y: Stuint): bool {.inline.} =
  ## Unsigned `equal` comparison
  x.data == y.data
export `<`, `<=`, `==` # Address Generic Instantiation too nested: https://github.com/status-im/nim-stint/pull/66#issuecomment-427557655

func isZero*(x: Stuint): bool {.inline.} =
  ## Returns true if input is zero
  ## false otherwise
  x.data.isZero

export isEven, isOdd
func isEven*(x: Stuint): bool {.inline.}=
  ## Returns true if input is even
  ## false otherwise
  x.data.isEven
func isOdd*(x: Stuint): bool {.inline.}=
  ## Returns true if input is odd
  ## false otherwise
  not x.isEven

import ./private/uint_bitwise_ops

func `not`*(x: Stuint): Stuint {.inline.}=
  ## Bitwise `not` i.e. flips all bits of the input
  result.data = x.data.not
func `or`*(x, y: Stuint): Stuint {.inline.}=
  ## Bitwise `or`
  result.data = x.data or y.data
func `and`*(x, y: Stuint): Stuint {.inline.}=
  ## Bitwise `and`
  result.data = x.data and y.data
func `xor`*(x, y: Stuint): Stuint {.inline.}=
  ## Bitwise `xor`
  result.data = x.data xor y.data

func `shr`*(x: StUint, y: SomeInteger): StUint {.inline.} =
  ## Logical shift right
  result.data = x.data shr y
func `shl`*(x: StUint, y: SomeInteger): StUint {.inline.} =
  ## Logical shift right
  ## Similar to C standard, result is undefined if y is bigger
  ## than the number of bits in x.
  result.data = x.data shl y

import ./private/uint_highlow

func high*[bits: static[int]](_: typedesc[Stuint[bits]]): Stuint[bits] {.inline.} =
  ## Returns the highest unsigned int of this size. I.e. bits are all ones.
  result.data = high(type result.data)

func low*[bits: static[int]](_: typedesc[Stuint[bits]]): Stuint[bits] {.inline.} =
  ## Returns the lowest unsigned int of this size. This is always 0.
  result.data = low(type result.data)

import ./private/bithacks

func countLeadingZeroBits*(x: Stuint): int {.inline.} =
  ## Logical count of leading zeros
  ## This corresponds to the number of zero bits of the input in
  ## its big endian representation.
  ## If input is zero, the number of bits of the number is returned.
  x.data.countLeadingZeroBits

import ./private/initialization

func zero*[bits: static[int]](T: typedesc[Stuint[bits] or Stint[bits]]): T {.inline.} =
  ## Returns the zero of the input type
  discard

func one*[bits: static[int]](T: typedesc[Stuint[bits]]): T {.inline.} =
  ## Returns the one of the input type
  result.data = one(type result.data)

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

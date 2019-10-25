# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  macros,
        ./conversion,
        ./initialization,
        ./datatypes,
        ./uint_comparison,
        ./uint_addsub

# ################### Multiplication ################### #

func lo(x: uint64): uint64 {.inline.} =
  const
    p: uint64 = 32
    base: uint64 = 1'u64 shl p
    mask: uint64 = base - 1
  result = x and mask

func hi(x: uint64): uint64 {.inline.} =
  const
    p = 32
  result = x shr p

# No generic, somehow Nim is given ambiguous call with the T: UintImpl overload
func extPrecMul*(result: var UintImpl[uint8], x, y: uint8) {.inline.}=
  ## Extended precision multiplication
  result = cast[type result](x.asDoubleUint * y.asDoubleUint)

func extPrecMul*(result: var UintImpl[uint16], x, y: uint16) {.inline.}=
  ## Extended precision multiplication
  result = cast[type result](x.asDoubleUint * y.asDoubleUint)

func extPrecMul*(result: var UintImpl[uint32], x, y: uint32) {.inline.}=
  ## Extended precision multiplication
  result = cast[type result](x.asDoubleUint * y.asDoubleUint)

func extPrecAddMul[T: uint8 or uint16 or uint32](result: var UintImpl[T], x, y: T) {.inline.}=
  ## Extended precision fused in-place addition & multiplication
  result += cast[type result](x.asDoubleUint * y.asDoubleUint)

template extPrecMulImpl(result: var UintImpl[uint64], op: untyped, u, v: uint64) =
  const
    p = 64 div 2
    base: uint64 = 1'u64 shl p

  var
    x0, x1, x2, x3: uint64

  let
    ul = lo(u)
    uh = hi(u)
    vl = lo(v)
    vh = hi(v)

  x0 = ul * vl
  x1 = ul * vh
  x2 = uh * vl
  x3 = uh * vh

  x1 += hi(x0)          # This can't carry
  x1 += x2              # but this can
  if x1 < x2:           # if carry, add it to x3
    x3 += base

  op(result.hi, x3 + hi(x1))
  op(result.lo, (x1 shl p) or lo(x0))

func extPrecMul*(result: var UintImpl[uint64], u, v: uint64) =
  ## Extended precision multiplication
  extPrecMulImpl(result, `=`, u, v)

func extPrecAddMul(result: var UintImpl[uint64], u, v: uint64) =
  ## Extended precision fused in-place addition & multiplication
  extPrecMulImpl(result, `+=`, u, v)

macro eqSym(x, y: untyped): untyped =
  let eq = $x == $y # Unfortunately eqIdent compares to string.
  result = newLit eq

func extPrecAddMul[T](result: var UintImpl[UintImpl[T]], u, v: UintImpl[T])
func extPrecMul*[T](result: var UintImpl[UintImpl[T]], u, v: UintImpl[T])
  # Forward declaration

template extPrecMulImpl*[T](result: var UintImpl[UintImpl[T]], op: untyped, x, y: UintImpl[T]) =
  # See details at
  # https://en.wikipedia.org/wiki/Karatsuba_algorithm
  # https://locklessinc.com/articles/256bit_arithmetic/
  # https://www.miracl.com/press/missing-a-trick-karatsuba-variations-michael-scott
  #
  # We use the naive school grade multiplication instead of Karatsuba I.e.
  # z1 = x.hi * y.lo + x.lo * y.hi (Naive) = (x.lo - x.hi)(y.hi - y.lo) + z0 + z2 (Karatsuba)
  #
  # On modern architecture:
  #   - addition and multiplication have the same cost
  #   - Karatsuba would require to deal with potentially negative intermediate result
  #     and introduce branching
  #   - More total operations means more register moves

  var z1: type x

  # Low part and hi part - z0 & z2
  when eqSym(op, `+=`):
    extPrecAddMul(result.lo, x.lo, y.lo)
    extPrecAddMul(result.hi, x.hi, y.hi)
  else:
    extPrecMul(result.lo, x.lo, y.lo)
    extPrecMul(result.hi, x.hi, y.hi)

  ## TODO - fuse those parts and reduce the number of carry checks
  # Middle part - z1 - 1st mul
  extPrecMul(z1, x.hi, y.lo)
  result.lo.hi += z1.lo
  if result.lo.hi < z1.lo:
    inc result.hi

  result.hi.lo += z1.hi
  if result.hi.lo < z1.hi:
    inc result.hi.hi

  # Middle part - z1 - 2nd mul
  extPrecMul(z1, x.lo, y.hi)
  result.lo.hi += z1.lo
  if result.lo.hi < z1.lo:
    inc result.hi

  result.hi.lo += z1.hi
  if result.hi.lo < z1.hi:
    inc result.hi.hi

func extPrecAddMul[T](result: var UintImpl[UintImpl[T]], u, v: UintImpl[T]) =
  ## Extended precision fused in-place addition & multiplication
  extPrecMulImpl(result, `+=`, u, v)

func extPrecMul*[T](result: var UintImpl[UintImpl[T]], u, v: UintImpl[T]) =
  ## Extended precision multiplication
  extPrecMulImpl(result, `=`, u, v)

func `*`*[T](x, y: UintImpl[T]): UintImpl[T] {.inline.}=
  ## Multiplication for multi-precision unsigned uint
  #
  # For our representation, it is similar to school grade multiplication
  # Consider hi and lo as if they were digits
  #
  #     12
  # X   15
  # ------
  #     10   lo*lo -> z0
  #     5    hi*lo -> z1
  #     2    lo*hi -> z1
  #    10    hi*hi -- z2
  # ------
  #    180
  #
  # If T is a type
  # For T * T --> T we don't need to compute z2 as it always overflow
  # For T * T --> 2T (uint64 * uint64 --> uint128) we use extra precision multiplication

  extPrecMul(result, x.lo, y.lo)
  result.hi += x.lo * y.hi + x.hi * y.lo

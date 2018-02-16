# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import  ./private/utils,
        uint_type,
        uint_comparison

proc `+=`*[T: MpUint](x: var T, y: T) {.noSideEffect.}=
  ## In-place addition for multi-precision unsigned int
  #
  # Optimized assembly should contain adc instruction (add with carry)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type MpBase = type x.lo
  let tmp = x.lo

  x.lo += y.lo
  x.hi += MpBase(x.lo < tmp) + y.hi

proc `+`*[T: MpUint](x, y: T): T {.noSideEffect, noInit, inline.}=
  # Addition for multi-precision unsigned int
  result = x
  result += y

proc `-=`*[T: MpUint](x: var T, y: T) {.noSideEffect.}=
  ## In-place substraction for multi-precision unsigned int
  #
  # Optimized assembly should contain sbb instruction (substract with borrow)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type MpBase = type x.lo
  let tmp = x.lo

  x.lo -= y.lo
  x.hi -= MpBase(x.lo > tmp) + y.hi

proc `-`*[T: MpUint](x, y: T): T {.noSideEffect, noInit, inline.}=
  # Substraction for multi-precision unsigned int
  result = x
  result -= y

proc naiveMul[T: BaseUint](x, y: T): MpUint[T] {.noSideEffect, noInit, inline.}
  # Forward declaration

proc `*`*[T: MpUint](x, y: T): T {.noSideEffect, noInit.}=
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

  result = naiveMul(x.lo, y.lo)
  result.hi += (naiveMul(x.hi, y.lo) + naiveMul(x.lo, y.hi)).lo

template naiveMulImpl[T: MpUint](x, y: T): MpUint[T] =
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

  let  # cannot be const, compile-time sizeof only works for simple types
    size = T.sizeof * 8
    halfSize = size div 2
  let
    z0 = naiveMul(x.lo, y.lo)
    tmp = naiveMul(x.hi, y.lo)

  var z1 = tmp
  z1 += naiveMul(x.hi, y.lo)
  let z2 = (z1 < tmp).T + naiveMul(x.hi, y.hi)

  result.lo = z1.lo shl halfSize + z0
  result.hi = z2 + z1.hi

proc naiveMul[T: BaseUint](x, y: T): MpUint[T] {.noSideEffect, noInit, inline.}=
  ## Naive multiplication algorithm with extended precision

  when T.sizeof in {1, 2, 4}:
    # Use types twice bigger to do the multiplication
    cast[type result](x.asDoubleUint * y.asDoubleUint)

  elif T.sizeof == 8: # uint64 or MpUint[uint32]
    # We cannot double uint64 to uint128
    naiveMulImpl(x.toMpUint, y.toMpUint)
  else:
    # Case: at least uint128 * uint128 --> uint256
    naiveMulImpl(x, y)


# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import  ./private/utils,
        uint_type

proc `+=`*[T: MpUint](a: var T, b: T) {.noSideEffect.}=
  ## In-place addition for multi-precision unsigned int
  #
  # Optimized assembly should contain adc instruction (add with carry)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type Base = type a.lo
  let tmp = a.lo

  a.lo += b.lo
  a.hi += (a.lo < tmp).Base + b.hi

proc `+`*[T: MpUint](a, b: T): T {.noSideEffect, noInit, inline.}=
  # Addition for multi-precision unsigned int
  result = a
  result += b

proc `-=`*[T: MpUint](a: var T, b: T) {.noSideEffect.}=
  ## In-place substraction for multi-precision unsigned int
  #
  # Optimized assembly should contain sbb instruction (substract with borrow)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type MPBase = type a.lo
  let tmp = a.lo

  a.lo -= b.lo
  a.hi -= (a.lo > tmp).MPBase + b.hi

proc `-`*[T: MpUint](a, b: T): T {.noSideEffect, noInit, inline.}=
  # Substraction for multi-precision unsigned int
  result = a
  result -= b

proc karatsuba[T: BaseUint](a, b: T): MpUint[T] {.noSideEffect, noInit, inline.}
  # Forward declaration

proc `*`*[T: MpUint](a, b: T): T {.noSideEffect, noInit.}=
  ## Multiplication for multi-precision unsigned uint
  #
  # We use a modified Karatsuba algorithm
  #
  # Karatsuba algorithm splits the operand into `hi * B + lo`
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
  # For T * T --> 2T (uint64 * uint64 --> uint128) we use the full precision Karatsuba algorithm

  result = karatsuba(a.lo, b.lo)
  result.hi += (karatsuba(a.hi, b.lo) + karatsuba(a.lo, b.hi)).lo

template karatsubaImpl[T: MpUint](x, y: T): MpUint[T] =
  # https://en.wikipedia.org/wiki/Karatsuba_algorithm
  let
    z0 = karatsuba(x.lo, y.lo)
    tmp = karatsuba(x.hi, y.lo)

  var z1 = tmp
  z1 += karatsuba(x.hi, y.lo)
  let z2 = (z1 < tmp).T + karatsuba(x.hi, y.hi)

  result.lo = z1.lo shl 32 + z0
  result.hi = z2 + z1.hi

proc karatsuba[T: BaseUint](a, b: T): MpUint[T] {.noSideEffect, noInit, inline.}=
  ## Karatsuba algorithm with full precision

  when T.sizeof in {1, 2, 4}:
    # Use types twice bigger to do the multiplication
    cast[type result](a.asDoubleUint * b.asDoubleUint)

  elif T.sizeof == 8: # uint64 or MpUint[uint32]
    # We cannot double uint64 to uint128
    # We use the Karatsuba algorithm
    karatsubaImpl(cast[MpUint[uint32]](a), cast[MpUint[uint32]](b))
  else:
    # Case: at least uint128 * uint128 --> uint256
    karatsubaImpl(a, b)
# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./bithacks, ./conversion,
        ./uint_type,
        ./uint_comparison,
        ./uint_bitwise_ops,
        ./size_mpuintimpl

# ############ Addition & Substraction ############ #

proc `+=`*(x: var MpUintImpl, y: MpUintImpl) {.noSideEffect, inline.}=
  ## In-place addition for multi-precision unsigned int

  type SubTy = type x.lo
  x.lo += y.lo
  x.hi += (x.lo < y.lo).toSubtype(SubTy) + y.hi

proc `+`*(x, y: MpUintImpl): MpUintImpl {.noSideEffect, noInit, inline.}=
  # Addition for multi-precision unsigned int
  result = x
  result += y

proc `-`*(x, y: MpUintImpl): MpUintImpl {.noSideEffect, noInit, inline.}=
  # Substraction for multi-precision unsigned int

  type SubTy = type x.lo
  result.lo = x.lo - y.lo
  result.hi = x.hi - y.hi - (x.lo < y.lo).toSubtype(SubTy)

proc `-=`*(x: var MpUintImpl, y: MpUintImpl) {.noSideEffect, inline.}=
  ## In-place substraction for multi-precision unsigned int
  x = x - y

# ################### Multiplication ################### #

proc naiveMulImpl[T: MpUintImpl](x, y: T): MpUintImpl[T] {.noSideEffect, noInit, inline.}
  # Forward declaration

proc naiveMul*[T: BaseUint](x, y: T): MpUintImpl[T] {.noSideEffect, noInit, inline.}=
  ## Naive multiplication algorithm with extended precision

  const size = size_mpuintimpl(x)

  when size in {8, 16, 32}:
    # Use types twice bigger to do the multiplication
    cast[type result](x.asDoubleUint * y.asDoubleUint)

  elif size == 64: # uint64 or MpUint[uint32]
    # We cannot double uint64 to uint128
    cast[type result](naiveMulImpl(x.toMpUintImpl, y.toMpUintImpl))
  else:
    # Case: at least uint128 * uint128 --> uint256
    cast[type result](naiveMulImpl(x, y))


proc naiveMulImpl[T: MpUintImpl](x, y: T): MpUintImpl[T] {.noSideEffect, noInit, inline.}=
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

  const halfSize = size_mpuintimpl(x) div 2
  let
    z0 = naiveMul(x.lo, y.lo)
    tmp = naiveMul(x.hi, y.lo)

  var z1 = tmp
  z1 += naiveMul(x.hi, y.lo)
  let z2 = (z1 < tmp).toSubtype(T) + naiveMul(x.hi, y.hi)

  let tmp2  = initMpUintImpl(z1.lo shl halfSize, T)
  result.lo = tmp2
  result.lo += z0
  result.hi = (result.lo < tmp2).toSubtype(T) + z2 + initMpUintImpl(z1.hi, type result.hi)

proc `*`*(x, y: MpUintImpl): MpUintImpl {.noSideEffect, noInit.}=
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

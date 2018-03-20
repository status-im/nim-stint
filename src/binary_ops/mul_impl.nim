# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../uint_type, ../uint_init
import ./addsub_impl

## Implementation of multiplication

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

import typetraits

proc `*`*(x, y: MpUint): MpUint {.noSideEffect.}=
  ## Multiplication for multi-precision unsigned uint

  mixin naiveMul

  result = naiveMul(x.lo, y.lo)
  result.hi += (naiveMul(x.hi, y.lo) + naiveMul(x.lo, y.hi)).lo

  debugEcho "*: " & $result
  debugEcho "* type: " & $result.type.name

# proc naiveMulImpl[bits: static[int]](x, y: MpUint[bits]): MpUint[bits * 2] {.noSideEffect.}=
#   ## Naive multiplication algorithm with extended precision
#   ## i.e. we use types twice bigger to do the multiplication
#   ## and only keep the bottom part

#   mixin naiveMul

#   const
#     halfSize = bits div 2

#   let
#     z0 = naiveMul(x.lo, y.lo)
#     tmp = naiveMul(x.hi, y.lo)

#   var z1 = tmp
#   z1 += naiveMul(x.hi, y.lo)
#   let z2 = (z1 < tmp).T + naiveMul(x.hi, y.hi)

#   let tmp2  = z1.lo shl halfSize
#   result.lo = tmp2
#   result.lo += z0
#   result.hi = (result.lo < tmp2).T + z2 + z1.hi

# proc naiveMul*[bits: static[int]](x, y: MpUint[bits]): MpUint[bits * 2] {.noSideEffect.}=
#   naiveMulImpl(x, y)

proc naiveMul*(x, y: float): MpUint[16] {.noSideEffect.}=
  result = toMpuint(x.uint16 * y.uint16)

proc naiveMul*(x, y: uint16): MpUint[32] {.noSideEffect.}=
  result = toMpuint(x.uint32 * y.uint32)
  debugEcho "naiveMul cast:" & $result

proc naiveMul*(x, y: uint32): MpUint[64] {.noSideEffect.}=
  toMpuint(x.uint64 * y.uint64)

# proc naiveMul*(x, y: uint64): MpUint[128] {.noSideEffect, noInit, inline.}=
#   let x = x.toMpUint
#   let y = y.toMpUint

#   naiveMulImpl[64](x, y)

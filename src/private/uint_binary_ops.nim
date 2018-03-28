# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./bithacks, ./conversion, ./stdlib_bitops,
        ./uint_type,
        ./uint_comparison,
        ./uint_bitwise_ops,
        ./size_mpuintimpl

# ############ Addition & Substraction ############ #

proc `+=`*(x: var MpUintImpl, y: MpUintImpl) {.noSideEffect, inline.}=
  ## In-place addition for multi-precision unsigned int
  #
  # Optimized assembly should contain adc instruction (add with carry)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type SubTy = type x.lo
  let tmp = x.lo

  x.lo += y.lo
  x.hi += (x.lo < tmp).toSubtype(SubTy) + y.hi

proc `+`*(x, y: MpUintImpl): MpUintImpl {.noSideEffect, noInit, inline.}=
  # Addition for multi-precision unsigned int
  result = x
  result += y

proc `-=`*(x: var MpUintImpl, y: MpUintImpl) {.noSideEffect, inline.}=
  ## In-place substraction for multi-precision unsigned int
  #
  # Optimized assembly should contain sbb instruction (substract with borrow)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type SubTy = type x.lo
  let tmp = x.lo

  x.lo -= y.lo
  x.hi -= (x.lo > tmp).toSubtype(SubTy) + y.hi

proc `-`*(x, y: MpUintImpl): MpUintImpl {.noSideEffect, noInit, inline.}=
  # Substraction for multi-precision unsigned int
  result = x
  result -= y


# ################### Multiplication ################### #

proc naiveMulImpl[T: MpUintImpl](x, y: T): MpUintImpl[T] {.noSideEffect, noInit, inline.}
  # Forward declaration
import typetraits
proc naiveMul[T: BaseUint](x, y: T): MpUintImpl[T] {.noSideEffect, noInit, inline.}=
  ## Naive multiplication algorithm with extended precision

  const size = size_mpuintimpl(x)

  when size in {8, 16, 32}:
    # Use types twice bigger to do the multiplication
    cast[type result](x.asDoubleUint * y.asDoubleUint)

  elif size == 64: # uint64 or MpUint[uint32]
    # We cannot double uint64 to uint128
    static:
      echo "####"
      echo x.type.name
      echo size
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


# ################### Division ################### #
from ./primitive_divmod import divmod

proc divmod*(x, y: MpUintImpl): tuple[quot, rem: MpUintImpl] {.noSideEffect.}

proc div2n1n[T: BaseUint](x_hi, x_lo, y: T): tuple[quot, rem: T] {.noSideEffect, noInit.} =
  const
    size = size_mpuintimpl(x_hi)
    halfSize = size div 2
    halfMask = (one(T) shl halfSize) - one(T)
    base = one(T) shl halfSize

  if unlikely(x_hi >= y):
    raise newException(ValueError, "Division overflow")

  let clz = countLeadingZeroBits(y) # We assume that for 0 clz returns 0

  # normalization, shift so that the MSB is at 2^n
  let xn = MpUintImpl[T](hi: x_hi, lo: x_lo) shl clz
  let yn = y shl clz

  # Break divisor in 2 and dividend in 4
  let yn_hi = yn shr halfSize
  let yn_lo = yn and halfMask

  let xnlohi = xn.lo shr halfSize
  let xnlolo = xn.lo and halfMask

  # First half of the quotient
  var (q1, r) = divmod(xn.hi, yn_hi)

  while (q1 >= base) or ((q1 * yn_lo) > (base * r + xnlohi)):
    q1 -= one(T)
    r += yn_hi
    if r >= base:
      break

  # Remove it
  let xn_rest = xn.hi shl halfSize + xnlohi - (q1 * yn)

  # Second half
  var (q2, s) = divmod(xn_rest, yn_hi)

  var
    q2_ynlo = q2 * yn_lo
    sbase_xnlolo = (s shl halfSize) or xnlolo

  while (q2 >= base) or (q2_ynlo > sbase_xnlolo):
    q2 -= one(T)
    s += yn_hi
    if s >= base:
      break
    else:
      q2_ynlo -= yn_lo
      sbase_xnlolo = (s shl halfSize) or xnlolo


  result.quot = (q1 shl halfSize) or q2
  result.rem = ((xn_rest shl halfSize) + xnlolo - q2 * yn) shr clz

proc divmod*(x, y: MpUintImpl): tuple[quot, rem: MpUintImpl] {.noSideEffect.}=

  # Using divide and conquer algorithm.
  if y.hi.isZero:
    if x.hi < y.lo: # Bit length of quotient x/y < bit_length(MpUintImpl) / 2
      (result.quot.lo, result.rem.lo) = div2n1n(x.hi, x.lo, y.lo)
    else:           # Quotient can overflow the subtype so we split work
      (result.quot.hi, result.rem.hi) = divmod(x.hi, y.hi)
      (result.quot.lo, result.rem.lo) = div2n1n(result.rem.hi, x.lo, y.lo)
      result.rem.hi = zero(type result.rem.hi)
    return

  const
    size = size_mpuintimpl(x)
    halfSize = size div 2

  block:
    # Normalization of divisor
    let clz = countLeadingZeroBits(x.hi)
    let yn = (y shl clz)

    # Prevent overflows
    let xn = x shr 1

    # Get the quotient
    block:
      let (qlo, _) = div2n1n(x.hi, x.lo, yn.hi)
      result.quot.lo = qlo

    # Undo normalization
    result.quot = result.quot shr (halfSize - 1 - clz) # -1 to correct for xn shift

  if not result.quot.isZero:
    result.quot -= one(type result.quot)
  # Quotient is correct or too small by one
  # We will fix that once we know the remainder

  # Remainder
  result.rem = x - (y * result.quot)

  # Fix quotient and reminder if we're off by one
  if result.rem >= y:
    # one more division round
    result.quot += one(type result.quot)
    result.rem -= y

proc `div`*(x, y: MpUintImpl): MpUintImpl {.inline, noSideEffect.} =
  ## Division operation for multi-precision unsigned uint
  divmod(x,y).quot

proc `mod`*(x, y: MpUintImpl): MpUintImpl {.inline, noSideEffect.} =
  ## Division operation for multi-precision unsigned uint
  divmod(x,y).rem


# ######################################################################
# Division implementations
#
# Division is the most costly operation
# And also of critical importance for cryptography application

# ##### Research #####

# Overview of division algorithms:
# - https://gmplib.org/manual/Division-Algorithms.html#Division-Algorithms
# - https://gmplib.org/~tege/division-paper.pdf
# - Comparison of fast division algorithms for large integers: http://bioinfo.ict.ac.cn/~dbu/AlgorithmCourses/Lectures/Hasselstrom2003.pdf

# Libdivide has an implementations faster than hardware if dividing by the same number is needed
# - http://libdivide.com/documentation.html
# - https://github.com/ridiculousfish/libdivide/blob/master/libdivide.h
# Furthermore libdivide also has branchless implementations

# Current implementation
# Currently we use the divide and conquer algorithm. Implementations can be found in
# - Hacker's delight: http://www.hackersdelight.org/hdcodetxt/divDouble.c.txt
# - Libdivide
# - Code project: https://www.codeproject.com/Tips/785014/UInt-Division-Modulus
# - Cuda-uint128 (unfinished): https://github.com/curtisseizert/CUDA-uint128/blob/master/cuda_uint128.h
# - Mpdecimal: https://github.com/status-im/nim-decimal/blob/9b65e95299cb582b14e0ae9a656984a2ce0bab03/decimal/mpdecimal_wrapper/generated/basearith.c#L305-L412

# Probably the most efficient algorithm that can benefit from MpUInt recursive data structure is
# the recursive fast division by Burnikel and Ziegler (http://www.mpi-sb.mpg.de/~ziegler/TechRep.ps.gz):
#  - Python implementation: https://bugs.python.org/file11060/fast_div.py and discussion https://bugs.python.org/issue3451
#  - C++ implementation: https://github.com/linbox-team/givaro/blob/master/src/kernel/recint/rudiv.h
#  - The Handbook of Elliptic and Hyperelliptic Cryptography Algorithm 10.35 on page 188 has a more explicit version of the div2NxN algorithm. This algorithm is directly recursive and avoids the mutual recursion of the original paper's calls between div2NxN and div3Nx2N.

# Other libraries that can be used as reference for alternative (?) implementations:
# - TTMath: https://github.com/status-im/nim-ttmath/blob/8f6ff2e57b65a350479c4012a53699e262b19975/src/headers/ttmathuint.h#L1530-L2383
# - LibTomMath: https://github.com/libtom/libtommath
# - Google Abseil: https://github.com/abseil/abseil-cpp/tree/master/absl/numeric
# - Crypto libraries like libsecp256k1, OpenSSL, ... though they are not generics. (uint256 only for example)
# Note: GMP/MPFR are GPL. The papers can be used but not their code.

# ######################################################################
# School division

# proc divmod*(x, y: MpUintImpl): tuple[quot, rem: MpUintImpl] {.noSideEffect.}=
#   ## Division for multi-precision unsigned uint
#   ## Returns quotient + reminder in a (quot, rem) tuple
#   #
#   # Implementation through binary shift division
#   if unlikely(y.isZero):
#     raise newException(DivByZeroError, "You attempted to divide by zero")

#   type SubTy = type x.lo

#   var
#     shift = x.bit_length - y.bit_length
#     d = y shl shift

#   result.rem  = x

#   while shift >= 0:
#     result.quot += result.quot
#     if result.rem >= d:
#       result.rem -= d
#       result.quot.lo = result.quot.lo or one(SubTy)

#     d = d shr 1
#     dec(shift)


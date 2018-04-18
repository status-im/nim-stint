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
        ./size_mpuintimpl,
        bitops

# ############ Addition & Substraction ############ #

proc `+=`*(x: var MpUintImpl, y: MpUintImpl) {.noSideEffect, inline.}=
  ## In-place addition for multi-precision unsigned int
  #
  # Optimized assembly should contain adc instruction (add with carry)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type SubTy = type x.lo
  x.lo += y.lo
  x.hi += (x.lo < y.lo).toSubtype(SubTy) + y.hi

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
  let original = x.lo
  x.lo -= y.lo
  x.hi -= (original < x.lo).toSubtype(SubTy) + y.hi

proc `-`*(x, y: MpUintImpl): MpUintImpl {.noSideEffect, noInit, inline.}=
  # Substraction for multi-precision unsigned int
  result = x
  result -= y


# ################### Multiplication ################### #

proc naiveMulImpl[T: MpUintImpl](x, y: T): MpUintImpl[T] {.noSideEffect, noInit, inline.}
  # Forward declaration

proc naiveMul[T: BaseUint](x, y: T): MpUintImpl[T] {.noSideEffect, noInit, inline.}=
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


# ################### Division ################### #
from ./primitive_divmod import divmod

func div3n2n( q, r1, r0: var MpUintImpl,
              a2, a1, a0: MpUintImpl,
              b1, b0: MpUintImpl) {.inline.}=
  mixin div2n1n

  type T = type q

  var
    c: T
    carry: bool

  if a2 < b1:
    div2n1n(q, c, a2, a1, b1)
  else:
    q = zero(T) - one(T) # We want 0xFFFFF ....
    c = a1 + b1
    if c < a1:
      carry = true

  let
    d = naiveMul(q, b0)
    r = MpUintImpl[T](hi: c, lo: a0) - d
    b = MpUintImpl[T](hi: b1, lo: b0)

  if  (not carry) and (d > r):
    q -= 1
    r += b

    if r > b:
      q -= one(T)
      r += b

  r1 = r.hi
  r0 = r.lo

func div3n2n( q, r1, r0: var SomeUnsignedInt,
              a2, a1, a0: SomeUnsignedInt,
              b1, b0: SomeUnsignedInt) {.inline.}=
  mixin div2n1n

  type T = type q

  var
    c: T
    carry: bool

  if a2 < b1:
    div2n1n(q, c, a2, a1, b1)
  else:
    q = 0.T - 1.T # We want 0xFFFFF ....
    c = a1 + b1
    if c < a1:
      carry = true

  let
    d = naiveMul(q, b0)
    b = MpUintImpl[T](hi: b1, lo: b0)

  var r = MpUintImpl[T](hi: c, lo: a0) - d

  if  (not carry) and (d > r):
    q -= 1.T
    r += b

    if r > b:
      q -= 1.T
      r += b

  r1 = r.hi
  r0 = r.lo

func div2n1n*(q, r: var MpUintImpl, ah, al, b: MpUintImpl) {.inline.} =
  var s: MpUintImpl
  div3n2n(q.hi, s.hi, s.lo, ah.hi, ah.lo, al.hi, b.hi, b.lo)
  div3n2n(q.lo, r.hi, r.lo, s.hi, s.lo, al.lo, b.hi, b.lo)

func div2n1n*[T: SomeunsignedInt](q, r: var T, n_hi, n_lo, d: T) {.inline.} =

  assert countLeadingZeroBits(d) == 0, "Divisor was not normalized"

  const
    size = size_mpuintimpl(q)
    halfSize = size div 2
    halfMask = (1.T shl halfSize) - 1.T

  template halfQR(n_hi, n_lo, d_hi, d_lo: T): tuple[q,r: T] =

    var (q, r) = divmod(n_hi, d_hi)
    let m = q * d_lo
    r = (r shl halfSize) or n_lo

    # Fix the reminder, we're at most 2 iterations off
    if r < m:
      q -= 1.T
      r += d_hi
      if r >= d_hi and r < m:
        q -= 1.T
        r += d_hi
    r -= m
    (q, r)

  let
    d_hi = d shr halfSize
    d_lo = d and halfMask
    n_lohi = nlo shr halfSize
    n_lolo = nlo and halfMask

  # First half of the quotient
  let (q1, r1) = halfQR(n_hi, n_lohi, d_hi, d_lo)

  # Second half
  let (q2, r2) = halfQR(r1, n_lolo, d_hi, d_lo)

  q = (q1 shl halfSize) or q2
  r = r2

func divmod*(x, y: MpUintImpl): tuple[quot, rem: MpUintImpl] =

  # Normalization
  assert y.isZero.not()

  const halfSize = size_mpuintimpl(x) div 2
  let clz = countLeadingZeroBits(y)

  let
    xx_hi = if clz < halfSize: (x shr (halfSize - clz))
            else: x shl (clz - halfSize)
    xx_lo = if clz < halfSize: x shl clz
            else: zero(type x)
    yy = y shl clz

  # Compute
  div2n1n(result.quot, result.rem, xx_hi, xx_lo, yy)

  # Undo normalization
  result.rem = result.rem shr clz

func `div`*(x, y: MpUintImpl): MpUintImpl {.inline.} =
  ## Division operation for multi-precision unsigned uint
  divmod(x,y).quot

func `mod`*(x, y: MpUintImpl): MpUintImpl {.inline.} =
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

# Implementation: we use recursive fast division by Burnikel and Ziegler.
#
# It is build upon divide and conquer algorithm that can be found in:
# - Hacker's delight: http://www.hackersdelight.org/hdcodetxt/divDouble.c.txt
# - Libdivide
# - Code project: https://www.codeproject.com/Tips/785014/UInt-Division-Modulus
# - Cuda-uint128 (unfinished): https://github.com/curtisseizert/CUDA-uint128/blob/master/cuda_uint128.h
# - Mpdecimal: https://github.com/status-im/nim-decimal/blob/9b65e95299cb582b14e0ae9a656984a2ce0bab03/decimal/mpdecimal_wrapper/generated/basearith.c#L305-L412

# Description of recursive fast division by Burnikel and Ziegler (http://www.mpi-sb.mpg.de/~ziegler/TechRep.ps.gz):
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


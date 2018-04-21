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
        ./uint_addsub,
        ./uint_mul,
        ./size_mpuintimpl,
        ./primitive_divmod

# ################### Division ################### #
# We use the following algorithm:
#  - Fast recursive division by Burnikel and Ziegler

###################################################################################################################
##                                                                                                               ##
##  Grade school division, but with (very) large digits, dividing [a1,a2,a3,a4] by [b1,b2]:                      ##
##                                                                                                               ##
##    +----+----+----+----+     +----+----+   +----+                                                             ##
##    | a1 | a2 | a3 | a4 |  /  | b1 | b2 | = | q1 |        DivideThreeHalvesByTwo(a1a2, a3, b1b2, n, q1, r1r2)  ##
##    +----+----+----+----+     +----+----+   +----+                                                             ##
##    +--------------+  |                       |                                                                ##
##    |   b1b2 * q1  |  |                       |                                                                ##
##    +--------------+  |                       |                                                                ##
##  - ================  v                       |                                                                ##
##         +----+----+----+     +----+----+     |  +----+                                                        ##
##         | r1 | r2 | a4 |  /  | b1 | b2 | =   |  | q2 |   DivideThreeHalvesByTwo(r1r2, a4, b1b2, n, q1, r1r2)  ##
##         +----+----+----+     +----+----+     |  +----+                                                        ##
##         +--------------+                     |    |                                                           ##
##         |   b1b2 * q2  |                     |    |                                                           ##
##         +--------------+                     |    |                                                           ##
##       - ================                     v    v                                                           ##
##              +----+----+                   +----+----+                                                        ##
##              | r1 | r2 |                   | q1 | q2 |   r1r2 = a1a2a3a4 mod b1b2, q1q2 = a1a2a3a4 div b1b2   ##
##              +----+----+                   +----+----+ ,                                                      ##
##                                                                                                               ##
##  Note: in the diagram above, a1, b1, q1, r1 etc. are the most significant "digits" of their numbers.          ##
##                                                                                                               ##
###################################################################################################################

func div2n1n[T: SomeunsignedInt](q, r: var T, n_hi, n_lo, d: T)
func div2n1n(q, r: var MpUintImpl, ah, al, b: MpUintImpl)
  # Forward declaration

func div3n2n[T]( q: var MpUintImpl[T],
              r: var MpUintImpl[MpUintImpl[T]],
              a2, a1, a0: MpUintImpl[T],
              b: MpUintImpl[MpUintImpl[T]]) =

  var
    c: MpUintImpl[T]
    d: MpUintImpl[MpUintImpl[T]]
    carry: bool

  if a2 < b.hi:
    div2n1n(q, c, a2, a1, b.hi)
  else:
    q = zero(type q) - one(type q) # We want 0xFFFFF ....
    c = a1 + b.hi
    if c < a1:
      carry = true

  extPrecMul[T](d, q, b.lo)
  let ca0 = MpUintImpl[type c](hi: c, lo: a0)

  r = ca0 - d

  if (not carry) and (d > ca0):
    q -= one(type q)
    r += b

    # if there was no carry
    if r > b:
      q -= one(type q)
      r += b

proc div3n2n[T: SomeUnsignedInt](
              q: var T,
              r: var MpUintImpl[T],
              a2, a1, a0: T,
              b: MpUintImpl[T]) =

  var
    c: T
    d: MpUintImpl[T]
    carry: bool

  if a2 < b.hi:
    div2n1n(q, c, a2, a1, b.hi)

  else:
    q = 0.T - 1.T # We want 0xFFFFF ....
    c = a1 + b.hi
    if c < a1:
      carry = true

  extPrecMul[T](d, q, b.lo)
  let ca0 = MpUintImpl[T](hi: c, lo: a0)
  r = ca0 - d

  if  (not carry) and d > ca0:
    dec q
    r += b

    # if there was no carry
    if r > b:
      dec q
      r += b

func div2n1n(q, r: var MpUintImpl, ah, al, b: MpUintImpl) =

  # assert countLeadingZeroBits(b) == 0, "Divisor was not normalized"

  var s: MpUintImpl
  div3n2n(q.hi, s, ah.hi, ah.lo, al.hi, b)
  div3n2n(q.lo, r, s.hi, s.lo, al.lo, b)

func div2n1n[T: SomeunsignedInt](q, r: var T, n_hi, n_lo, d: T) =

  # assert countLeadingZeroBits(d) == 0, "Divisor was not normalized"

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
      dec q
      r += d_hi
      if r >= d_hi and r < m:
        dec q
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

func divmod*[T](x, y: MpUintImpl[T]): tuple[quot, rem: MpUintImpl[T]]
  # Forward declaration

func divmodBZ[T](x, y: MpUintImpl[T], q, r: var MpUintImpl[T])=

  assert y.isZero.not() # This should be checked on release mode in the divmod caller proc

  if y.hi.isZero:
    # Shortcut if divisor is smaller than half the size of the type

    # Normalize
    let
      clz = countLeadingZeroBits(y.lo)
      xx = x shl clz
      yy = y.lo shl clz

    if x.hi < y.lo:
      # If y is smaller than the base, normalizing x does not overflow.
      # Compute directly
      div2n1n(q.lo, r.lo, xx.hi, xx.lo, yy)
      # Undo normalization
      r.lo = r.lo shr clz
    else:
      # Normalizing x overflowed, we need to compute the high remainder first
      (q.hi, r.hi) = divmod(x.hi, y.lo)

      # Normalize the remainder. (x.lo is already normalized)
      r.hi = r.hi shl clz

      # Compute
      div2n1n(q.lo, r.lo, r.hi, xx.lo, yy)

      # Undo normalization
      r.lo = r.lo shr clz

      # Given size n, dividing a 2n number by a 1n normalized number
      # always gives a 1n remainder.
      r.hi = zero(T)

  else: # General case
    # Normalization
    let clz = countLeadingZeroBits(y)

    let
      xx = MpUintImpl[type x](lo: x) shl clz
      yy = y shl clz

    # Compute
    div2n1n(q, r, xx.hi, xx.lo, yy)

    # Undo normalization
    r = r shr clz

func divmodBS(x, y: MpUintImpl, q, r: var MpuintImpl) =
  ## Division for multi-precision unsigned uint
  ## Implementation through binary shift division

  assert y.isZero.not() # This should be checked on release mode in the divmod caller proc

  type SubTy = type x.lo

  var
    shift = x.countLeadingZeroBits - y.countLeadingZeroBits
    d = y shl shift

  r = x

  while shift >= 0:
    q += q
    if r >= d:
      r -= d
      q.lo = q.lo or one(SubTy)

    d = d shr 1
    dec(shift)

const BinaryShiftThreshold = 8  # If the difference in bit-length is below 8
                                # binary shift is probably faster

func divmod*[T](x, y: MpUintImpl[T]): tuple[quot, rem: MpUintImpl[T]]=

  let x_clz = x.countLeadingZeroBits
  let y_clz = y.countLeadingZeroBits

  # We short-circuit division depending on special-cases.
  # TODO: Constant-time division
  if unlikely(y.isZero):
    raise newException(DivByZeroError, "You attempted to divide by zero")
  elif y_clz == (size_mpuintimpl(y) - 1):
    # y is one
    result.quot = x
  elif (x.hi or y.hi).isZero:
    # If computing just on the low part is enough
    (result.quot.lo, result.rem.lo) = divmod(x.lo, y.lo)
  elif (y and (y - one(type y))).isZero:
    # y is a power of 2. (this also matches 0 but it was eliminated earlier)
    # TODO. Would it be faster to use countTrailingZero (ctz) + clz == size(y) - 1?
    #       Especially because we shift by ctz after.
    #       It is a bit tricky with recursive types. An empty n.lo means 0 or sizeof(n.lo)
    let y_ctz = size_mpuintimpl(y) - y_clz - 1
    result.quot = x shr y_ctz
    result.rem = y_ctz.initMpUintImpl(MpUintImpl[T])
    result.rem = result.rem and x
  elif x == y:
    result.quot.lo = one(T)
  elif x < y:
    result.rem = x
  elif (y_clz - x_clz) < BinaryShiftThreshold:
    divmodBS(x, y, result.quot, result.rem)
  else:
    divmodBZ(x, y, result.quot, result.rem)

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
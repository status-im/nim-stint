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
        ./uint_binary_ops,
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

func div2n1n[T: SomeunsignedInt](q, r: var T, n_hi, n_lo, d: T) {.inline.}
func div2n1n(q, r: var MpUintImpl, ah, al, b: MpUintImpl) {.inline.}
  # Forward declaration

func div3n2n[T]( q, r1, r0: var MpUintImpl[T],
              a2, a1, a0: MpUintImpl[T],
              b1, b0: MpUintImpl[T]) {.inline.}=
  mixin div2n1n

  type T = type q

  var
    c: T
    carry: bool

  if a2 < b1:
    div2n1n(q, c, a2, a1, b1)
  else:
    q = zero(type q) - one(type q) # We want 0xFFFFF ....
    c = a1 + b1
    if c < a1:
      carry = true

  let
    d = naiveMul(q, b0)
    b = MpUintImpl[type c](hi: b1, lo: b0)

  var r = MpUintImpl[type c](hi: c, lo: a0) - d

  if  (not carry) and (d > r):
    q -= one(type q)
    r += b

    if r > b:
      q -= one(type q)
      r += b

  r1 = r.hi
  r0 = r.lo

template sub_ddmmss[T](sh, sl, ah, al, bh, bl: T) =
  sl = al - bl
  sh = ah - bh - (al < bl).T

func lo[T:SomeUnsignedInt](x: T): T {.inline.} =
  const
    p = T.sizeof * 8 div 2
    base = 1 shl p
    mask = base - 1
  result = x and mask

func hi[T:SomeUnsignedInt](x: T): T {.inline.} =
  const
    p = T.sizeof * 8 div 2
  result = x shr p

func umul_ppmm[T](w1, w0: var T, u, v: T) =

  const
    p = (T.sizeof * 8 div 2)
    base = 1 shl p

  var
    x0, x1, x2, x3: T

  let
    ul = u.lo
    uh = u.hi
    vl = v.lo
    vh = v.hi

  x0 = ul * vl
  x1 = ul * vh
  x2 = uh * vl
  x3 = uh * vh

  x1 += x0.hi           # This can't carry
  x1 += x2              # but this can
  if x1 < x2:           # if carry, add it to x3
    x3 += base

  w1 = x3 + x1.hi
  w0 = (x1 shl p) + x0.lo


proc div3n2n( q, r1, r0: var SomeUnsignedInt,
              a2, a1, a0: SomeUnsignedInt,
              b1, b0: SomeUnsignedInt) {.inline.}=
  mixin div2n1n

  type T = type q

  var
    c, d1, d0: T
    carry: bool

  if a2 < b1:
    div2n1n(q, c, a2, a1, b1)

  else:
    q = 0.T - 1.T # We want 0xFFFFF ....
    c = a1 + b1
    if c < a1:
      carry = true

  umul_ppmm(d1, d0, q, b0)
  sub_ddmmss(r1, r0, c, a0, d1, d0)

  if  (not carry) and ((d1 > c) or ((d1 == c) and (d0 > a0))):
    q -= 1.T
    r0 += b0
    r1 += b1
    if r0 < b0:
      inc r1

    if (r1 > b1) or ((r1 == b1) and (r0 >= b0)):
      q -= 1.T
      r0 += b0
      r1 += b1
      if r0 < b0:
        inc r1

func div2n1n(q, r: var MpUintImpl, ah, al, b: MpUintImpl) {.inline.} =

  # assert countLeadingZeroBits(b) == 0, "Divisor was not normalized"

  var s: MpUintImpl
  div3n2n(q.hi, s.hi, s.lo, ah.hi, ah.lo, al.hi, b.hi, b.lo)
  div3n2n(q.lo, r.hi, r.lo, s.hi, s.lo, al.lo, b.hi, b.lo)

func div2n1n[T: SomeunsignedInt](q, r: var T, n_hi, n_lo, d: T) {.inline.} =

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

func divmod*[T](x, y: MpUintImpl[T]): tuple[quot, rem: MpUintImpl[T]] =

  # Normalization
  assert y.isZero.not()

  const halfSize = size_mpuintimpl(x) div 2
  let clz = countLeadingZeroBits(y)

  let
    xx = MpUintImpl[type x](lo: x) shl clz
    yy = y shl clz

  # Compute
  div2n1n(result.quot, result.rem, xx.hi, xx.lo, yy)

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

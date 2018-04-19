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
import strutils

func tohexBE[T: uint8 or uint16 or uint32 or uint64](x: T): string =

  let bytes = cast[array[T.sizeof, byte]](x)

  result = ""
  for i in countdown(T.sizeof - 1, 0):
    result.add toHex(bytes[i])

func tohexBE(x: MpUintImpl): string =

  const size = size_mpuintimpl(x) div 8
  debugecho "Size MpUintImpl: " & $size

  let bytes = cast[array[size, byte]](x)
  result = ""
  for i in countdown(size - 1, 0):
    result.add toHex(bytes[i])

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

import strformat

proc div3n2n( q, r1, r0: var SomeUnsignedInt,
              a2, a1, a0: SomeUnsignedInt,
              b1, b0: SomeUnsignedInt) {.inline.}=
  debugecho "\n Entering div3n2n"
  mixin div2n1n

  type T = type q

  var
    c, d1, d0: T
    carry: bool

  if a2 < b1:
    # debugecho "Branch a2 < b1"
    div2n1n(q, c, a2, a1, b1)
    # debugecho &"q: {q}, bytes: {toBytes(q)}"
    # debugecho &"c: {c}, bytes: {toBytes(c)}"

  else:
    # debugecho "Branch a2 >= b1"
    q = 0.T - 1.T # We want 0xFFFFF ....
    c = a1 + b1
    if c < a1:
      carry = true

  # debugecho &"q: {q}, bytes: {toBytes(q)}"
  # debugecho &"b0: {b0}, bytes: {toBytes(b0)}"

  umul_ppmm(d1, d0, q, b0)
  # debugecho &"d1: {d1}, bytes: {toBytes(d1)}"
  # debugecho &"d0: {d0}, bytes: {toBytes(d0)}"
  # debugecho &"q * b0: {q * b0}, bytes: {toBytes(q * b0)}"

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

func div2n1n*(q, r: var MpUintImpl, ah, al, b: MpUintImpl) {.inline.} =

  # assert countLeadingZeroBits(b) == 0, "Divisor was not normalized"

  # debugecho "\nhere div2n1n - MpUintImpl"
  # debugecho "ah: " & $ah
  # debugecho "al: " & $al
  # debugecho "b: " & $b
  # debugecho "q: " & $q
  # debugecho "r: " & $r

  var s: MpUintImpl
  div3n2n(q.hi, s.hi, s.lo, ah.hi, ah.lo, al.hi, b.hi, b.lo)

  # debugecho "\n1st part - div2n1n - MpUintImpl"
  # debugecho "q: " & $q
  # debugecho "s: " & $s
  # debugecho "r: " & $r

  div3n2n(q.lo, r.hi, r.lo, s.hi, s.lo, al.lo, b.hi, b.lo)

  # debugecho "\n2nd part - div2n1n - MpUintImpl"
  # debugecho "q: " & $q
  # debugecho "r: " & $r
  # debugecho "\n"

func div2n1n*[T: SomeunsignedInt](q, r: var T, n_hi, n_lo, d: T) {.inline.} =

  debugecho "here div2n1n - Normal Int"

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

  debugecho "\nEntering div2n1n"
  debugecho "x: " & x.toHexBE
  debugecho "y: " & y.toHexBE

  debugecho "Clz: " & $clz
  debugecho "xx_hi: " & xx.hi.toHexBE
  debugecho "xx_lo: " & xx.lo.toHexBE
  debugecho "yy: "    & yy.toHexBE

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


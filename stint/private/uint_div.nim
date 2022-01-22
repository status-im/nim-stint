# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Status lib
  stew/bitops2,
  # Internal
  ./datatypes,
  ./uint_bitwise,
  ./uint_shift,
  ./primitives/[addcarry_subborrow, extended_precision]

# Division
# --------------------------------------------------------

func shortDiv*(a: var Limbs, k: Word): Word =
  ## Divide `a` by k in-place and return the remainder
  result = Word(0)

  let clz = leadingZeros(k)
  let normK = k shl clz

  for i in countdown(a.len-1, 0):
    # dividend = 2^64 * remainder + a[i]
    var hi = result
    var lo = a[i]
    # Normalize, shifting the remainder by clz(k) cannot overflow.
    hi = (hi shl clz) or (lo shr (WordBitWidth - clz))
    lo = lo shl clz
    div2n1n(a[i], result, hi, lo, normK)
    # Undo normalization
    result = result shr clz

# func binaryShiftDiv[qLen, rLen, uLen, vLen: static int](
#        q: var Limbs[qLen],
#        r: var Limbs[rLen],
#        u: Limbs[uLen],
#        v: Limbs[vLen]) =
#   ## Division for multi-precision unsigned uint
#   ## Implementation through binary shift division
#   doAssert y.isZero.not() # This should be checked on release mode in the divmod caller proc

#   type SubTy = type x.lo

#   var
#     shift = y.leadingZeros - x.leadingZeros
#     d = y shl shift

#   r = x

#   while shift >= 0:
#     q += q
#     if r >= d:
#       r -= d
#       q.lo = q.lo or one(SubTy)

#     d = d shr 1
#     dec(shift)

func knuthDivLE(
       q: var StUint,
       r: var StUint,
       u: StUint,
       v: StUint,
       needRemainder: bool) =
  ## Compute the quotient and remainder (if needed)
  ## of the division of u by v
  ##
  ## - q must be of size uLen - vLen + 1 (assuming u and v uses all words)
  ## - r must be of size vLen (assuming v uses all words)
  ## - uLen >= vLen
  ##
  ## For now only LittleEndian is implemented
  #
  # Resources at the bottom of the file

  const
    qLen = q.limbs.len
    rLen = r.limbs.len
    uLen = u.limbs.len
    vLen = v.limbs.len

  template `[]`(a: Stuint, i: int): Word = a.limbs[i]
  template `[]=`(a: Stuint, i: int, val: Word) = a.limbs[i] = val

  # Find the most significant word with actual set bits
  # and get the leading zero count there
  var divisorLen = vLen
  var clz: int
  for w in mostToLeastSig(v):
    if w != 0:
      clz = leadingZeros(w)
      break
    else:
      divisorLen -= 1

  doAssert divisorLen != 0, "Division by zero. Abandon ship!"

  # Divisor is a single word.
  if divisorLen == 1:
    q.copyFrom(u)
    r.leastSignificantWord() = q.limbs.shortDiv(v.leastSignificantWord())
    # zero all but the least significant word
    var lsw = true
    for w in leastToMostSig(r):
      if lsw:
        lsw = false
      else:
        w = 0
    return

  var un {.noInit.}: Limbs[uLen+1]
  var vn {.noInit.}: Limbs[vLen] # [mswLen .. vLen] range is unused

  # Normalize so that the divisor MSB is set,
  # vn cannot overflow, un can overflowed by 1 word at most, hence uLen+1
  un.shlSmallOverflowing(u.limbs, clz)
  vn.shlSmall(v.limbs, clz)

  static: doAssert cpuEndian == littleEndian, "Currently the division algorithm requires little endian ordering of the limbs"
  # TODO: is it worth it to have the uint be the exact same extended precision representation
  # as a wide int (say uint128 or uint256)?
  # in big-endian, the following loop must go the other way and the -1 must be +1

  let vhi = vn[divisorLen-1]
  let vlo = vn[divisorLen-2]

  for j in countdown(uLen - divisorLen, 0, 1):
    # Compute qhat estimate of q[j] (off by 0, 1 and rarely 2)
    var qhat, rhat: Word
    let uhi = un[j+divisorLen]
    let ulo = un[j+divisorLen-1]
    div2n1n(qhat, rhat, uhi, ulo, vhi)
    var mhi, mlo: Word
    var rhi, rlo: Word
    mul(mhi, mlo, qhat, vlo)
    rhi = rhat
    rlo = ulo

    # if r < m, adjust approximation, up to twice
    while rhi < mhi or (rhi == mhi and rlo < mlo):
      qhat -= 1
      rhi += vhi

    # Found the quotient
    q[j] = qhat

    # un -= qhat * v
    var borrow = Borrow(0)
    var qvhi, qvlo: Word
    for i in 0 ..< divisorLen-1:
      mul(qvhi, qvlo, qhat, v[i])
      subB(borrow, un[j+i], un[j+i], qvlo, borrow)
      subB(borrow, un[j+i+1], un[j+i+1], qvhi, borrow)
    # Last step
    mul(qvhi, qvlo, qhat, v[divisorLen-1])
    subB(borrow, un[j+divisorLen-1], un[j+divisorLen-1], qvlo, borrow)
    qvhi += Word(borrow)
    let isNeg = un[j+divisorLen] < qvhi
    un[j+divisorLen] -= qvhi

    if isNeg:
      # oops, too big by one, add back
      q[j] -= 1
      var carry = Carry(0)
      for i in 0 ..< divisorLen:
        addC(carry, un[j+i], un[j+i], v[i], carry)

  # Quotient is found, if remainder is needed we need to un-normalize un
  if needRemainder:
    # r.limbs.shrSmall(un, clz) - TODO
    when cpuEndian == littleEndian:
      # rLen+1 == un.len
      for i in 0 ..< rLen:
        r[i] = (un[i] shr clz) or (un[i+1] shl (WordBitWidth - clz))
    else:
      {.error: "Not Implemented for bigEndian".}


const BinaryShiftThreshold = 8  # If the difference in bit-length is below 8
                                # binary shift is probably faster

func divmod(q, r: var Stuint,
<<<<<<< HEAD
    x: Limbs[xLen], y: Limbs[yLen], needRemainder: bool) =
=======
            x, y: Stuint, needRemainder: bool) =

>>>>>>> 88858a7 (uint division - compile and pass the single limb tests)
  let x_clz = x.leadingZeros()
  let y_clz = y.leadingZeros()

  # We short-circuit division depending on special-cases.
<<<<<<< HEAD
  if unlikely(y.isZero):
    raise newException(DivByZeroDefect, "You attempted to divide by zero")
  elif y_clz == (bitsof(y) - 1):
=======
  if unlikely(y.isZero()):
    raise newException(DivByZeroError, "You attempted to divide by zero")
  elif y_clz == (y.bits - 1):
>>>>>>> 88858a7 (uint division - compile and pass the single limb tests)
    # y is one
    q = x
  # elif (x.hi or y.hi).isZero:
  #   # If computing just on the low part is enough
  #   (result.quot.lo, result.rem.lo) = divmod(x.lo, y.lo, needRemainder)
  # elif (y and (y - one(type y))).isZero:
  #   # y is a power of 2. (this also matches 0 but it was eliminated earlier)
  #   # TODO. Would it be faster to use countTrailingZero (ctz) + clz == size(y) - 1?
  #   #       Especially because we shift by ctz after.
  #   let y_ctz = bitsof(y) - y_clz - 1
  #   result.quot = x shr y_ctz
  #   if needRemainder:
  #     result.rem = x and (y - one(type y))
  elif x == y:
    q.setOne()
  elif x < y:
    r = x
  # elif (y_clz - x_clz) < BinaryShiftThreshold:
  #   binaryShiftDiv(x, y, result.quot, result.rem)
  else:
    knuthDivLE(q, r, x, y, needRemainder)

func `div`*(x, y: Stuint): Stuint {.inline.} =
  ## Division operation for multi-precision unsigned uint
  var tmp{.noInit.}: Stuint
  divmod(result, tmp, x, y, needRemainder = false)

func `mod`*(x, y: Stuint): Stuint {.inline.} =
  ## Remainder operation for multi-precision unsigned uint
  var tmp{.noInit.}: Stuint
  divmod(tmp, result, x, y, needRemainder = true)

func divmod*(x, y: Stuint): tuple[quot, rem: Stuint] =
  ## Division and remainder operations for multi-precision unsigned uint
  divmod(result.quot, result.rem, x, y, needRemainder = true)

# ######################################################################
# Division implementations
#
# Multi-precision division is a costly
#and also difficult to implement operation

# ##### Research #####

# Overview of division algorithms:
# - https://gmplib.org/manual/Division-Algorithms.html#Division-Algorithms
# - https://gmplib.org/~tege/division-paper.pdf
# - Comparison of fast division algorithms for large integers: http://bioinfo.ict.ac.cn/~dbu/AlgorithmCourses/Lectures/Lec5-Fast-Division-Hasselstrom2003.pdf

# Schoolbook / Knuth Division (Algorithm D)
# - https://skanthak.homepage.t-online.de/division.html
#   Review of implementation flaws
# - Hacker's Delight https://github.com/hcs0/Hackers-Delight/blob/master/divmnu64.c.txt
# - LLVM: https://github.com/llvm-mirror/llvm/blob/2c4ca68/lib/Support/APInt.cpp#L1289-L1451
# - ctbignum: https://github.com/niekbouman/ctbignum/blob/v0.5/include/ctbignum/division.hpp
# - Modern Computer Arithmetic - https://members.loria.fr/PZimmermann/mca/mca-cup-0.5.9.pdf
#   p14 - 1.4.1 Naive Division
# - Handbook of Applied Cryptography - https://cacr.uwaterloo.ca/hac/about/chap14.pdf
#   Chapter 14 algorithm 14.2.5

# Smith Method (and derivatives)
# This method improves Knuth algorithm by ~3x by removing regular normalization
# - A Multiple-Precision Division Algorithm, David M Smith
#   American mathematical Society, 1996
#   https://www.ams.org/journals/mcom/1996-65-213/S0025-5718-96-00688-6/S0025-5718-96-00688-6.pdf
#
# - An Efficient Multiple-Precision Division Algorithm,
#   Liusheng Huang, Hong Zhong, Hong Shen, Yonglong Luo, 2005
#   https://ieeexplore.ieee.org/document/1579076
#
# - Efficient multiple-precision integer division algorithm
#   Debapriyay Mukhopadhyaya, Subhas C.Nandy, 2014
#   https://www.sciencedirect.com/science/article/abs/pii/S0020019013002627

# Recursive division by Burnikel and Ziegler (http://www.mpi-sb.mpg.de/~ziegler/TechRep.ps.gz):
# - Python implementation: https://bugs.python.org/file11060/fast_div.py and discussion https://bugs.python.org/issue3451
# - C++ implementation: https://github.com/linbox-team/givaro/blob/master/src/kernel/recint/rudiv.h
# - The Handbook of Elliptic and Hyperelliptic Cryptography Algorithm 10.35 on page 188 has a more explicit version of the div2NxN algorithm. This algorithm is directly recursive and avoids the mutual recursion of the original paper's calls between div2NxN and div3Nx2N.
# - Modern Computer Arithmetic - https://members.loria.fr/PZimmermann/mca/mca-cup-0.5.9.pdf
#   p18 - 1.4.3 Divide and Conquer Division

# Newton Raphson Iterations
# - Putty (constant-time): https://github.com/github/putty/blob/0.74/mpint.c#L1818-L2112
# - Modern Computer Arithmetic - https://members.loria.fr/PZimmermann/mca/mca-cup-0.5.9.pdf
#   p18 - 1.4.3 Divide and Conquer Division

# Other libraries that can be used as reference for alternative (?) implementations:
# - TTMath: https://github.com/status-im/nim-ttmath/blob/8f6ff2e57b65a350479c4012a53699e262b19975/src/headers/ttmathuint.h#L1530-L2383
# - LibTomMath: https://github.com/libtom/libtommath
# - Google Abseil for uint128: https://github.com/abseil/abseil-cpp/tree/master/absl/numeric
# Note: GMP/MPFR are GPL. The papers can be used but not their code.

# Related research
# - Efficient divide-and-conquer multiprecision integer division
#   William Hart, IEEE 2015
#   https://github.com/wbhart/bsdnt
#   https://ieeexplore.ieee.org/document/7203801
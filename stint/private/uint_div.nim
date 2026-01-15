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
  intops/ops/division,
  # Internal
  ./datatypes,
  ./uint_bitwise,
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
    if hi == 0:
      if lo < k:
        a[i] = 0
      elif lo == k:
        a[i] = 1
        result = 0
      continue
    # Normalize, shifting the remainder by clz(k) cannot overflow.
    hi = (hi shl clz) or (lo shr (WordBitWidth - clz))
    lo = lo shl clz
    div2n1n(a[i], result, hi, lo, normK)
    # Undo normalization
    result = result shr clz

func shlAddMod_multi(a: var openArray[Word], c: Word,
                     M: openArray[Word], mBits: int): Word =
  ## Fused modular left-shift + add
  ## Shift input `a` by a word and add `c` modulo `M`
  ##
  ## Specialized for M being a multi-precision integer.
  ##
  ## With a word W = 2^WordBitWidth and a modulus M
  ## Does a <- a * W + c (mod M)
  ## and returns q = (a * W + c ) / M
  ##
  ## The modulus `M` most-significant bit at `mBits` MUST be set.

                                        # Assuming 64-bit words
  let hi = a[^1]                        # Save the high word to detect carries
  let R = mBits and (WordBitWidth - 1)  # R = mBits mod 64

  var a0, a1, m0: Word
  if R == 0:                            # If the number of mBits is a multiple of 64
    a0 = a[^1]                          #
    copyWords(a, 1, a, 0, a.len-1)      # we can just shift words
    a[0] = c                            # and replace the first one by c
    a1 = a[^1]
    m0 = M[^1]
  else:                                 # Else: need to deal with partial word shifts at the edge.
    let clz = WordBitWidth-R
    a0 = (a[^1] shl clz) or (a[^2] shr R)
    copyWords(a, 1, a, 0, a.len-1)
    a[0] = c
    a1 = (a[^1] shl clz) or (a[^2] shr R)
    m0 = (M[^1] shl clz) or (M[^2] shr R)

  # m0 has its high bit set. (a0, a1)/m0 fits in a limb.
  # Get a quotient q, at most we will be 2 iterations off
  # from the true quotient
  var q: Word                           # Estimate quotient
  if a0 == m0:                          # if a_hi == divisor
    q = high(Word)                      # quotient = MaxWord (0b1111...1111)
  elif a0 == 0 and a1 < m0:             # elif q == 0, true quotient = 0
    q = 0
    return q
  else:
    var r: Word
    div2n1n(q, r, a0, a1, m0)           # else instead of being of by 0, 1 or 2
    q -= 1                              # we return q-1 to be off by -1, 0 or 1

  # Now substract a*2^64 - q*m
  var carry = Word(0)
  var overM = true                      # Track if quotient greater than the modulus

  for i in 0 ..< M.len:
    var qm_lo: Word
    block:                              # q*m
      # q * p + carry (doubleword) carry from previous limb
      muladd1(carry, qm_lo, q, M[i], carry)

    block:                              # a*2^64 - q*m
      var borrow: Borrow
      subB(borrow, a[i], a[i], qm_lo, Borrow(0))
      carry += Word(borrow) # Adjust if borrow

    if a[i] != M[i]:
      overM = a[i] > M[i]

  # Fix quotient, the true quotient is either q-1, q or q+1
  #
  # if carry < q or carry == q and overM we must do "a -= M"
  # if carry > hi (negative result) we must do "a += M"
  if carry > hi:
    var c = Carry(0)
    for i in 0 ..< a.len:
      addC(c, a[i], a[i], M[i], c)
    q -= 1
  elif overM or (carry < hi):
    var b = Borrow(0)
    for i in 0 ..< a.len:
      subB(b, a[i], a[i], M[i], b)
    q += 1

  return q

func shlAddMod(a: var openArray[Word], c: Word,
               M: openArray[Word], mBits: int): Word {.inline.} =
  ## Fused modular left-shift + add
  if mBits <= WordBitWidth:
    # Intops narrowingDiv handles normalization internally.
    # We pass the raw accumulator (a[0]), the new limb (c), and the modulus (M[0]).
    # It calculates: (a[0] * 2^64 + c) div M[0]
    # And returns the correct quotient and remainder.
    
    let (q, r) = narrowingDiv(a[0], c, M[0])
    
    a[0] = r
    return q
  else:
    return shlAddMod_multi(a, c, M, mBits)

func divRem*(
       q, r: var openArray[Word],
       a, b: openArray[Word]
     ) =
  let (aBits, aLen) = usedBitsAndWords(a)
  let (bBits, bLen) = usedBitsAndWords(b)
  let rLen = bLen

  if unlikely(bBits == 0):
    raise newException(DivByZeroDefect, "You attempted to divide by zero")

  if aBits < bBits:
    # if a uses less bits than b,
    # a < b, so q = 0 and r = a
    copyWords(r, 0, a, 0, aLen)
    for i in aLen ..< r.len: # r.len >= rLen
      r[i] = 0
    for i in 0 ..< q.len:
      q[i] = 0
  else:
    # The length of a is at least the divisor
    # We can copy bLen-1 words
    # and modular shift-lef-add the rest
    let aOffset = aLen - bLen
    copyWords(r, 0, a, aOffset+1, bLen-1)
    r[rLen-1] = 0
    # Now shift-left the copied words while adding the new word mod b

    when nimvm:
      # workaround nim bug #22095
      var rr = @(r.toOpenArray(0, rLen-1))
      var bb = @(b.toOpenArray(0, bLen-1))
      for i in countdown(aOffset, 0):
        q[i] = shlAddMod(
          rr,
          a[i],
          bb,
          bBits
        )
      for i in 0..rLen-1:
        r[i] = rr[i]
    else:
      for i in countdown(aOffset, 0):
        q[i] = shlAddMod(
          r.toOpenArray(0, rLen-1),
          a[i],
          b.toOpenArray(0, bLen-1),
          bBits
        )

    # Clean up extra words
    for i in aOffset+1 ..< q.len:
      q[i] = 0
    for i in rLen ..< r.len:
      r[i] = 0

# ######################################################################
# Division implementations
#
# Multi-precision division is a costly
# and also difficult to implement operation

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

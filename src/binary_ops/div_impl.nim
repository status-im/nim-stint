# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

# proc divmod*(x, y: MpUint): tuple[quot, rem: MpUint] {.noSideEffect.}=
#   ## Division for multi-precision unsigned uint
#   ## Returns quotient + reminder in a (quot, rem) tuple
#   #
#   # Implementation through binary shift division
#   const zero = T()

#   when x.lo is MpUInt:
#     const one = T(lo: getSubType(T)(1))
#   else:
#     const one: getSubType(T) = 1

#   if unlikely(y.isZero):
#     raise newException(DivByZeroError, "You attempted to divide by zero")

#   var
#     shift = x.bit_length - y.bit_length
#     d = y shl shift

#   result.rem  = x

#   while shift >= 0:
#     result.quot += result.quot
#     if result.rem >= d:
#       result.rem -= d
#       result.quot.lo = result.quot.lo or one

#     d = d shr 1
#     dec(shift)

#   # Performance note:
#   # The performance of this implementation is extremely dependant on shl and shr.
#   #
#   # Probably the most efficient algorithm that can benefit from MpUInt data structure is
#   # the recursive fast division by Burnikel and Ziegler (http://www.mpi-sb.mpg.de/~ziegler/TechRep.ps.gz):
#   #  - Python implementation: https://bugs.python.org/file11060/fast_div.py and discussion https://bugs.python.org/issue3451
#   #  - C++ implementation: https://github.com/linbox-team/givaro/blob/master/src/kernel/recint/rudiv.h
#   #  - The Handbook of Elliptic and Hyperelliptic Cryptography Algorithm 10.35 on page 188 has a more explicit version of the div2NxN algorithm. This algorithm is directly recursive and avoids the mutual recursion of the original paper's calls between div2NxN and div3Nx2N.
#   #  - Comparison of fast division algorithms fro large integers: http://bioinfo.ict.ac.cn/~dbu/AlgorithmCourses/Lectures/Hasselstrom2003.pdf

# proc `div`*(x, y: MpUint): MpUint {.inline, noSideEffect.} =
#   ## Division operation for multi-precision unsigned uint
#   divmod(x,y).quot

# proc `mod`*(x, y: MpUint): MpUint {.inline, noSideEffect.} =
#   ## Division operation for multi-precision unsigned uint
#   divmod(x,y).rem

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
  ./uint_shift

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

func binaryShiftDiv[qLen, rLen, uLen, vLen: static int](
       q: var Limbs[qLen],
       r: var Limbs[rLen],
       u: Limbs[uLen],
       v: Limbs[vLen]) =
  ## Division for multi-precision unsigned uint
  ## Implementation through binary shift division
  doAssert y.isZero.not() # This should be checked on release mode in the divmod caller proc

  type SubTy = type x.lo

  var
    shift = y.leadingZeros - x.leadingZeros
    d = y shl shift

  r = x

  while shift >= 0:
    q += q
    if r >= d:
      r -= d
      q.lo = q.lo or one(SubTy)

    d = d shr 1
    dec(shift)

func knuthDivLE[qLen, rLen, uLen, vLen: static int](
       q: var Limbs[qLen],
       r: var Limbs[rLen],
       u: Limbs[uLen],
       v: Limbs[vLen],
       needRemainder: bool) =
  ## Compute the quotient and remainder (if needed)
  ## of the division of u by v
  ##
  ## - q must be of size uLen - vLen + 1 (assuming u and v uses all words)
  ## - r must be of size vLen (assuming v uses all words)
  ## - uLen >= vLen
  ##
  ## Knuth Division
  ## - Knuth's "Algorithm D", The Art of Computer Programming, 1998
  ## - Warren, Hacker's Delight, 2013
  ##
  ## For now only LittleEndian is implemented

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

  doAssert msw != 0, "Division by zero. Abandon ship!"

  if mswLen == 1:
    q.copyFrom(u)
    r.leastSignificantWord() = q.shortDiv(v.leastSignificantWord())
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
  un.shlSmallOverflowing(u, clz)
  vn.shlSmall(v, clz)

  static: doAssert cpuEndian == littleEndian, "As it is the division algorithm requires little endian ordering of the limbs".
  # TODO: is it worth it to have the uint be the exact same extended precision representation
  # as a wide int (say uint128 or uint256)?
  # in big-endian, the following loop must go the other way and the -1 must be +1
  for j in countdown(uLen - divisorLen, 0, 1):
    # Compute qhat estimate of q[j] (off by 0, 1 and rarely 2)
    var qhat, rhat: Word
    let hi = un[j+divisorLen]
    let lo = un[j+divisorLen-1]
    div2n1n(qhat, rhat, hi, lo, vn[divisorLen-1])


const BinaryShiftThreshold = 8  # If the difference in bit-length is below 8
                                # binary shift is probably faster

func divmod*[T](x, y: UintImpl[T]): tuple[quot, rem: UintImpl[T]]=

  let x_clz = x.leadingZeros()
  let y_clz = y.leadingZeros()

  # We short-circuit division depending on special-cases.
  if unlikely(y.isZero):
    raise newException(DivByZeroDefect, "You attempted to divide by zero")
  elif y_clz == (bitsof(y) - 1):
    # y is one
    result.quot = x
  elif (x.hi or y.hi).isZero:
    # If computing just on the low part is enough
    (result.quot.lo, result.rem.lo) = divmod(x.lo, y.lo)
  elif (y and (y - one(type y))).isZero:
    # y is a power of 2. (this also matches 0 but it was eliminated earlier)
    # TODO. Would it be faster to use countTrailingZero (ctz) + clz == size(y) - 1?
    #       Especially because we shift by ctz after.
    let y_ctz = bitsof(y) - y_clz - 1
    result.quot = x shr y_ctz
    result.rem = x and (y - one(type y))
  elif x == y:
    result.quot.lo = one(T)
  elif x < y:
    result.rem = x
  elif (y_clz - x_clz) < BinaryShiftThreshold:
    binaryShiftDiv(x, y, result.quot, result.rem)
  else:
    divmodBZ(x, y, result.quot, result.rem)

func `div`*(x, y: UintImpl): UintImpl {.inline.} =
  ## Division operation for multi-precision unsigned uint
  divmod(x,y).quot

func `mod`*(x, y: UintImpl): UintImpl {.inline.} =
  ## Division operation for multi-precision unsigned uint
  divmod(x,y).rem

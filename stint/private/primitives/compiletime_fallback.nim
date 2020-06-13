# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../datatypes

# ############################################################
#
#                 VM fallback for uint64
#
# ############################################################

const
  uint64BitWidth = 64
  HalfWidth = uint64BitWidth shr 1
  HalfBase = 1'u64 shl HalfWidth
  HalfMask = HalfBase - 1

func hi(n: uint64): uint64 =
  result = n shr HalfWidth

func lo(n: uint64): uint64 =
  result = n and HalfMask

func split(n: uint64): tuple[hi, lo: uint64] =
  result.hi = n.hi
  result.lo = n.lo

func merge(hi, lo: uint64): uint64 =
  (hi shl HalfWidth) or lo

func addC_nim*(cOut: var Carry, sum: var uint64, a, b: uint64, cIn: Carry) =
  # Add with carry, fallback for the Compile-Time VM
  # (CarryOut, Sum) <- a + b + CarryIn
  let (aHi, aLo) = split(a)
  let (bHi, bLo) = split(b)
  let tLo = aLo + bLo + cIn
  let (cLo, rLo) = split(tLo)
  let tHi = aHi + bHi + cLo
  let (cHi, rHi) = split(tHi)
  cOut = Carry(cHi)
  sum = merge(rHi, rLo)

func subB_nim*(bOut: var Borrow, diff: var uint64, a, b: uint64, bIn: Borrow) =
  # Substract with borrow, fallback for the Compile-Time VM
  # (BorrowOut, Sum) <- a - b - BorrowIn
  let (aHi, aLo) = split(a)
  let (bHi, bLo) = split(b)
  let tLo = HalfBase + aLo - bLo - bIn
  let (noBorrowLo, rLo) = split(tLo)
  let tHi = HalfBase + aHi - bHi - uint64(noBorrowLo == 0)
  let (noBorrowHi, rHi) = split(tHi)
  bOut = Borrow(noBorrowHi == 0)
  diff = merge(rHi, rLo)

func mul_nim*(hi, lo: var uint64, u, v: uint64) =
  ## Extended precision multiplication
  ## (hi, lo) <- u * v
  var x0, x1, x2, x3: uint64

  let
    (uh, ul) = u.split()
    (vh, vl) = v.split()

  x0 = ul * vl
  x1 = ul * vh
  x2 = uh * vl
  x3 = uh * vh

  x1 += hi(x0)          # This can't carry
  x1 += x2              # but this can
  if x1 < x2:           # if carry, add it to x3
    x3 += HalfBase

  hi = x3 + hi(x1)
  lo = merge(x1, lo(x0))

func muladd1*(hi, lo: var uint64, a, b, c: uint64) {.inline.} =
  ## Extended precision multiplication + addition
  ## (hi, lo) <- a*b + c
  ##
  ## Note: 0xFFFFFFFF_FFFFFFFF² -> (hi: 0xFFFFFFFFFFFFFFFE, lo: 0x0000000000000001)
  ##       so adding any c cannot overflow
  var carry: Carry
  mul_nim(hi, lo, a, b)
  addC_nim(carry, lo, lo, c, 0)
  addC_nim(carry, hi, hi, 0, carry)

func muladd2*(hi, lo: var uint64, a, b, c1, c2: uint64) {.inline.}=
  ## Extended precision multiplication + addition + addition
  ## (hi, lo) <- a*b + c1 + c2
  ##
  ## Note: 0xFFFFFFFF_FFFFFFFF² -> (hi: 0xFFFFFFFFFFFFFFFE, lo: 0x0000000000000001)
  ##       so adding 0xFFFFFFFFFFFFFFFF leads to (hi: 0xFFFFFFFFFFFFFFFF, lo: 0x0000000000000000)
  ##       and we have enough space to add again 0xFFFFFFFFFFFFFFFF without overflowing
  var carry1, carry2: Carry

  mul_nim(hi, lo, a, b)
  # Carry chain 1
  addC_nim(carry1, lo, lo, c1, 0)
  addC_nim(carry1, hi, hi, 0, carry1)
  # Carry chain 2
  addC_nim(carry2, lo, lo, c2, 0)
  addC_nim(carry2, hi, hi, 0, carry2)

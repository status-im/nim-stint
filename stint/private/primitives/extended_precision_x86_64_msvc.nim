# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ../datatypes,
  ./addcarry_subborrow

# ############################################################
#
#      Extended precision primitives for X86-64 on MSVC
#
# ############################################################

static:
  doAssert defined(vcc)
  doAssert sizeof(int) == 8
  doAssert X86

func udiv128(highDividend, lowDividend, divisor: Ct[uint64], remainder: var Ct[uint64]): Ct[uint64] {.importc:"_udiv128", header: "<intrin.h>", nodecl.}
  ## Division 128 by 64, Microsoft only, 64-bit only,
  ## returns quotient as return value remainder as var parameter
  ## Warning ⚠️ :
  ##   - if n_hi == d, quotient does not fit in an uint64 and will throw SIGFPE
  ##   - if n_hi > d result is undefined

func umul128(a, b: Ct[uint64], hi: var Ct[uint64]): Ct[uint64] {.importc:"_umul128", header:"<intrin.h>", nodecl.}
  ## (hi, lo) <-- a * b
  ## Return value is the low word

func div2n1n*(q, r: var Ct[uint64], n_hi, n_lo, d: Ct[uint64]) {.inline.}=
    ## Division uint128 by uint64
    ## Warning ⚠️ :
    ##   - if n_hi == d, quotient does not fit in an uint64 and will throw SIGFPE
    ##   - if n_hi > d result is undefined
    q = udiv128(n_hi, n_lo, d, r)

func mul_128*(hi, lo: var Ct[uint64], a, b: Ct[uint64]) {.inline.} =
  ## Extended precision multiplication
  ## (hi, lo) <- a*b
  lo = umul128(a, b, hi)

func muladd1_128*(hi, lo: var Ct[uint64], a, b, c: Ct[uint64]) {.inline.} =
  ## Extended precision multiplication + addition
  ## (hi, lo) <- a*b + c
  ##
  ## Note: 0xFFFFFFFF_FFFFFFFF² -> (hi: 0xFFFFFFFFFFFFFFFE, lo: 0x0000000000000001)
  ##       so adding any c cannot overflow
  var carry: Carry
  lo = umul128(a, b, hi)
  addC(carry, lo, lo, c, Carry(0))
  addC(carry, hi, hi, 0, carry)

func muladd2_128*(hi, lo: var Ct[uint64], a, b, c1, c2: Ct[uint64]) {.inline.}=
  ## Extended precision multiplication + addition + addition
  ## This is constant-time on most hardware except some specific one like Cortex M0
  ## (hi, lo) <- a*b + c1 + c2
  ##
  ## Note: 0xFFFFFFFF_FFFFFFFF² -> (hi: 0xFFFFFFFFFFFFFFFE, lo: 0x0000000000000001)
  ##       so adding 0xFFFFFFFFFFFFFFFF leads to (hi: 0xFFFFFFFFFFFFFFFF, lo: 0x0000000000000000)
  ##       and we have enough space to add again 0xFFFFFFFFFFFFFFFF without overflowing
  # For speed this could be implemented with parallel pipelined carry chains
  # via MULX + ADCX + ADOX
  var carry1, carry2: Carry

  lo = umul128(a, b, hi)
  # Carry chain 1
  addC(carry1, lo, lo, c1, Carry(0))
  addC(carry1, hi, hi, 0, carry1)
  # Carry chain 2
  addC(carry2, lo, lo, c2, Carry(0))
  addC(carry2, hi, hi, 0, carry2)

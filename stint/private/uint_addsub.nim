# Stint
# Copyright 2018-Present Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Internal
  ./datatypes,
  ./primitives/addcarry_subborrow

# Addsub
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func sum*(r: var Stuint, a, b: Stuint) =
  ## Addition for multi-precision unsigned int
  var carry = Carry(0)
  for i in 0 ..< r.limbs.len:
    addC(carry, r[i], a[i], b[i], carry)
  r.clearExtraBitsOverMSB()

func `+=`*(a: var Stuint, b: Stuint) =
  ## In-place addition for multi-precision unsigned int
  a.sum(a, b)

func diff*(r: var Stuint, a, b: Stuint) =
  ## Substraction for multi-precision unsigned int
  var borrow = Borrow(0)
  for i in 0 ..< r.limbs.len:
    subB(borrow, r[i], a[i], b[i], borrow)
  r.clearExtraBitsOverMSB()

func `-=`*(a: var Stuint, b: Stuint) =
  ## In-place substraction for multi-precision unsigned int
  a.diff(a, b)

func inc*(a: var Stuint, w: Word = 1) =
  var carry = Carry(0)
  addC(carry, a.limbs[0], a.limbs[0], w, carry)
  for i in 1 ..< a.limbs.len:
    addC(carry, a.limbs[i], a.limbs[i], 0, carry)
  a.clearExtraBitsOverMSB()

func sum*(r: var Stuint, a: Stuint, b: SomeUnsignedInt) =
  ## Addition for multi-precision unsigned int
  ## with an unsigned integer
  r = a
  r.inc(Word(b))

func `+=`*(a: var Stuint, b: SomeUnsignedInt) =
  ## In-place addition for multi-precision unsigned int
  ## with an unsigned integer
  a.inc(Word(b))

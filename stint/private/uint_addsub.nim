# Stint
# Copyright 2018-Present Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Status Lib
  intops/ops/[add, sub],
  # Internal
  ./datatypes

# Addsub
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

func sum*(r: var StUint, a, b: StUint) =
  ## Addition for multi-precision unsigned int.
  var carry = false
  for i in 0 ..< r.limbs.len:
    (r[i], carry) = carryingAdd(a[i], b[i], carry)
  r.clearExtraBitsOverMSB()

func `+=`*(a: var StUint, b: StUint) =
  ## In-place addition for multi-precision unsigned int.
  a.sum(a, b)

func diff*(r: var StUint, a, b: StUint) =
  ## Substraction for multi-precision unsigned int.
  var borrow = false
  for i in 0 ..< r.limbs.len:
    (r[i], borrow) = borrowingSub(a[i], b[i], borrow)
  r.clearExtraBitsOverMSB()

func `-=`*(a: var StUint, b: StUint) =
  ## In-place substraction for multi-precision unsigned int.
  a.diff(a, b)

func inc*(a: var StUint, w: Word = 1) =
  var carry = false
  (a.limbs[0], carry) = carryingAdd(a.limbs[0], w, carry)
  for i in 1 ..< a.limbs.len:
    (a.limbs[i], carry) = carryingAdd(a.limbs[i], 0, carry)
  a.clearExtraBitsOverMSB()

func sum*(r: var StUint, a: StUint, b: SomeUnsignedInt) =
  ## Addition for multi-precision unsigned int
  ## with an unsigned integer.
  r = a
  r.inc(Word(b))

func `+=`*(a: var StUint, b: SomeUnsignedInt) =
  ## In-place addition for multi-precision unsigned int
  ## with an unsigned integer.
  a.inc(Word(b))

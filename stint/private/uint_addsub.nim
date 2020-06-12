# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ./datatypes,
  ./primitives/addcarry_subborrow

# ############ Addition & Substraction ############ #
{.push raises: [], inline, noInit, gcsafe.}

func `+`*(x, y: Limbs): Limbs =
  # Addition for multi-precision unsigned int
  var carry = Carry(0)
  for wr, wx, wy in leastToMostSig(result, x, y):
    addC(carry, wr, wx, wy, carry)

func `+=`*(x: var Limbs, y: Limbs) =
  ## In-place addition for multi-precision unsigned int
  var carry = Carry(0)
  for wx, wy in leastToMostSig(x, y):
    addC(carry, wx, wx, wy, carry)

func `-`*(x, y: Limbs): Limbs =
  # Substraction for multi-precision unsigned int
  var borrow = Borrow(0)
  for wr, wx, wy in leastToMostSig(result, x, y):
    subB(borrow, wr, wx, wy, borrow)

func `-=`*(x: var Limbs, y: Limbs) =
  ## In-place substraction for multi-precision unsigned int
  var borrow = Borrow(0)
  for wx, wy in leastToMostSig(x, y):
    subB(borrow, wx, wx, wy, borrow)

func inc*(x: var Limbs, w: SomeUnsignedInt = 1) =
  var carry = Carry(0)
  when cpuEndian == littleEndian:
    addC(carry, x[0], x[0], w, carry)
    for i in 1 ..< x.len:
      addC(carry, x[i], x[i], 0, carry)

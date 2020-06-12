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

{.push raises: [], inline, noInit, gcsafe.}

func isZero*(n: SomeUnsignedInt): bool =
  n == 0

func isZero*(limbs: Limbs): bool =
  for word in limbs:
    if not word.isZero():
      return false
  return true

func `<`*(x, y: Limbs): bool =
  # Lower comparison for multi-precision integers
  var diff: Word
  var borrow: Borrow
  for wx, wy in leastToMostSig(x, y):
    subB(borrow, diff, wx, wy, borrow)
  return bool(borrow)

func `==`*(x, y: Limbs): bool =
  # Equal comparison for multi-precision integers
  for wx, wy in leastToMostSig(x, y):
    if wx != wy:
      return false
  return true

func `<=`*(x, y: Limbs): bool =
  # Lower or equal comparison for multi-precision integers
  not(y < x)

func isEven*(x: SomeUnsignedInt): bool =
  (x and 1) == 0

func isEven*(x: Limbs): bool =
  x.leastSignificantWord.isEven

func isOdd*(x: SomeUnsignedInt): bool =
  not x.isEven

func isOdd*(x: Limbs): bool =
  not x.isEven

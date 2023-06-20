# Stint
# Copyright 2018-Present Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ./intops,
  ./modular_arithmetic,
  private/datatypes

{.push raises: [], noinit, gcsafe.}

func addmod*(a, b, m: StInt): StInt =
  ## Modular addition
  let mt = m.abs
  if mt.isOne:
    result.setZero
    return

  if a.isNegative and b.isNegative:
    result.impl = addmod(a.neg.impl, b.neg.impl, mt.impl)
    result.negate
  elif a.isPositive and b.isPositive:
    result.impl = addmod(a.impl, b.impl, mt.impl)
  else:
    result = a + b
    result = result mod mt

func submod*(a, b, m: StInt): StInt =
  ## Modular substraction
  let mt = m.abs
  if mt.isOne:
    result.setZero
    return

  if a.isNegative and b.isPositive:
    result.impl = addmod(a.neg.impl, b.impl, mt.impl)
    result.negate
  elif a.isPositive and b.isNegative:
    result.impl = addmod(a.impl, b.neg.impl, mt.impl)
  else:
    result = a - b
    result = result mod mt

func mulmod*(a, b, m: StInt): StInt =
  ## Modular multiplication

  let mAbs = m.abs
  if (a.isNegative and b.isPositive) or
     (a.isPositive and b.isNegative):
    let xAbs = a.abs
    let yAbs = b.abs
    result.impl = mulmod(xAbs.impl, yAbs.impl, mAbs.impl)
    result.negate
  else:
    var xAbs = a
    var yAbs = b
    if a.isNegative:
      xAbs.negate
      yAbs.negate
    result.impl = mulmod(xAbs.impl, yAbs.impl, mAbs.impl)

func powmod*(base, exp, m: StInt): StInt {.raises: [ValueError].} =
  ## Modular exponentiation

  if exp.isNegative:
    raise newException(ValueError, "exponent must not be negative")

  var
    bv = base
    switchSign = false
    mAbs = m.abs

  if base.isNegative:
    bv.negate
    switchSign = exp.isOdd

  result.impl = powmod(bv.impl, exp.impl, mAbs.impl)
  if switchSign:
    result.negate

{.pop.}

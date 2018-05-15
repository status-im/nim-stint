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
  ./uint_bitwise_ops, ./uint_mul, ./initialization, ./uint_comparison

func pow*(x: UintImpl, y: Natural): UintImpl =
  ## Compute ``x`` to the power of ``y``,
  ## ``x`` must be non-negative

  # Implementation uses exponentiation by squaring
  # See Nim math module: https://github.com/nim-lang/Nim/blob/4ed24aa3eb78ba4ff55aac3008ec3c2427776e50/lib/pure/math.nim#L429
  # And Eli Bendersky's blog: https://eli.thegreenplace.net/2009/03/21/efficient-integer-exponentiation-algorithms

  var (x, y) = (x, y)
  result = one(type x)

  while true:
    if bool(y and 1): # if y is odd
      result = result * x
    y = y shr 1
    if y == 0:
      break
    x = x * x

func pow*(x: UintImpl, y: UintImpl): UintImpl =
  ## Compute ``x`` to the power of ``y``,
  ## ``x`` must be non-negative

  # Implementation uses exponentiation by squaring
  # See Nim math module: https://github.com/nim-lang/Nim/blob/4ed24aa3eb78ba4ff55aac3008ec3c2427776e50/lib/pure/math.nim#L429
  # And Eli Bendersky's blog: https://eli.thegreenplace.net/2009/03/21/efficient-integer-exponentiation-algorithms

  var (x, y) = (x, y)
  result = one(type x)

  while true:
    if y.isOdd:
      result = result * x
    y = y shr 1
    if y.isZero:
      break
    x = x * x

# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, ./uint_comparison

func isZero*(n: SomeSignedInt): bool {.inline.} =
  n == 0

func isZero*(n: IntImpl): bool {.inline.} =
  n.hi.isZero and n.lo.isZero

func isNegative*(n: SomeSignedInt): bool {.inline.} =
  n < 0

func isNegative*(n: IntImpl): bool {.inline.} =
  ## Returns true if a number is negative:
  n.hi.isNegative

func `<`*(x, y: IntImpl): bool {.inline.}=
  # Lower comparison for multi-precision integers
  x.hi < y.hi or
    (x.hi == y.hi and x.lo < y.lo)

func `==`*(x, y: IntImpl): bool {.inline.}=
  # Equal comparison for multi-precision integers
  x.hi == y.hi and x.lo == y.lo

func `<=`*(x, y: IntImpl): bool {.inline.}=
  # Lower or equal comparison for multi-precision integers
  x.hi < y.hi or
    (x.hi == y.hi and x.lo <= y.lo)

func isOdd*(x: SomeSignedInt): bool {.inline.}=
  bool(x and 1)

func isEven*(x: SomeSignedInt): bool {.inline.}=
  not x.isOdd

func isEven*(x: IntImpl): bool {.inline.}=
  x.lo.isEven

func isOdd*(x: IntImpl): bool {.inline.}=
  not x.isEven

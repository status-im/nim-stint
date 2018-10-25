# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes

func isZero*(n: SomeUnsignedInt): bool {.inline.} =
  n == 0

func isZero*(n: UintImpl): bool {.inline.} =
  n.hi.isZero and n.lo.isZero

func `<`*(x, y: UintImpl): bool {.inline.}=
  # Lower comparison for multi-precision integers
  x.hi < y.hi or
    (x.hi == y.hi and x.lo < y.lo)

func `==`*(x, y: UintImpl): bool {.inline.}=
  # Equal comparison for multi-precision integers
  x.hi == y.hi and x.lo == y.lo

func `<=`*(x, y: UintImpl): bool {.inline.}=
  # Lower or equal comparison for multi-precision integers
  x.hi < y.hi or
    (x.hi == y.hi and x.lo <= y.lo)

func isEven*(x: SomeUnsignedInt): bool {.inline.} =
  (x and 1) == 0

func isEven*(x: UintImpl): bool {.inline.}=
  x.lo.isEven

func isOdd*(x: SomeUnsignedInt): bool {.inline.} =
  not x.isEven

func isOdd*(x: UintImpl): bool {.inline.}=
  not x.isEven

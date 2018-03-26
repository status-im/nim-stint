# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./uint_type

proc `<`*(x, y: MpUintImpl): bool {.noSideEffect, noInit, inline.}=
  (x.hi < y.hi) or ((x.hi == y.hi) and x.lo < y.lo)

proc `<=`*(x, y: MpUintImpl): bool {.noSideEffect, noInit, inline.}=
  # Lower or equal comparison for multi-precision integers
  result = if x == y: true
           else: x < y

proc isZero[T: SomeUnsignedInt](n: T): bool {.noSideEffect,inline.} =
  n == 0.T

proc isZero*(n: MpUintImpl): bool {.noSideEffect,inline.} =
  n.lo.isZero and n.hi.isZero

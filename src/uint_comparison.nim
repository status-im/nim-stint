# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import  ./uint_type

proc `<`*[T: MpUint](x, y: T): bool {.noSideEffect, noInit, inline.}=
  (x.hi < y.hi) or ((x.hi == y.hi) and x.lo < y.lo)

proc `<=`*[T: MpUint](x, y: T): bool {.noSideEffect, noInit, inline.}=
  # Lower or equal comparison for multi-precision integers
  if x == y:
    return true
  x < y

proc isZero[T: SomeUnsignedInt](n: T): bool {.noSideEffect,inline.} =
  n == 0.T

proc isZero*(n: MpUint): bool {.noSideEffect,inline.} =
  n.lo.isZero and n.hi.isZero

# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./uint_type, macros

macro cast_optim(x: typed): untyped =
  let size = getSize(x)

  if size > 64:
    result = quote do:
      cast[array[`size` div 64, uint64]](`x`)
  elif size == 64:
    result = quote do:
      cast[uint64](`x`)
  elif size == 32:
    result = quote do:
      cast[uint32](`x`)
  elif size == 16:
    result = quote do:
      cast[uint16](`x`)
  elif size == 8:
    result = quote do:
      cast[uint8](`x`)
  else:
    error "Unreachable path reached"

proc isZero*(n: SomeUnsignedInt): bool {.noSideEffect,inline.} =
  n == 0

proc isZero*(n: MpUintImpl): bool {.noSideEffect,inline.} =
  n == (type n)()

proc `<`*(x, y: MpUintImpl): bool {.noSideEffect, noInit, inline.}=
  (x.hi < y.hi) or ((x.hi == y.hi) and x.lo < y.lo)

proc `==`*(x, y: MpuintImpl): bool {.noSideEffect, noInit, inline.}=
  # Equal comparison for multi-precision integers

  # We cast to array of uint64 because the default comparison is slow
  result = cast_optim(x) == cast_optim(y)

proc `<=`*(x, y: MpUintImpl): bool {.noSideEffect, noInit, inline.}=
  # Lower or equal comparison for multi-precision integers
  result = if x == y: true
           else: x < y

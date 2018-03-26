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
  # Size of doesn't always work at compile-time, pending PR https://github.com/nim-lang/Nim/pull/5664

  var multiplier = 1
  var node = x.getTypeInst

  while node.kind == nnkBracketExpr:
    assert eqIdent(node[0], "MpuintImpl")
    multiplier *= 2
    node = node[1]

  # node[1] has the type
  # size(node[1]) * multiplier is the size in byte

  # For optimization we cast to the biggest possible uint
  if eqIdent(node, "uint64"):
    multiplier = multiplier div 8
    result = quote do:
      cast[array[multiplier, uint64]](x)
  elif eqIdent(node, "uint32"):
    # Why would someone do a MpuintImpl[MpUintImpl[uint32]]?
    assert multiplier == 1
    result = quote do:
      cast[uint32](x)
  elif eqIdent(node, "uint16"):
    # Why would someone do a MpuintImpl[MpUintImpl[uint16]]?
    assert multiplier == 1
    result = quote do:
      cast[uint16](x)

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

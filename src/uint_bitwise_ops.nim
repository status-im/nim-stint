# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import  uint_type


proc `not`*(x: MpUint): MpUint {.noInit, noSideEffect, inline.}=
  ## Bitwise complement of unsigned integer x
  result.lo = not x.lo
  result.hi = not x.hi

proc `or`*(x, y: MpUint): MpUint {.noInit, noSideEffect, inline.}=
  ## `Bitwise or` of numbers x and y
  result.lo = x.lo or y.lo
  result.hi = x.hi or y.hi

proc `and`*(x, y: MpUint): MpUint {.noInit, noSideEffect, inline.}=
  ## `Bitwise and` of numbers x and y
  result.lo = x.lo and y.lo
  result.hi = x.hi and y.hi

proc `xor`*(x, y: MpUint): MpUint {.noInit, noSideEffect, inline.}=
  ## `Bitwise xor` of numbers x and y
  result.lo = x.lo xor y.lo
  result.hi = x.hi xor y.hi

proc `shr`*[T: MpUint](x: T, y: SomeInteger): T {.noInit, noSideEffect.}
  # Forward declaration

proc `shl`*[T: MpUint](x: T, y: SomeInteger): T {.noInit, noSideEffect.}=
  ## Compute the `shift left` operation of x and y
  # Note: inlining this poses codegen/aliasing issue when doing `x = x shl 1`
  let
    halfSize = T.sizeof * 4

  type SubT = type x.lo

  result.hi = (x.hi shl y) or (x.lo shl (y - halfSize))
  result.lo = if y < halfSize: x.lo shl y
              else: 0.SubT


proc `shr`*[T: MpUint](x: T, y: SomeInteger): T {.noInit, noSideEffect.}=
  ## Compute the `shift right` operation of x and y
  # Note: inlining this poses codegen/aliasing issue when doing `x = x shl 1`
  let
    halfSize = T.sizeof * 4

  type SubT = type x.lo

  result.lo = (x.lo shr y) or (x.hi shl (y - halfSize)) # the shl is not a mistake
  result.hi = if y < halfSize: x.hi shr y
              else: 0.SubT


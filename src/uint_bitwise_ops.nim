# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import  ./private/utils,
        uint_type


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

proc `shl`*[T: MpUint](x: T, y: SomeInteger): T {.noInit, noSideEffect.}
  # Forward declaration

proc `shl`*[T: MpUint](x: T, y: SomeInteger): T {.noInit, noSideEffect.}=
  ## Compute the `shift left` operation of x and y

  if y == 0:
    return x

  let # TODO: should be a const - https://github.com/nim-lang/Nim/pull/5664
    size = (T.sizeof * 8)
    halfSize = size div 2

  type Sub = getSubType T

  if y > halfSize:
    result.hi = x.lo shl (y - halfSize)
    result.lo = 0.Sub
  elif y < halfSize:
    result.hi = (x.hi shl y) or (x.lo shr (halfSize - y))
    result.lo = x.lo shl y
  else:
    result.hi = x.lo
    result.lo = 0.Sub

proc `shr`*[T: MpUint](x: T, y: SomeInteger): T {.noInit, noSideEffect.}=
  ## Compute the `shift right` operation of x and y

  if y == 0:
    return x

  let # TODO: should be a const - https://github.com/nim-lang/Nim/pull/5664
    size = (T.sizeof * 8)
    halfSize = size div 2

  type Sub = getSubType T

  if y > halfSize:
    result.hi = x.hi shr (y - halfSize)
    result.lo = 0.Sub
  elif y < halfSize:
    result.lo = (x.lo shr y) or (x.hi shl (halfSize - y))
    result.hi = x.hi shr y
  else:
    result.lo = x.hi
    result.hi = 0.Sub
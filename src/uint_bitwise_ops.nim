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

  let # cannot be const, compile-time sizeof only works for simple types
    size = (T.sizeof * 8)
    halfSize = size div 2

  type Sub = getSubType T

  if y < halfSize:
    result.hi = (x.hi shl y) or (x.lo shr (halfSize - y))
    result.lo = x.lo shl y
  else:
    result.hi = x.lo shl (y - halfSize)
    result.lo = 0.Sub

proc `shr`*[T: MpUint](x: T, y: SomeInteger): T {.noInit, noSideEffect.}=
  ## Compute the `shift right` operation of x and y

  if y == 0:
    return x

  let # cannot be const, compile-time sizeof only works for simple types
    size = (T.sizeof * 8)
    halfSize = size div 2

  type Sub = getSubType T

  if y < halfSize:
    result.lo = (x.lo shr y) or (x.hi shl (halfSize - y))
    result.hi = x.hi shr y
  else:
    result.hi = x.hi shr (y - halfSize)
    result.lo = 0.Sub



# ########################################################################
# TODO Benchmarks (especially on ARM)
# Alternative shift implementations without branching
#
# Quick testing on MpUint[uint32] on x86_64 with Clang shows that it is somewhat slower
# Fast shifting is key to fast division and modulo operations

# proc `shl`*[T: MpUint](x: T, y: SomeInteger): T {.noInit, noSideEffect.}=
#   ## Compute the `shift left` operation of x and y
#   type Sub = getSubType T
#
#   let # cannot be const, compile-time sizeof only works for simple types
#     size = Sub(T.sizeof * 8)
#     halfSize = size div 2
#
#   var S = y.Sub and (size-1) # y mod size
#
#   let
#     M1 = Sub( ((((S + size-1) or S) and halfSize) div halfSize) - 1)
#     M2 = Sub( (S div halfSize) - 1)
#
#   S = S and (halfSize-1) # y mod halfsize
#
#   result.hi = (x.lo shl S) and not M2
#   result.lo = (x.lo shl S) and M2
#   result.hi = result.hi or ((
#     x.hi shl S or (x.lo shr (size - S) and M1)
#   ) and M2)

# proc `shr`*[T: MpUint](x: T, y: SomeInteger): T {.noInit, noSideEffect.}=
#   ## Compute the `shift right` operation of x and y
#   type Sub = getSubType T
#
#   let # cannot be const, compile-time sizeof only works for simple types
#     size = Sub(T.sizeof * 8)
#     halfSize = size div 2
#
#   var S = y.Sub and (size-1) # y mod size
#
#   let
#     M1 = Sub( ((((S + size-1) or S) and halfSize) div halfSize) - 1)
#     M2 = Sub( (S div halfSize) - 1)
#
#   S = S and (halfSize-1) # y mod halfsize
#
#   result.lo = (x.hi shr S) and not M2
#   result.hi = (x.hi shr S) and M2
#   result.lo = result.lo or ((
#     x.lo shr S or (x.lo shl (size - S) and M1)
#   ) and M2)

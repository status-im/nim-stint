# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./uint_type, ./conversion


func `not`*(x: MpUintImpl): MpUintImpl {.noInit, inline.}=
  ## Bitwise complement of unsigned integer x
  result.lo = not x.lo
  result.hi = not x.hi

func `or`*(x, y: MpUintImpl): MpUintImpl {.noInit, inline.}=
  ## `Bitwise or` of numbers x and y
  result.lo = x.lo or y.lo
  result.hi = x.hi or y.hi

func `and`*(x, y: MpUintImpl): MpUintImpl {.noInit, inline.}=
  ## `Bitwise and` of numbers x and y
  result.lo = x.lo and y.lo
  result.hi = x.hi and y.hi

func `xor`*(x, y: MpUintImpl): MpUintImpl {.noInit, inline.}=
  ## `Bitwise xor` of numbers x and y
  result.lo = x.lo xor y.lo
  result.hi = x.hi xor y.hi

func `shr`*(x: MpUintImpl, y: SomeInteger): MpUintImpl {.inline.}
  # Forward declaration

func `shl`*(x: MpUintImpl, y: SomeInteger): MpUintImpl {.inline.}=
  ## Compute the `shift left` operation of x and y
  # Note: inlining this poses codegen/aliasing issue when doing `x = x shl 1`

  # TODO: would it be better to reimplement this using an array of bytes/uint64
  # That opens up to endianness issues.

  const halfSize = getSize(x) div 2
  let defect = halfSize - int(y)

  if y == 0:
    return x
  elif y == halfSize:
    result.hi = x.lo
  elif y < halfSize:
    result.hi = (x.hi shl y) or (x.lo shr (halfSize - y))
    result.lo = x.lo shl y
  else:
    result.hi = x.lo shl (y - halfSize)

func `shr`*(x: MpUintImpl, y: SomeInteger): MpUintImpl {.inline.}=
  ## Compute the `shift right` operation of x and y
  const halfSize = getSize(x) div 2

  if y == 0:
    return x
  elif y == halfSize:
    result.lo = x.hi
  elif y < halfSize:
    result.lo = (x.lo shr y) or (x.hi shl (halfSize - y))
    result.hi = x.hi shr y
  else:
    result.lo = x.hi shr (y - halfSize)


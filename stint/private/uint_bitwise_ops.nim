# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, ./bitops2_priv

func `not`*(x: UintImpl): UintImpl {.inline.}=
  ## Bitwise complement of unsigned integer x
  applyHiLo(x, `not`)

func `or`*(x, y: UintImpl): UintImpl {.inline.}=
  ## `Bitwise or` of numbers x and y
  applyHiLo(x, y, `or`)

func `and`*(x, y: UintImpl): UintImpl {.inline.}=
  ## `Bitwise and` of numbers x and y
  applyHiLo(x, y, `and`)

func `xor`*(x, y: UintImpl): UintImpl {.inline.}=
  ## `Bitwise xor` of numbers x and y
  applyHiLo(x, y, `xor`)

func `shr`*(x: UintImpl, y: SomeInteger): UintImpl {.inline.}
  # Forward declaration

func `shl`*(x: UintImpl, y: SomeInteger): UintImpl {.inline.}=
  ## Compute the `shift left` operation of x and y
  # Note: inlining this poses codegen/aliasing issue when doing `x = x shl 1`

  # TODO: would it be better to reimplement this with words iteration?
  const halfSize: type(y) = bitsof(x) div 2

  if y == 0:
    return x
  elif y == halfSize:
    result.hi = x.lo
  elif y < halfSize:
    result.hi = (x.hi shl y) or (x.lo shr (halfSize - y))
    result.lo = x.lo shl y
  else:
    result.hi = x.lo shl (y - halfSize)

func `shr`*(x: UintImpl, y: SomeInteger): UintImpl {.inline.}=
  ## Compute the `shift right` operation of x and y
  ## Similar to C standard, result is undefined if y is bigger
  ## than the number of bits in x.
  const halfSize: type(y) = bitsof(x) div 2

  if y == 0:
    return x
  elif y == halfSize:
    result.lo = x.hi
  elif y < halfSize:
    result.lo = (x.lo shr y) or (x.hi shl (halfSize - y))
    result.hi = x.hi shr y
  else:
    result.lo = x.hi shr (y - halfSize)

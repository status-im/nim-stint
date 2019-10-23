# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, ./bitops2_priv, ./uint_bitwise_ops, ./compiletime_cast

func `not`*(x: IntImpl): IntImpl {.inline.}=
  ## Bitwise complement of unsigned integer x
  applyHiLo(x, `not`)

func `or`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise or` of numbers x and y
  applyHiLo(x, y, `or`)

func `and`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise and` of numbers x and y
  applyHiLo(x, y, `and`)

func `xor`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise xor` of numbers x and y
  applyHiLo(x, y, `xor`)

func `shl`*(x: IntImpl, y: SomeInteger): IntImpl {.inline.}=
  ## Compute the `shift left` operation of x and y
  # Note: inlining this poses codegen/aliasing issue when doing `x = x shl 1`

  # TODO: would it be better to reimplement this with words iteration?
  const halfSize: type(y) = bitsof(x) div 2
  type HiType = type(result.hi)

  if y == 0:
    return x
  elif y == halfSize:
    result.hi = convert[HiType](x.lo)
  elif y < halfSize:
    # `shr` in this equation uses uint version
    result.hi = (x.hi shl y) or convert[HiType](x.lo shr (halfSize - y))
    result.lo = x.lo shl y
  else:
    result.hi = convert[HiType](x.lo shl (y - halfSize))

template createShr(name, operator: untyped) =
  template name(x, y: SomeInteger): auto =
    operator(x, y)

  func name*(x: IntImpl, y: SomeInteger): IntImpl {.inline.}=
    ## Compute the `arithmetic shift right` operation of x and y
    ## Similar to C standard, result is undefined if y is bigger
    ## than the number of bits in x.
    const halfSize: type(y) = bitsof(x) div 2
    type LoType = type(result.lo)
    if y == 0:
      return x
    elif y == halfSize:
      result.lo = convert[LoType](x.hi)
      result.hi = name(x.hi, halfSize-1)
    elif y < halfSize:
      result.lo = (x.lo shr y) or convert[LoType](x.hi shl (halfSize - y))
      result.hi = name(x.hi, y)
    else:
      result.lo = convert[LoType](name(x.hi, (y - halfSize)))
      result.hi = name(x.hi, halfSize-1)

when (NimMajor, NimMinor, NimPatch) >= (0, 20, 0):
  createShr(shrOfShr, `shr`)
elif (NimMajor, NimMinor, NimPatch) < (0, 20, 0) and defined(nimAshr):
  createShr(shrOfAshr, ashr)
else:
  {.error: "arithmetic right shift is not defined for this Nim version".}

template `shr`*(a, b: typed): untyped =
  when (NimMajor, NimMinor, NimPatch) >= (0, 20, 0):
    shrOfShr(a, b)
  elif (NimMajor, NimMinor, NimPatch) < (0, 20, 0) and defined(nimAshr):
    shrOfAShr(a, b)

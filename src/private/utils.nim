# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import ../uint_type

proc bit_length*[T: BaseUint](n: T): int {.noSideEffect.}=
  ## Calculates how many bits are necessary to represent the number
  result = 1
  var y: T = n shr 1
  while y > 0.T:
    y = y shr 1
    inc(result)


proc bit_length*[T: Natural](n: T): int {.noSideEffect.}=
  ## Calculates how many bits are necessary to represent the number
  #
  # For some reason using "BaseUint or Natural" directly makes Nim compiler
  # throw a type mismatch
  result = 1
  var y: T = n shr 1
  while y > 0.T:
    y = y shr 1
    inc(result)

proc asUint*[T: MpUInt](n: T): auto {.noSideEffect, inline.}=
  ## Casts a multiprecision integer to an uint of the same size

  when T.sizeof > 8:
    raise newException("Unreachable. You are trying to cast a MpUint with more than 64-bit of precision")
  elif T.sizeof == 8:
    cast[uint64](n)
  elif T.sizeof == 4:
    cast[uint32](n)
  elif T.sizeof == 2:
    cast[uint16](n)
  else:
    raise newException("Unreachable. MpUInt must be 16-bit minimum and a power of 2")

proc asUint*[T: SomeUnsignedInt](n: T): T {.noSideEffect, inline.}=
  ## No-op overload of multi-precision int casting
  n

proc asDoubleUint*[T: BaseUint](n: T): auto {.noSideEffect, inline.} =
  ## Convert an integer or MpUint to an uint with double the size

  type Double = (
    when T.sizeof == 4: uint64
    elif T.sizeof == 2: uint32
    else: uint16
  )

  n.asUint.Double
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
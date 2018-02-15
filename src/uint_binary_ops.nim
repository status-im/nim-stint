# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import uint_type

proc `+=`*[T: MpUint](a: var T, b: T) {.noSideEffect.}=

  type Base = type a.lo
  let tmp = a.lo

  a.lo += b.lo
  a.hi += (a.lo < tmp).Base + b.hi
  # Optimized assembly should contain adc instruction (add with carry)
  # Clang on MacOS does with the -d:release switch.

proc `+`*[T: MpUint](a: T, b: T): T {.noSideEffect, noInit.}=

  result = a
  result += b
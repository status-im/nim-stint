# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import uint_type

proc `+=`*[T: MpUint](a: var T, b: T) {.noSideEffect.}=
  # In-place addition for multi-precision unsigned int
  #
  # Optimized assembly should contain adc instruction (add with carry)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type Base = type a.lo
  let tmp = a.lo

  a.lo += b.lo
  a.hi += (a.lo < tmp).Base + b.hi

proc `+`*[T: MpUint](a, b: T): T {.noSideEffect, noInit, inline.}=
  # Addition for multi-precision unsigned int
  result = a
  result += b

proc `-=`*[T: MpUint](a: var T, b: T) {.noSideEffect.}=
  # In-place substraction for multi-precision unsigned int
  #
  # Optimized assembly should contain sbc instruction (substract with carry)
  # Clang on MacOS does with the -d:release switch and MpUint[uint32] (uint64)
  type Base = type a.lo
  let tmp = a.lo

  a.lo -= b.lo
  a.hi -= (a.lo > tmp).Base + b.hi

proc `-`*[T: MpUint](a, b: T): T {.noSideEffect, noInit, inline.}=
  # Substraction for multi-precision unsigned int
  result = a
  result -= b
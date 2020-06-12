# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Status lib
  stew/bitops2

when sizeof(int) == 8 and not defined(Stint32):
  type Word* = uint64
else:
  type Word* = uint32

const WordBitWidth = sizeof(Word) * 8

func wordsRequired*(bits: int): int {.compileTime.} =
  ## Compute the number of limbs required
  ## from the **announced** bit length
  (bits + WordBitWidth - 1) div WordBitWidth

type
  Limbs*[N: static int] = array[N, Word]

  StUint*[bits: static[int]] = object
    ## Stack-based integer
    ## Unsigned
    limbs*: Limbs[bits.wordsRequired]

  StInt*[bits: static[int]] = object
    ## Stack-based integer
    ## Signed
    limbs*: Limbs[bits.wordsRequired]

  Carry* = uint8  # distinct range[0'u8 .. 1]
  Borrow* = uint8 # distinct range[0'u8 .. 1]

const GCC_Compatible* = defined(gcc) or defined(clang) or defined(llvm_gcc)
const X86* = defined(amd64) or defined(i386)

when sizeof(int) == 8 and GCC_Compatible:
  type
    uint128*{.importc: "unsigned __int128".} = object

template leastSignificantWord*(num: SomeInteger): auto =
  num

func leastSignificantWord*(limbs: Limbs): auto {.inline.} =
  when cpuEndian == littleEndian:
    limbs[0]
  else:
    limbs[^1]

func mostSignificantWord*(limbs: Limbs): auto {.inline.} =
  when cpuEndian == littleEndian:
    limbs[^1]
  else:
    limbs[0]

iterator leastToMostSig*(limbs: Limbs): Word =
  ## Iterate from least to most significant word
  when cpuEndian == littleEndian:
    for i in 0 ..< limbs.len:
      yield limbs[i]
  else:
    for i in countdown(limbs.len-1, 0):
      yield limbs[i]

iterator leastToMostSig*(limbs: var Limbs): var Word =
  ## Iterate from least to most significant word
  when cpuEndian == littleEndian:
    for i in 0 ..< limbs.len:
      yield limbs[i]
  else:
    for i in countdown(limbs.len-1, 0):
      yield limbs[i]

iterator leastToMostSig*(aLimbs, bLimbs: Limbs): (Word, Word) =
  ## Iterate from least to most significant word
  when cpuEndian == littleEndian:
    for i in 0 ..< limbs.len:
      yield (aLimbs[i], bLimbs[i])
  else:
    for i in countdown(limbs.len-1, 0):
      yield (aLimbs[i], bLimbs[i])

iterator leastToMostSig*(aLimbs: var Limbs, bLimbs: Limbs): (var Word, Word) =
  ## Iterate from least to most significant word
  when cpuEndian == littleEndian:
    for i in 0 ..< limbs.len:
      yield (aLimbs[i], bLimbs[i])
  else:
    for i in countdown(limbs.len-1, 0):
      yield (aLimbs[i], bLimbs[i])

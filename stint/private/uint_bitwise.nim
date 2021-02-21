# Stint
# Copyright 2018-Present Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Status lib
  stew/bitops2,
  # Internal
  ./datatypes

# Bitwise operations
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func bitnot*(r: var StUint, a: Stuint) =
  ## Bitwise complement of unsigned integer a
  ## i.e. flips all bits of the input
  for wr, wa in leastToMostSig(r, a):
    wr = not wa
  r.clearExtraBits()

func bitor*(r: var Stuint, a, b: Stuint) =
  ## `Bitwise or` of numbers a and b
  for wr, wa, wb in leastToMostSig(r, a, b):
    wr = wa or wb

func bitand*(r: var Stuint, a, b: Stuint) =
  ## `Bitwise and` of numbers a and b
  for wr, wa, wb in leastToMostSig(r, a, b):
    wr = wa and wb

func bitxor*(r: var Stuint, a, b: Stuint) =
  ## `Bitwise xor` of numbers x and y
  for wr, wa, wb in leastToMostSig(r, a, b):
    wr = wa xor wb
  r.clearExtraBits()

func countOnes*(a: Stuint): int =
  result = 0
  for wa in leastToMostSig(a):
    result += countOnes(wa)

func parity*(a: Stuint): int =
  result = parity(a.limbs[0])
  for i in 1 ..< a.limbs.len:
    result = result xor parity(a.limbs[i])

func leadingZeros*(a: Stuint): int =
  result = 0

  # Adjust when we use only part of the word size
  var extraBits = WordBitWidth * a.limbs.len - a.bits

  for word in mostToLeastSig(a):
    let zeroCount = word.leadingZeros()
    if extraBits > 0:
      result += zeroCount - min(extraBits, WordBitWidth)
      extraBits -= WordBitWidth
    else:
      result += zeroCount
    if zeroCount != WordBitWidth:
      break

func trailingZeros*(a: Stuint): int =
  result = 0
  for word in leastToMostSig(a):
    let zeroCount = word.trailingZeros()
    result += zeroCount
    if zeroCount != WordBitWidth:
      break

  when a.limbs.len * WordBitWidth != a.bits:
    if result > a.bits:
      result = a.bits

func firstOne*(a: Stuint): int =
  result = trailingZeros(a)
  if result == a.limbs.len * WordBitWidth:
    result = 0
  else:
    result += 1

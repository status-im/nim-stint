# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes

{.push raises: [], inline, noInit, gcsafe.}

func `not`*(x: Limbs): Limbs =
  ## Bitwise complement of unsigned integer x
  for wr, wx in leastToMostSig(result, x):
    wr = not wx

func `or`*(x, y: Limbs): Limbs =
  ## `Bitwise or` of numbers x and y
  for wr, wx, wy in leastToMostSig(result, x, y):
    wr = wx or wy

func `and`*(x, y: Limbs): Limbs =
  ## `Bitwise and` of numbers x and y
  for wr, wx, wy in leastToMostSig(result, x, y):
    wr = wx and wy

func `xor`*(x, y: Limbs): Limbs =
  ## `Bitwise xor` of numbers x and y
  for wr, wx, wy in leastToMostSig(result, x, y):
    wr = wx xor wy

func `shr`*(x: Limbs, k: SomeInteger): Limbs =
  ## Shift right by k.
  ##
  ## k MUST be less than the base word size (2^32 or 2^64)
  # Note: for speed, loading a[i] and a[i+1]
  #       instead of a[i-1] and a[i]
  #       is probably easier to parallelize for the compiler
  #       (antidependence WAR vs loop-carried dependence RAW)
  when cpuEndian == littleEndian:
    for i in 0 ..< x.len-1:
      result[i] = (x[i] shr k) or (x[i+1] shl (WordBitWidth - k))
    result[^1] = x[^1] shr k
  else:
    for i in countdown(x.len-1, 1):
      result[i] = (x[i] shr k) or (x[i-1] shl (WordBitWidth - k))
    result[0] = x[0] shr k

func `shl`*(x: Limbs, k: SomeInteger): Limbs =
  ## Compute the `shift left` operation of x and k
  when cpuEndian == littleEndian:
    result[0] = x[0] shl k
    for i in 1 ..< x.len:
      result[i] = (x[i] shl k) or (x[i-1] shr (WordBitWidth - k))
  else:
    result[^1] = x[^1] shl k
    for i in countdown(x.len-2, 0):
      result[i] = (x[i] shl k) or (x[i+1] shr (WordBitWidth - k))

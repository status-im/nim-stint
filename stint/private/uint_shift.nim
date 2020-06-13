# Stint
# Copyright 2018-Present Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ./datatypes

# Shifts
# --------------------------------------------------------
{.push raises: [], gcsafe.}

func shrSmall*(r: var Limbs, a: Limbs, k: SomeInteger) =
  ## Shift right by k.
  ##
  ## k MUST be less than the base word size (2^32 or 2^64)
  # Note: for speed, loading a[i] and a[i+1]
  #       instead of a[i-1] and a[i]
  #       is probably easier to parallelize for the compiler
  #       (antidependence WAR vs loop-carried dependence RAW)
  when cpuEndian == littleEndian:
    for i in 0 ..< a.len-1:
      r[i] = (a[i] shr k) or (a[i+1] shl (WordBitWidth - k))
    r[^1] = a[^1] shr k
  else:
    for i in countdown(a.len-1, 1):
      r[i] = (a[i] shr k) or (a[i-1] shl (WordBitWidth - k))
    r[0] = a[0] shr k

func shrLarge*(r: var Limbs, a: Limbs, w, shift: SomeInteger) =
  ## Shift right by `w` words + `shift` bits
  ## Assumes `r` is 0 initialized
  if w > Limbs.len:
    return

  when cpuEndian == littleEndian:
    for i in w ..< a.len-1:
      r[i-w] = (a[i] shr shift) or (a[i+1] shl (WordBitWidth - shift))
    r[^(1+w)] = a[^1] shr shift
  else:
    for i in countdown(a.len-1, 1+w):
      r[i-w] = (a[i] shr shift) or (a[i-1] shl (WordBitWidth - k))
    r[0] = a[w] shr shift

func shrWords*(r: var Limbs, a: Limbs, w: SomeInteger) =
  ## Shift right by w word
  when cpuEndian == littleEndian:
    for i in 0 ..< Limbs.len-w:
      r[i] = a[i+w]
  else:
    for i in countdown(Limbs.len-w, 0):
      r[i] = a[i+w]

func shlSmall*(r: var Limbs, a: Limbs, k: SomeInteger) =
  ## Compute the `shift left` operation of x and k
  ##
  ## k MUST be less than the base word size (2^32 or 2^64)
  when cpuEndian == littleEndian:
    r[0] = a[0] shl k
    for i in 1 ..< a.len:
      r[i] = (a[i] shl k) or (a[i-1] shr (WordBitWidth - k))
  else:
    r[^1] = a[^1] shl k
    for i in countdown(a.len-2, 0):
      r[i] = (a[i] shl k) or (a[i+1] shr (WordBitWidth - k))

func shlLarge*(r: var Limbs, a: Limbs, w, shift: SomeInteger) =
  ## Shift left by `w` words + `shift` bits
  ## Assumes `r` is 0 initialized
  if w > Limbs.len:
    return

  when cpuEndian == littleEndian:
    r[w] = a[0] shl shift
    for i in 1+w ..< r.len:
      r[i] = (a[i-w] shl shift) or (a[i-w-1] shr (WordBitWidth - shift))
  else:
    r[^1] = a[^w] shl shift
    for i in countdown(a.len-2-w, 0):
      r[i+w] = (a[i] shl shift) or (a[i+1] shr (WordBitWidth - shift))

func shlWords*(r: var Limbs, a: Limbs, w: SomeInteger) =
  ## Shift left by w word
  when cpuEndian == littleEndian:
    for i in 0 ..< Limbs.len-w:
      r[i+w] = a[i]
  else:
    for i in countdown(Limbs.len-1, 0):
      r[i] = a[i-w]

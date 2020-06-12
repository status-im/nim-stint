# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ./datatypes,
  ./primitives/extended_precision

# ################### Multiplication ################### #
{.push raises: [], gcsafe.}

func prod*[rLen, aLen, bLen](r: var Limbs[rLen], a: Limbs[aLen], b: Limbs[bLen]) =
  ## Multi-precision multiplication
  ## r <- a*b
  ##
  ## `a`, `b`, `r` can have a different number of limbs
  ## if `r`.limbs.len < a.limbs.len + b.limbs.len
  ## The result will be truncated, i.e. it will be
  ## a * b (mod (2^WordBitwidth)^r.limbs.len)

  # We use Product Scanning / Comba multiplication
  var t, u, v = Word(0)
  var z: Limbs[rLen] # zero-init, ensure on stack and removes in-place problems

  staticFor i, 0, min(a.len+b.len, r.len):
    const ib = min(b.len-1, i)
    const ia = i - ib
    staticFor j, 0, min(a.len - ia, ib+1):
      mulAcc(t, u, v, a[ia+j], b[ib-j])

    z[i] = v
    v = u
    u = t
    t = Word(0)

  r = z

func prod_high_words*[rLen, aLen, bLen](
       r: var Limbs[rLen],
       a: Limbs[aLen], b: Limbs[bLen],
       lowestWordIndex: static int) =
  ## Multi-precision multiplication keeping only high words
  ## r <- a*b >> (2^WordBitWidth)^lowestWordIndex
  ##
  ## `a`, `b`, `r` can have a different number of limbs
  ## if `r`.limbs.len < a.limbs.len + b.limbs.len - lowestWordIndex
  ## The result will be truncated, i.e. it will be
  ## a * b >> (2^WordBitWidth)^lowestWordIndex (mod (2^WordBitwidth)^r.limbs.len)
  #
  # This is useful for
  # - Barret reduction
  # - Approximating multiplication by a fractional constant in the form f(a) = K/C * a
  #   with K and C known at compile-time.
  #   We can instead find a well chosen M = (2^WordBitWidth)^w, with M > C (i.e. M is a power of 2 bigger than C)
  #   Precompute P = K*M/C at compile-time
  #   and at runtime do P*a/M <=> P*a >> (WordBitWidth*w)
  #   i.e. prod_high_words(result, P, a, w)

  # We use Product Scanning / Comba multiplication
  var t, u, v = Word(0) # Will raise warning on empty iterations
  var z: Limbs[rLen] # zero-init, ensure on stack and removes in-place problems

  # The previous 2 columns can affect the lowest word due to carries
  # but not the ones before (we accumulate in 3 words (t, u, v))
  const w = lowestWordIndex - 2

  staticFor i, max(0, w), min(a.len+b.len, r.len+lowestWordIndex):
    const ib = min(b.len-1, i)
    const ia = i - ib
    staticFor j, 0, min(a.len - ia, ib+1):
      mulAcc(t, u, v, a[ia+j], b[ib-j])

    when i >= lowestWordIndex:
      z[i-lowestWordIndex] = v
    v = u
    u = t
    t = Word(0)

  r = z

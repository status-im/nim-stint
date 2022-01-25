# Stint
# Copyright 2022 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Standard library
  std/[unittest, times],
  # Internal
  ../stint,
  # Test utilities
  ../helpers/prng_unsafe

const Iters = 50000

var rng: RngState
let seed = uint32(getTime().toUnix() and (1'i64 shl 32 - 1)) # unixTime mod 2^32
rng.seed(seed)
echo "\n------------------------------------------------------\n"
echo "t_randomized_divmod xoshiro512** seed: ", seed

proc test_divmod(bits: static int, iters: int, gen: RandomGen) =
  for _ in 0 ..< iters:
    let a = rng.random_elem(Stuint[bits], gen)
    let b = rng.random_elem(Stuint[bits], gen)

    try:
      let (q, r) = divmod(a, b)
      doAssert a == q*b + r
    except DivByZeroDefect:
      doAssert b.isZero()
    
template test(bits: static int) =
  test "(q, r) = divmod(a, b) <=> a = q*b + r (" & $bits & " bits)":
    test_divmod(bits, Iters, Uniform)
    test_divmod(bits, Iters, HighHammingWeight)
    test_divmod(bits, Iters, Long01Sequence)

suite "Randomized division and modulo checks":
  test(128)
  test(256)
  test(512)
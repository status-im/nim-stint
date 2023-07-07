# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  std/[times, random],
  unittest,
  ./intx/intx_compat,
  ../stint,
  ../helpers/prng_unsafe

const
  itercount = 10_000

let seed = uint32(getTime().toUnix() and (1'i64 shl 32 - 1)) # unixTime mod 2^32
var rng: RngState
rng.seed(seed)

template testLoopImpl(bits: static int, name: string, gen: RandomGen, body: untyped) =
  test name & " " & $gen & " " & $bits & " bits":
    for _ in 0 ..< itercount:
      let
        mp_x {.inject.} = rng.random_elem(StUint[bits], gen)
        mp_y {.inject.} = rng.random_elem(StUint[bits], gen)
        ttm_x {.inject.} = asTT(mp_x)
        ttm_y {.inject.} = asTT(mp_y)

      body

template testLoop(bits: static int, name: string, body: untyped) =
  testLoopImpl(bits, name, Long01Sequence, body)
  testLoopImpl(bits, name, HighHammingWeight, body)
  testLoopImpl(bits, name, Uniform, body)

template testYImpl(bits: static int, name: string, gen: RandomGen, maxY: uint64, body: untyped) =
  test name & " " & $gen & " " & $bits & " bits":
    var xrng = initRand()
    for _ in 0 ..< itercount:
      let
        mp_x {.inject.}  = rng.random_elem(StUint[bits], gen)
        ttm_x {.inject.} = asTT(mp_x)
        y {.inject.}     = xrng.rand(maxY)

      body

template testY(bits: static int, name: string, maxY: uint64, body: untyped) =
  testYImpl(bits, name, Long01Sequence, maxY, body)
  testYImpl(bits, name, HighHammingWeight, maxY, body)
  testYImpl(bits, name, Uniform, maxY, body)

suite "Property-based testing (testing with random inputs) of UInt":

  when defined(release):
    echo "Testing in release mode with " & $itercount & " random tests for each proc."
  else:
    echo "Testing in debug mode " & $itercount & " random tests for each proc. (StUint[64] = 2x uint32)"

  testLoop(256, "`or`"):
    let
      ttm_z = ttm_x or ttm_y
      mp_z  = mp_x  or mp_y

    check ttm_z.asSt == mp_z

  testLoop(256, "`and`"):
    let
      ttm_z = ttm_x and ttm_y
      mp_z  = mp_x  and mp_y

    check ttm_z.asSt == mp_z

  testLoop(256, "`xor`"):
    let
      ttm_z = ttm_x xor ttm_y
      mp_z  = mp_x  xor mp_y

    check ttm_z.asSt == mp_z

  testLoop(256, "`<`"):
    let
      ttm_z = ttm_x < ttm_y
      mp_z  = mp_x  < mp_y

    check(ttm_z == mp_z)

  testLoop(256, "`<=`"):
    let
      ttm_z = ttm_x <= ttm_y
      mp_z  = mp_x  <= mp_y

    check(ttm_z == mp_z)

  testLoop(256, "`+`"):
    let
      ttm_z = ttm_x + ttm_y
      mp_z  = mp_x  + mp_y

    check ttm_z.asSt == mp_z

  testLoop(256, "`-`"):
    let
      ttm_z = ttm_x - ttm_y
      mp_z  = mp_x  - mp_y

    check ttm_z.asSt == mp_z

  testLoop(256, "`*`"):
    let
      ttm_z = ttm_x * ttm_y
      mp_z  = mp_x  * mp_y

    check ttm_z.asSt == mp_z

  testLoop(256, "`div`"):
    if not mp_y.isZero:
      let
        ttm_z = ttm_x div ttm_y
        mp_z  = mp_x  div mp_y

      check ttm_z.asSt == mp_z

  testLoop(256, "`mod`"):
    if not mp_y.isZero:
      let
        ttm_z = ttm_x mod ttm_y
        mp_z  = mp_x  mod mp_y

      check ttm_z.asSt == mp_z

  testY(256, "`pow`", high(int).uint64):
    let
      ttm_z = ttm_x.pow y.uint64
      mp_z  = mp_x.pow y

    check ttm_z.asSt == mp_z

  testY(256, "`shl`", 255'u64):
    let
      ttm_z = ttm_x shl y.uint
      mp_z  = mp_x  shl y

    check ttm_z.asSt == mp_z

  testY(256, "`shr`", 255'u64):

    let
      ttm_z = ttm_x shr y.uint
      mp_z  = mp_x  shr y

    check ttm_z.asSt == mp_z

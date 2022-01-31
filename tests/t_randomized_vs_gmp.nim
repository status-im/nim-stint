# Stint
# Copyright (c) 2018-2022    Status Research & Development GmbH
# 
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Standard library
  std/[unittest, times, strutils],
  # Third-party
  gmp, stew/byteutils,
  # Internal
  ../stint,
  # Test utilities
  ../helpers/[prng_unsafe, staticfor]

const
  Iters = 1000
  Bitwidths = [128, 256, 512, 1024, 2048]

const # https://gmplib.org/manual/Integer-Import-and-Export.html
  GMP_WordLittleEndian {.used.} = -1'i32
  GMP_WordNativeEndian {.used.} = 0'i32
  GMP_WordBigEndian {.used.} = 1'i32

  GMP_MostSignificantWordFirst = 1'i32
  GMP_LeastSignificantWordFirst {.used.} = -1'i32

var rng: RngState
let seed = uint32(getTime().toUnix() and (1'i64 shl 32 - 1)) # unixTime mod 2^32
rng.seed(seed)
echo "\n------------------------------------------------------\n"
echo "t_randomized_vs_gmp xoshiro512** seed: ", seed

proc rawUint(dst: var openArray[byte], src: mpz_t): csize =
  ## Converts a GMP bigint to a canonical integer as a BigEndian array of byte
  ## Returns the number of words actually written
  discard mpz_export(dst[0].addr, result.addr, GMP_MostSignificantWordFirst, 1, GMP_WordNativeEndian, 0, src)

proc fromStuint[bits: static int](dst: var mpz_t, src: Stuint[bits]) =
  let t = src.toBytes()
  mpz_import(dst, t.len, GMP_MostSignificantWordFirst, 1, GMP_WordNativeEndian, 0, t[0].addr)

  # Sanity check
  var t2: typeof(t)
  let wordsWritten = t2.rawUint(dst)
  # Note: in bigEndian, GMP aligns left while Stint aligns right
  doAssert t2.toOpenArray(0, wordsWritten-1) == t.toOpenArray(t.len-wordsWritten, t.len-1)

proc test_add(bits: static int, iters: int, gen: RandomGen) =
  
  const N = (bits + 7) div 8

  var x, y, z, m: mpz_t
  mpz_init(x)
  mpz_init(y)
  mpz_init(z)
  mpz_init(m)
  mpz_ui_pow_ui(m, 2, bits) # 2^bits
  
  for _ in 0 ..< iters:
    let a = rng.random_elem(Stuint[bits], gen)
    let b = rng.random_elem(Stuint[bits], gen)

    x.fromStuint(a)
    y.fromStuint(b)

    let c = a + b
    mpz_add(z, x, y)
    mpz_mod(z, z, m)

    let cBytes = c.toBytes()

    var zBytes: array[N, byte]
    let wordsWritten = zBytes.rawUint(z)

    # Note: in bigEndian, GMP aligns left while Stint aligns right
    doAssert zBytes.toOpenArray(0, wordsWritten-1) == cBytes.toOpenArray(N-wordsWritten, N-1), block:
      # Reexport as bigEndian for debugging
      var xBuf, yBuf: array[N, byte]
      discard xBuf.rawUint(x)
      discard yBuf.rawUint(y)
      "\nAddition with operands\n" &
      "  x (" & align($bits, 4) & "-bit):   0x" & xBuf.toHex & "\n" &
      "  y (" & align($bits, 4) & "-bit):   0x" & yBuf.toHex & "\n" &
      "failed:" & "\n" &
      "  GMP:            0x" & zBytes.toHex() & "\n" &
      "  Stint:          0x" & cBytes.toHex() & "\n" &
      "(Note that GMP aligns bytes left while Stint aligns bytes right)"

template testAddition(bits: static int) =
  test "Addition vs GMP (" & $bits & " bits)":
    test_add(bits, Iters, Uniform)
    test_add(bits, Iters, HighHammingWeight)
    test_add(bits, Iters, Long01Sequence)

proc test_sub(bits: static int, iters: int, gen: RandomGen) =
  
  const N = (bits + 7) div 8

  var x, y, z, m: mpz_t
  mpz_init(x)
  mpz_init(y)
  mpz_init(z)
  mpz_init(m)
  mpz_ui_pow_ui(m, 2, bits) # 2^bits
  
  for _ in 0 ..< iters:
    let a = rng.random_elem(Stuint[bits], gen)
    let b = rng.random_elem(Stuint[bits], gen)

    x.fromStuint(a)
    y.fromStuint(b)

    let c = a - b
    mpz_sub(z, x, y)
    mpz_mod(z, z, m)

    let cBytes = c.toBytes()

    var zBytes: array[N, byte]
    let wordsWritten = zBytes.rawUint(z)

    # Note: in bigEndian, GMP aligns left while Stint aligns right
    doAssert zBytes.toOpenArray(0, wordsWritten-1) == cBytes.toOpenArray(N-wordsWritten, N-1), block:
      # Reexport as bigEndian for debugging
      var xBuf, yBuf: array[N, byte]
      discard xBuf.rawUint(x)
      discard yBuf.rawUint(y)
      "\nSubstraction with operands\n" &
      "  x (" & align($bits, 4) & "-bit):   0x" & xBuf.toHex & "\n" &
      "  y (" & align($bits, 4) & "-bit):   0x" & yBuf.toHex & "\n" &
      "failed:" & "\n" &
      "  GMP:            0x" & zBytes.toHex() & "\n" &
      "  Stint:          0x" & cBytes.toHex() & "\n" &
      "(Note that GMP aligns bytes left while Stint aligns bytes right)"

template testSubstraction(bits: static int) =
  test "Substaction vs GMP (" & $bits & " bits)":
    test_sub(bits, Iters, Uniform)
    test_sub(bits, Iters, HighHammingWeight)
    test_sub(bits, Iters, Long01Sequence)

proc test_mul(bits: static int, iters: int, gen: RandomGen) =
  
  const N = (bits + 7) div 8

  var x, y, z, m: mpz_t
  mpz_init(x)
  mpz_init(y)
  mpz_init(z)
  mpz_init(m)
  mpz_ui_pow_ui(m, 2, bits) # 2^bits
  
  for _ in 0 ..< iters:
    let a = rng.random_elem(Stuint[bits], gen)
    let b = rng.random_elem(Stuint[bits], gen)

    x.fromStuint(a)
    y.fromStuint(b)

    let c = a * b
    mpz_mul(z, x, y)
    mpz_mod(z, z, m)

    let cBytes = c.toBytes()

    var zBytes: array[N, byte]
    let wordsWritten = zBytes.rawUint(z)

    # Note: in bigEndian, GMP aligns left while Stint aligns right
    doAssert zBytes.toOpenArray(0, wordsWritten-1) == cBytes.toOpenArray(N-wordsWritten, N-1), block:
      # Reexport as bigEndian for debugging
      var xBuf, yBuf: array[N, byte]
      discard xBuf.rawUint(x)
      discard yBuf.rawUint(y)
      "\nMultiplication with operands\n" &
      "  x (" & align($bits, 4) & "-bit):   0x" & xBuf.toHex & "\n" &
      "  y (" & align($bits, 4) & "-bit):   0x" & yBuf.toHex & "\n" &
      "failed:" & "\n" &
      "  GMP:            0x" & zBytes.toHex() & "\n" &
      "  Stint:          0x" & cBytes.toHex() & "\n" &
      "(Note that GMP aligns bytes left while Stint aligns bytes right)"

template testMultiplication(bits: static int) =
  test "Multiplication vs GMP (" & $bits & " bits)":
    test_mul(bits, Iters, Uniform)
    test_mul(bits, Iters, HighHammingWeight)
    test_mul(bits, Iters, Long01Sequence)

suite "Randomized arithmetic tests vs GMP":
  staticFor i, 0, Bitwidths.len:
    testAddition(Bitwidths[i])
    testSubstraction(Bitwidths[i])
    testMultiplication(Bitwidths[i])
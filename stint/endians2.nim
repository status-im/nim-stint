# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import stew/[endians2, staticfor], private/datatypes

{.push raises: [], noinit, gcsafe, inline.}

# Serialization
# ------------------------------------------------------------------------------------------

template copyBytes(tgt, src, tstart, sstart, n: untyped) =
  when nimvm:
    for i in 0..<n:
      tgt[tstart + i] = src[sstart + i]
  else:
    moveMem(addr tgt[tstart], unsafeAddr src[sstart], n)

template toBytesCopy(src: StUint) =
  # Copy src to result maintaining native byte order
  const words = result.len div sizeof(Word)
  staticFor i, 0 ..< words:
    let limb = src.limbs[i].toBytes()
    const pos = i * sizeof(Word)
    copyBytes(result, limb, pos, 0, sizeof(Word))

  const leftover = result.len - (words * sizeof(Word))
  when leftover > 0:
    # Handle partial limb when bits don't line up with word size
    let limb = src.limbs[^1].toBytes()
    copyBytes(result, limb, result.len - leftover, 0, leftover)

template toBytesSwap(src: StUint) =
  # Copy src to result swapping both limb and byte order
  const words = result.len div sizeof(Word)
  staticFor i, 0 ..< words:
    let limb = swapBytes(src.limbs[i]).toBytes()
    const pos = result.len - (i + 1) * sizeof(Word)
    copyBytes(result, limb, pos, 0, sizeof(Word))

  const leftover = result.len - (words * sizeof(Word))
  when leftover > 0:
    let limb = swapBytes(src.limbs[^1]).toBytes()
    copyBytes(result, limb, 0, limb.len - leftover, leftover)

func toBytesLE*[bits: static int](src: StUint[bits]): array[bits div 8, byte] =
  ## Encode `src` to a byte array using little-endian byte order
  when cpuEndian == littleEndian:
    toBytesCopy(src)
  else:
    toBytesSwap(src)

func toBytesBE*[bits: static int](src: StUint[bits]): array[bits div 8, byte] =
  ## Encode `src` to a byte array using big-endian byte order
  when cpuEndian == littleEndian:
    toBytesSwap(src)
  else:
    toBytesCopy(src)

func toBytes*[bits: static int](
    x: StUint[bits], endian: Endianness
): array[bits div 8, byte] =
  ## Encode `src` to a byte array using the given byte order
  ## TODO Unlike the corresponding function in stew/endians that defaults to
  ##      native endian, this function used to default to big endian - the
  ##      default has been removed to avoid confusion and runtime surprises
  if endian == littleEndian:
    x.toBytesLE()
  else:
    x.toBytesBE()

# Deserialization
# ------------------------------------------------------------------------------------------

when sizeof(Word) == 8:
  const
    wordMask = 0b111
    wordShift = 3
elif sizeof(Word) == 4:
  const
    wordMask = 0b11
    wordShift = 2
else:
  static:
    raiseAssert "unsupported"

template fromBytesSwapUnrolled(src: openArray[byte]) =
  # Copy src to result swapping limb and byte order - unrolled version for when
  # src doers not need padding
  const
    bytes = result.bits div 8
    words = bytes shr wordShift

  staticFor i, 0 ..< words:
    const pos = bytes - (i + 1) * sizeof(Word)
    let limb = Word.fromBytes(src.toOpenArray(pos, pos + sizeof(Word) - 1))
    result.limbs[i] = swapBytes(limb)

  # Handle partial limb in case the bit length doesn't line up with word size
  const leftover = bytes mod sizeof(Word)
  when leftover > 0:
    var limb: Word
    staticFor i, 0 ..< leftover:
      limb = limb or (Word(src[i]) shl ((leftover - i - 1) shl 3))

    result.limbs[words] = limb

template fromBytesSwap(src: openArray[byte]) =
  # Copy src to result swapping limb and byte order
  if src.len >= result.bits div 8:
    # Fast path - there's enough bytes for the full stint meaning we don't have
    # to worry about out-of-bounds src access
    fromBytesSwapUnrolled(src)
  else:
    # Slow path - src is shorter than the integer so we must zero-pad
    let
      bytes = src.len
      words = bytes shr wordShift

    block bulk: # Unroll this part to reduce in-loop arithmetic
      staticFor i, 0 ..< result.limbs.len:
        if i >= words:
          break bulk
        const reversePos = (i + 1) * sizeof(Word)
        let
          pos = bytes - reversePos
          limb = Word.fromBytes(src.toOpenArray(pos, pos + sizeof(Word) - 1))
        result.limbs[i] = swapBytes(limb)

    # Handle partial limb in case the bit length doesn't line up with word size
    let leftover = bytes and wordMask
    var limb: Word
    for i in 0 ..< leftover:
      limb = limb or (Word(src[i]) shl ((leftover - i - 1) shl 3))

    result.limbs[words] = limb

    # noinit means we have to manually zero the limbs missing from src
    for i in words + 1 ..< result.limbs.len:
      result.limbs[i] = 0

template fromBytesCopyUnrolled(src: openArray[byte]) =
  # Copy src to result maintaining limb and byte order - unrolled version for when
  # src doers not need padding
  const
    bytes = result.bits div 8
    words = bytes shr wordShift

  staticFor i, 0 ..< words:
    const pos = i * sizeof(Word)
    let limb = Word.fromBytes(src.toOpenArray(pos, pos + sizeof(Word) - 1))
    result.limbs[i] = limb

  const leftover = bytes and wordMask
  when leftover > 0:
    var limb: Word
    staticFor i, 0 .. leftover - 1:
      limb = limb or (Word(src[bytes - i - 1]) shl ((leftover - i - 1) shl 3))

    result.limbs[words] = limb

template fromBytesCopy(src: openArray[byte]) =
  if src.len >= result.bits div 8:
    fromBytesCopyUnrolled(src)
  else:
    let
      bytes = src.len
      words = bytes shr wordShift

    block bulk: # Unroll this part to reduce in-loop arithmetic
      staticFor i, 0 ..< result.limbs.len:
        if i >= words:
          break bulk

        const pos = i * sizeof(Word)
        let
          limb = Word.fromBytes(src.toOpenArray(pos, pos + sizeof(Word) - 1))
        result.limbs[i] = limb

    let leftover = bytes and wordMask
    var limb: Word
    for i in 0 ..< leftover:
      limb = limb or (Word(src[bytes - i - 1]) shl ((leftover - i - 1) shl 3))

    # No overflow because src.len < result.bits div 8
    result.limbs[words] = limb

    for i in words + 1 ..< result.limbs.len:
      result.limbs[i] = 0

func fromBytesBE*[bits: static int](
    T: typedesc[StUint[bits]], src: openArray[byte]
): T =
  ## Read big endian bytes and convert to an integer. At runtime, src must contain
  ## at least sizeof(T) bytes.
  ## TODO Contrary to docs and the corresponding stew/endians2 function, src is
  ##      actually padded when short - this may change in the future to match
  ##      stew where it panics instead
  when cpuEndian == littleEndian:
    fromBytesSwap(src)
  else:
    fromBytesCopy(src)

func fromBytesBE*[bits: static int](
    T: typedesc[StUint[bits]], src: array[bits div 8, byte]
): T =
  ## Read big endian bytes and convert to an integer. At runtime, src must contain
  ## at least sizeof(T) bytes.
  ## TODO Contrary to docs and the corresponding stew/endians2 function, src is
  ##      actually padded when short - this may change in the future to match
  ##      stew where it panics instead
  when cpuEndian == littleEndian:
    fromBytesSwapUnrolled(src)
  else:
    fromBytesCopyUnrolled(src)

func fromBytesLE*[bits: static int](
    T: typedesc[StUint[bits]], src: openArray[byte]
): T =
  ## Read little endian bytes and convert to an integer. At runtime, src must
  ## contain at least sizeof(T) bytes.
  ## TODO Contrary to docs and the corresponding stew/endians2 function, src is
  ##      actually padded when short - this may change in the future to match
  ##      stew where it panics instead

  when cpuEndian == littleEndian:
    fromBytesCopy(src)
  else:
    fromBytesSwap(src)

func fromBytesLE*[bits: static int](
    T: typedesc[StUint[bits]], src: array[bits div 8, byte]
): T =
  when cpuEndian == littleEndian:
    fromBytesCopyUnrolled(src)
  else:
    fromBytesSwapUnrolled(src)

func fromBytes*[bits: static int](
    T: typedesc[StUint[bits]], src: openArray[byte], srcEndian: Endianness
): T =
  ## Read an source bytearray with the specified endianness and
  ## convert it to an integer
  ## TODO Unlike the corresponding function in stew/endians that defaults to
  ##      native endian, this function used to default to big endian - the
  ##      default has been removed to avoid confusion and runtime surprises
  if srcEndian == littleEndian:
    fromBytesLE(T, src)
  else:
    fromBytesBE(T, src)

func fromBytes*[bits: static int](
    T: typedesc[StUint[bits]], src: array[bits div 8, byte], srcEndian: Endianness
): T =
  ## Read an source bytearray with the specified endianness and
  ## convert it to an integer
  ## TODO Unlike the corresponding function in stew/endians that defaults to
  ##      native endian, this function used to default to big endian - the
  ##      default has been removed to avoid confusion and runtime surprises
  if srcEndian == littleEndian:
    fromBytesLE(T, src)
  else:
    fromBytesBE(T, src)

# Signed integer version of above funcs
# TODO these are not in stew/endians2 :/
# ------------------------------------------------------------------------------------------

func toBytesLE*[bits: static int](src: StInt[bits]): array[bits div 8, byte] =
  toBytesLE(src.impl)

func toBytesBE*[bits: static int](src: StInt[bits]): array[bits div 8, byte] =
  toBytesBE(src.impl)

func toBytes*[bits: static int](
    x: StInt[bits], endian: Endianness
): array[bits div 8, byte] =
  ## TODO Unlike the corresponding function in stew/endians that defaults to
  ##      native endian, this function used to default to big endian - the
  ##      default has been removed to avoid confusion and runtime surprises
  toBytes(x.impl, endian)

func fromBytesBE*[bits: static int](
    T: typedesc[StInt[bits]], x: openArray[byte]
): T {.raises: [], noinit, gcsafe, inline.} =
  fromBytesBE(type result.impl, x)

func fromBytesLE*[bits: static int](T: typedesc[StInt[bits]], x: openArray[byte]): T =
  fromBytesLE(type result.impl, x)

func fromBytes*[bits: static int](
    T: typedesc[StInt[bits]], x: openArray[byte], srcEndian: Endianness
): T =
  ## TODO Unlike the corresponding function in stew/endians that defaults to
  ##      native endian, this function used to default to big endian - the
  ##      default has been removed to avoid confusion and runtime surprises
  fromBytes(type result.impl, x, srcEndian)

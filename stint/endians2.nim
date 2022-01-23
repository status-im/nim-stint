# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import private/datatypes

{.push raises: [IndexError], noInit, gcsafe.}

# Serialization
# ------------------------------------------------------------------------------------------

template toByte(x: SomeUnsignedInt): byte =
  ## At compile-time, conversion to bytes checks the range
  ## we want to ensure this is done at the register level
  ## at runtime in a single "mov byte" instruction
  when nimvm:
    byte(x and 0xFF)
  else:
    byte(x)

template blobFrom(dst: var openArray[byte], src: SomeUnsignedInt, startIdx: int, endian: static Endianness) =
  ## Write an integer into a raw binary blob
  ## Swapping endianness if needed
  when endian == cpuEndian:
    for i in 0 ..< sizeof(src):
      dst[startIdx+i] = toByte((src shr (i * 8)))
  else:
    for i in 0 ..< sizeof(src):
      dst[startIdx+sizeof(src)-1-i] = toByte((src shr (i * 8)))

func toBytesLE*[bits: static int](src: StUint[bits]): array[bits div 8, byte] =
  var
    src_idx, dst_idx = 0
    acc: Word = 0
    acc_len = 0

  when cpuEndian == bigEndian:
    srcIdx = src.limbs.len - 1

  var tail = result.len
  while tail > 0:
    when cpuEndian == littleEndian:
      let w = if src_idx < src.limbs.len: src.limbs[src_idx]
              else: 0
      inc src_idx
    else:
      let w = if src_idx >= 0: src.limbs[src_idx]
              else: 0
      dec src_idx

    if acc_len == 0:
      # We need to refill the buffer to output 64-bit
      acc = w
      acc_len = WordBitWidth
    else:
      let lo = acc
      acc = w

      if tail >= sizeof(Word):
        # Unrolled copy
        result.blobFrom(src = lo, dst_idx, littleEndian)
        dst_idx += sizeof(Word)
        tail -= sizeof(Word)
      else:
        # Process the tail and exit
        when cpuEndian == littleEndian:
          # When requesting little-endian on little-endian platform
          # we can just copy each byte
          # tail is inclusive
          for i in 0 ..< tail:
            result[dst_idx+i] = toByte(lo shr (i*8))
        else: # TODO check this
          # We need to copy from the end
          for i in 0 ..< tail:
            result[dst_idx+i] = toByte(lo shr ((tail-i)*8))
        return

func toBytesBE*[bits: static int](src: StUint[bits]): array[bits div 8, byte] {.inline.} =
  var
    src_idx = 0
    acc: Word = 0
    acc_len = 0

  when cpuEndian == bigEndian:
    srcIdx = src.limbs.len - 1

  var tail = result.len
  while tail > 0:
    when cpuEndian == littleEndian:
      let w = if src_idx < src.limbs.len: src.limbs[src_idx]
              else: 0
      inc src_idx
    else:
      let w = if src_idx >= 0: src.limbs[src_idx]
              else: 0
      dec src_idx

    if acc_len == 0:
      # We need to refill the buffer to output 64-bit
      acc = w
      acc_len = WordBitWidth
    else:
      let lo = acc
      acc = w

      if tail >= sizeof(Word):
        # Unrolled copy
        tail -= sizeof(Word)
        result.blobFrom(src = lo, tail, bigEndian)
      else:
        # Process the tail and exit
        when cpuEndian == littleEndian:
          # When requesting little-endian on little-endian platform
          # we can just copy each byte
          # tail is inclusive
          for i in 0 ..< tail:
            result[tail-1-i] = toByte(lo shr (i*8))
        else:
          # We need to copy from the end
          for i in 0 ..< tail:
            result[tail-1-i] = toByte(lo shr ((tail-i)*8))
        return

func toBytes*[bits: static int](x: StUint[bits], endian: Endianness = system.cpuEndian): array[bits div 8, byte] {.inline.} =
  if endian == littleEndian:
    result = x.toBytesLE()
  else:
    result = x.toBytesBE()

# Deserialization
# ------------------------------------------------------------------------------------------

func fromBytesBE*[bits: static int](
    T: typedesc[StUint[bits]],
    x: openArray[byte]): T =
  ## Read big endian bytes and convert to an integer. At runtime, v must contain
  ## at least sizeof(T) bytes. Native endianess is used which is not
  ## portable! (i.e. use fixed-endian byte array or hex for serialization)

  var accum: Word
  var accumBits: int
  var dstIdx: int

  when cpuEndian == littleEndian: # src is bigEndian, CPU is little-endian
    dstIdx = 0

    for srcIdx in countdown(x.len-1, 0):
      let srcByte = x[srcIdx]

      accum = accum or (srcByte shl accumBits)
      accumBits += 8

      if accumBits >= WordBitWidth:
        result.limbs[dstIdx] = accum
        inc dstIdx
        accumBits -= WordBitWidth
        accum = srcByte shr (8 - accumBits)

    if dstIdx < result.limbs.len:
      result.limbs[dstIdx] = accum
      for fillIdx in dstIdx+1 ..< result.limbs.len:
        result.limbs[fillIdx] = 0
  else:                          # src and CPU are bigEndian
    dstIdx = result.limbs.len-1

    for srcIdx in countdown(x.len-1, 0):
      let srcByte = x[srcIdx]

      accum = accum or (srcByte shl accumBits)
      accumBits += 8

      if accumBits >= WordBitWidth:
        result.limbs[dstIdx] = accum
        dec dstIdx
        accumBits -= WordBitWidth
        accum = srcByte shr (8 - accumBits)

    if dstIdx > 0:
      result.limbs[dstIdx] = accum
      for fillIdx in 0 ..< dstIdx:
        result.limbs[fillIdx] = 0

func fromBytesLE*[bits: static int](
    T: typedesc[StUint[bits]],
    x: openArray[byte]): T =
  ## Read little endian bytes and convert to an integer. At runtime, v must
  ## contain at least sizeof(T) bytes. By default, native endianess is used
  ## which is not portable! (i.e. use fixed-endian byte array or hex for serialization)

  var accum: Word
  var accumBits: int
  var dstIdx: int

  when cpuEndian == littleEndian: # src and CPU are little-endian
    dstIdx = 0

    for srcIdx in 0 ..< x.len:
      let srcByte = x[srcIdx]

      accum = accum or (srcByte shl accumBits)
      accumBits += 8

      if accumBits >= WordBitWidth:
        result.limbs[dstIdx] = accum
        inc dstIdx
        accumBits -= WordBitWidth
        accum = srcByte shr (8 - accumBits)

    if dstIdx < result.limbs.len:
      result.limbs[dstIdx] = accum
      for fillIdx in dstIdx+1 ..< result.limbs.len:
        result.limbs[fillIdx] = 0
  else:                          # src is little endian, CPU is bigEndian
    dstIdx = result.limbs.len-1

    for srcIdx in 0 ..< x.len:
      let srcByte = x[srcIdx]

      accum = accum or (srcByte shl accumBits)
      accumBits += 8

      if accumBits >= WordBitWidth:
        result.limbs[dstIdx] = accum
        dec dstIdx
        accumBits -= WordBitWidth
        accum = srcByte shr (8 - accumBits)

    if dstIdx > 0:
      result.limbs[dstIdx] = accum
      for fillIdx in 0 ..< dstIdx:
        result.limbs[fillIdx] = 0

func fromBytes*[bits: static int](
    T: typedesc[StUint[bits]],
    x: openarray[byte],
    srcEndian: Endianness = system.cpuEndian): T {.inline.} =
  ## Read an source bytearray with the specified endianness and
  ## convert it to an integer
  when srcEndian == littleEndian:
    result = fromBytesLE(T, x)
  else:
    result = fromBytesBE(T, x)

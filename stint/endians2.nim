# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import private/datatypes

import stew/endians2
export endians2

{.push raises: [IndexError], noInit, gcsafe.}

func toBytes*[bits: static int](x: StUint[bits], endian: Endianness = system.cpuEndian):
    array[bits div 8, byte] {.inline.} =
  when endian == system.cpuEndian:
    for i in 0 ..< x.limbs.len:
      result[i * sizeof(Word)] = x.limbs[i].toBytes()
  else:
    for i in 0 ..< x.limbs.len:
      result[i * sizeof(Word)] = x.limbs[^i].toBytes()

func toBytesLE*[bits: static int](x: StUint[bits]):
    array[bits div 8, byte] {.inline.} =
  toBytes(x, littleEndian)

func toBytesBE*[bits: static int](x: StUint[bits]):
    array[bits div 8, byte] {.inline.} =
  toBytes(x, bigEndian)

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

# TODO: What is the use-case for all the procs below?
# ------------------------------------------------------------------------------------------

func toBE*[bits: static int](x: StUint[bits]): StUint[bits] {.inline, deprecated: "Use toByteArrayBE instead".} =
  ## Convert a native endian value to big endian. Consider toBytesBE instead
  ## which may prevent some confusion.
  if cpuEndian == bigEndian: x
  else: x.swapBytes

func fromBE*[bits: static int](x: StUint[bits]): StUint[bits] {.inline, deprecated: "Use fromBytesBE instead".} =
  ## Read a big endian value and return the corresponding native endian
  # there's no difference between this and toBE, except when reading the code
  toBE(x)

func toLE*[bits: static int](x: StUint[bits]): StUint[bits] {.inline, deprecated.} =
  ## Convert a native endian value to little endian. Consider toBytesLE instead
  ## which may prevent some confusion.
  if cpuEndian == littleEndian: x
  else: x.swapBytes

func fromLE*[bits: static int](x: StUint[bits]): StUint[bits] {.inline, deprecated: "Use fromBytesLE instead".} =
  ## Read a little endian value and return the corresponding native endian
  # there's no difference between this and toLE, except when reading the code
  toLE(x)

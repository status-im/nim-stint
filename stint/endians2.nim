# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import private/[bitops2_priv, endians2_priv, datatypes, compiletime_helpers]

import stew/endians2
export endians2

func swapBytes*(x: StUint): StUint {.inline.} = StUint(data: swapBytes(x.data))

func toBytes*[bits: static int](x: StUint[bits], endian: Endianness = system.cpuEndian):
    array[bits div 8, byte] {.inline.} =
  toBytes(x.data, endian)

func toBytesLE*[bits: static int](x: StUint[bits]):
    array[bits div 8, byte] {.inline.} =
  toBytes(x, littleEndian)

func toBytesBE*[bits: static int](x: StUint[bits]):
    array[bits div 8, byte] {.inline.} =
  toBytes(x, bigEndian)

func fromBytes*[bits: static int](
    T: typedesc[StUint[bits]],
    x: array[bits div 8, byte],
    endian: Endianness = system.cpuEndian): T {.inline, noinit.} =

  when nimvm:
    copyFromArray(result.data, x)
  else:
    copyMem(addr result, unsafeAddr x[0], bits div 8)

  if endian != system.cpuEndian:
    result = swapBytes(result)

func fromBytes*[bits: static int](
    T: typedesc[StUint[bits]],
    x: openArray[byte],
    endian: Endianness = system.cpuEndian): T {.inline.} =
  # TODO fromBytesBE in io.nim handles this better, merge the two!
  var tmp: array[bits div 8, byte]
  if x.len < tmp.len:
    let offset = if endian == bigEndian: tmp.len - x.len else: 0
    for i in 0..<x.len: # Loop since vm can't copymem
      tmp[i + offset] = x[i]
  else:
    for i in 0..<tmp.len: # Loop since vm can't copymem
      tmp[i] = x[i]
  fromBytes(T, tmp, endian)

func fromBytesBE*[bits: static int](
    T: typedesc[StUint[bits]],
    x: array[bits div 8, byte]): T {.inline.} =
  ## Read big endian bytes and convert to an integer. By default, native
  ## endianess is used which is not
  ## portable!
  fromBytes(T, x, bigEndian)

func fromBytesBE*[bits: static int](
    T: typedesc[StUint[bits]],
    x: openArray[byte]): T {.inline.} =
  ## Read big endian bytes and convert to an integer. At runtime, v must contain
  ## at least sizeof(T) bytes. By default, native endianess is used which is not
  ## portable!
  fromBytes(T, x, bigEndian)

func toBE*[bits: static int](x: StUint[bits]): StUint[bits] {.inline.} =
  ## Convert a native endian value to big endian. Consider toBytesBE instead
  ## which may prevent some confusion.
  if cpuEndian == bigEndian: x
  else: x.swapBytes

func fromBE*[bits: static int](x: StUint[bits]): StUint[bits] {.inline.} =
  ## Read a big endian value and return the corresponding native endian
  # there's no difference between this and toBE, except when reading the code
  toBE(x)

func fromBytesLE*[bits: static int](
    T: typedesc[StUint[bits]],
    x: array[bits div 8, byte]): StUint[bits] {.inline.} =
  ## Read little endian bytes and convert to an integer. By default, native
  ## endianess is used which is not portable!
  fromBytes(T, x, littleEndian)

func fromBytesLE*[bits: static int](
    T: typedesc[StUint[bits]],
    x: openArray[byte]): StUint[bits] {.inline.} =
  ## Read little endian bytes and convert to an integer. At runtime, v must
  ## contain at least sizeof(T) bytes. By default, native endianess is used
  ## which is not portable!
  fromBytes(T, x, littleEndian)

func toLE*[bits: static int](x: StUint[bits]): StUint[bits] {.inline.} =
  ## Convert a native endian value to little endian. Consider toBytesLE instead
  ## which may prevent some confusion.
  if cpuEndian == littleEndian: x
  else: x.swapBytes

func fromLE*[bits: static int](x: StUint[bits]): StUint[bits] {.inline.} =
  ## Read a little endian value and return the corresponding native endian
  # there's no difference between this and toLE, except when reading the code
  toLE(x)

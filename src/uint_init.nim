# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  typetraits

import ./uint_type

proc toMpUint*(n: uint16): MpUint[16] {.noInit, inline, noSideEffect.}=
  ## Cast an integer to the corresponding size MpUint
  cast[MpUint[16]](n)

proc toMpUint*(n: uint32): MpUint[32] {.noInit, inline, noSideEffect.}=
  ## Cast an integer to the corresponding size MpUint
  cast[MpUint[32]](n)

proc toMpUint*(n: uint64): MpUint[64] {.noInit, inline, noSideEffect.}=
  ## Cast an integer to the corresponding size MpUint
  cast[MpUint[64]](n)

proc initMpUint*(n: SomeUnsignedInt, bits: static[int]): MpUint[bits] {.noSideEffect.} =

  const nb_bits = n.sizeof * 8

  static:
    assert (bits and (bits-1)) == 0, $bits & " is not a power of 2"
    assert bits >= 16, "The number of bits in a should be greater or equal to 16"
    assert nb_bits <= bits, "Input cannot be stored in a " & $bits "-bit multi-precision unsigned integer\n"  &
                            "It requires at least " & nb_bits & " bits of precision"

  when nb_bits <= bits div 2:
    result.lo = (type result.lo)(n)
  else:
    result = n.toMpUint

  ## TODO: The current initMpUint prevents the following:
  ## let a = 10
  ## let b = initMpUint[16](a)
  ##
  ## It should use bit_length to get the number of bits needed instead

# proc u128*[T: BaseUInt](n: T): UInt128 {.noSideEffect, inline.}=
#   initMpUint(n, uint64)

# proc u256*[T: BaseUInt](n: T): UInt256 {.noSideEffect, inline.}=
#   initMpUint(n, UInt256)


when isMainModule:

  let a = 10'u16

  let b = a.toMpUint

  echo b.repr
  echo b

# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, stdlib_bitops, as_words
export stdlib_bitops

# We reuse bitops from Nim standard lib, and expand it for multi-precision int.
# MpInt rely on no undefined behaviour as often we scan 0. (if 1 is stored in a uint128 for example)
# Also countLeadingZeroBits must return the size of the type and not 0 like in the stdlib

func countLeadingZeroBits*(n: UintImpl): int {.inline.} =
  ## Returns the number of leading zero bits in integer.

  const maxHalfRepr = getSize(n) div 2

  let hi_clz = n.hi.countLeadingZeroBits

  result =  if hi_clz == maxHalfRepr:
              n.lo.countLeadingZeroBits + maxHalfRepr
            else: hi_clz

func msb*[T: SomeInteger](n: T): T =
  ## Returns the most significant bit of an integer.

  when T is int64 or (T is int and sizeof(int) == 8):
    type UInt = uint64
  elif T is int32 or (T is int and sizeof(int) == 4):
    type Uint = uint32
  elif T is int16:
    type Uint = uint16
  elif T is int8:
    type Uint = uint8
  else:
    type Uint = T

  const msb_pos = sizeof(T) * 8 - 1
  result = T(cast[Uint](n) shr msb_pos)

func msb*(n: IntImpl): auto =
  ## Returns the most significant bit of an arbitrary precision integer.

  result = msb most_significant_word(n)

# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./uint_type, stdlib_bitops
export stdlib_bitops

# We reuse bitops from Nim standard lib, and expand it for multi-precision int.
# MpInt rely on no undefined behaviour as often we scan 0. (if 1 is stored in a uint128 for example)
# Also countLeadingZeroBits must return the size of the type and not 0 like in the stdlib

func countLeadingZeroBits*(n: MpUintImpl): int {.inline.} =
  ## Returns the number of leading zero bits in integer.

  const maxHalfRepr = getSize(n) div 2

  let hi_clz = n.hi.countLeadingZeroBits

  result =  if hi_clz == maxHalfRepr:
              n.lo.countLeadingZeroBits + maxHalfRepr
            else: hi_clz

func bit_length*(n: SomeInteger): int {.inline.}=
  ## Calculates how many bits are necessary to represent the number
  result = getSize(n) - n.countLeadingZeroBits

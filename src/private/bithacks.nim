# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./uint_type, stdlib_bitops, size_mpuintimpl

# We reuse bitops from Nim standard lib and optimize it further on x86.
# On x86 clz it is implemented as bitscanreverse then xor and we need to again xor/sub.
# We need the bsr instructions so we xor again hoping for the compiler to only keep 1.

proc bit_length*(x: SomeInteger): int {.noSideEffect.}=
  when nimvm:
    when sizeof(x) <= 4: result = if x == 0: 0 else: fastlog2_nim(x.uint32)
    else:                result = if x == 0: 0 else: fastlog2_nim(x.uint64)
  else:
    when useGCC_builtins:
      when sizeof(x) <= 4: result = if x == 0: 0 else: builtin_clz(x.uint32) xor 31.cint
      else:                result = if x == 0: 0 else: builtin_clzll(x.uint64) xor 63.cint
    elif useVCC_builtins:
      when sizeof(x) <= 4:
        result = if x == 0: 0 else: vcc_scan_impl(bitScanReverse, x.culong)
      elif arch64:
        result = if x == 0: 0 else: vcc_scan_impl(bitScanReverse64, x.uint64)
      else:
        result = if x == 0: 0 else: fastlog2_nim(x.uint64)
    elif useICC_builtins:
      when sizeof(x) <= 4:
        result = if x == 0: 0 else: icc_scan_impl(bitScanReverse, x.uint32)
      elif arch64:
        result = if x == 0: 0 else: icc_scan_impl(bitScanReverse64, x.uint64)
      else:
        result = if x == 0: 0 else: fastlog2_nim(x.uint64)
    else:
      when sizeof(x) <= 4:
        result = if x == 0: 0 else: fastlog2_nim(x.uint32)
      else:
        result = if x == 0: 0 else: fastlog2_nim(x.uint64)


proc bit_length*(n: MpUintImpl): int {.noSideEffect.}=
  ## Calculates how many bits are necessary to represent the number

  const maxHalfRepr = n.lo.type.sizeof * 8 - 1

  # Changing the following to an if expression somehow transform the whole ASM to 5 branches
  # instead of the 4 expected (with the inline ASM from bit_length_impl)
  # Also there does not seems to be a way to generate a conditional mov
  let hi_bitlen = n.hi.bit_length
  result = if hi_bitlen == 0: n.lo.bit_length
           else: hi_bitlen + maxHalfRepr


proc countLeadingZeroBits*(x: MpUintImpl): int {.inline, nosideeffect.} =
  ## Returns the number of leading zero bits in integer.

  const maxHalfRepr = size_mpuintimpl(x.lo)

  let hi_clz = x.hi.countLeadingZeroBits
  result = if hi_clz == 0: x.lo.countLeadingZeroBits + maxHalfRepr
           else: hi_clz

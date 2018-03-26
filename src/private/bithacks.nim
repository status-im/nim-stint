# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./uint_type, bitops

proc bit_length*(x: SomeInteger): int {.inline, noSideEffect.}=
  if x == 0: 0
  else: fastlog2(x)

proc bit_length*(n: MpUintImpl): int {.noSideEffect.}=
  ## Calculates how many bits are necessary to represent the number

  const maxHalfRepr = n.lo.type.sizeof * 8 - 1

  # Changing the following to an if expression somehow transform the whole ASM to 5 branches
  # instead of the 4 expected (with the inline ASM from bit_length_impl)
  # Also there does not seems to be a way to generate a conditional mov
  if n.hi.bit_length == 0:
    n.lo.bit_length
  else:
    n.hi.bit_length + maxHalfRepr

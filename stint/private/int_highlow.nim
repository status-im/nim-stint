# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./datatypes, ./int_bitwise_ops, ./initialization, ./uint_highlow, typetraits

# XXX There's some Araq reason why this isn't part of the std lib..
func high(T: typedesc[SomeUnsignedInt]): T =
  not T(0)

func high*[T, T2](_: typedesc[IntImpl[T, T2]]): IntImpl[T, T2] {.inline.}=
  # The highest signed int has representation
  # 0b0111_1111_1111_1111 ....
  # so we only have to unset the most significant bit.
  result.hi = high(type result.hi)
  result.lo = high(type result.lo)

func low*[T, T2](_: typedesc[IntImpl[T, T2]]): IntImpl[T, T2] {.inline.}=
  # The lowest signed int has representation
  # 0b1000_0000_0000_0000 ....
  # so we only have to set the most significant bit.
  not high(IntImpl[T, T2])

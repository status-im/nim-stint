# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./datatypes, ./uint_bitwise_ops, ./int_bitwise_ops, ./initialization

func high*[T](_: typedesc[IntImpl[T]]): IntImpl[T] {.inline.}=

  # The lowest signed int has representation
  # 0b0111_1111_1111_1111 ....
  # so we only have to unset the most significant bit.
  let only_msb_set = UintImpl[T].zero.not shr 1
  result = cast[IntImpl[T]](only_msb_set)

func low*[T](_: typedesc[IntImpl[T]]): IntImpl[T] {.inline.}=

  # The lowest signed int has representation
  # 0b1000_0000_0000_0000 ....
  # so we only have to set the most significant bit.
  not high(IntImpl[T])

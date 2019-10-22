# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./datatypes, ./uint_mul, ./compiletime_helpers

func `*`*[T, T2](x, y: IntImpl[T, T2]): IntImpl[T, T2] {.inline.}=
  ## Multiplication for multi-precision signed integers
  # For 2-complement representation this is the exact same
  # as unsigned multiplication. We don't need to deal with the sign
  # TODO: overflow detection.
  convert[type result](convert[UIntImpl[T2]](x) * convert[UIntImpl[T2]](y))

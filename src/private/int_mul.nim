# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./datatypes, ./uint_mul

func `*`*[T](x, y: IntImpl[T]): IntImpl[T] {.inline, noInit.}=
  ## Multiplication for multi-precision unsigned uint
  cast[type result](cast[UIntImpl[T]](x) * cast[UIntImpl[T]](y))

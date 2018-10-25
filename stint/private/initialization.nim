# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./datatypes

func zero*(T: typedesc): T {.inline.} =
  discard

func one*(T: typedesc[SomeInteger]): T {.inline.} =
  1

func one*(T: typedesc[UintImpl or IntImpl]): T {.inline.} =
  result.lo = one(type result.lo)

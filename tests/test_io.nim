# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../src/stint, unittest

suite "Testing input and output procedures":
  test "Creation from decimal strings":
    block:
      let a = parse(Stint[64], "123456789")
      let b = 123456789.stint(64)

      check: a == b
      check: 123456789'i64 == cast[int64](a)

    block:
      let a = parse(Stuint[64], "123456789")
      let b = 123456789.stuint(64)

      check: a == b
      check: 123456789'u64 == cast[uint64](a)

    block:
      let a = parse(Stint[64], "-123456789")
      let b = (-123456789).stint(64)

      check: a == b
      check: -123456789'i64 == cast[int64](a)

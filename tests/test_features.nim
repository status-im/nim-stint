# Copyright 2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest

suite "new features":
  test "custom literal":
    const
      a = 0xabcdef0123456'u128
      b = 0xabcdef0123456'u256
      c = -100'i128
      d = -50000'i256

    let
      x = 0b111100011'u128
      y = 0o777766666'u256

    check:
      a == 0xabcdef0123456.u128
      b == 0xabcdef0123456.u256
      c == -100.i128
      d == -50000.i256
      x == 0b111100011.u128
      y == 0o777766666.u256

# Copyright 2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ../stint,
  unittest2

template reject(code: untyped) =
  static: assert(not compiles(code))

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
      z = 0x1122334455667788991011121314151617181920aabbccddeeffb1b2b3b4b500'u256
      w = 340282366920938463463374607431768211455'u128

    check:
      a == 0xabcdef0123456.u128
      b == 0xabcdef0123456.u256
      c == -100.i128
      d == -50000.i256
      x == 0b111100011.u128
      y == 0o777766666.u256
      z == UInt256.fromHex("0x1122334455667788991011121314151617181920aabbccddeeffb1b2b3b4b500")
      w == UInt128.fromDecimal("340282366920938463463374607431768211455")

  test "custom literal overflow":
    reject:
      const
        z = 0x1122334455667788991011121314151617181920aabbccddeeffb1b2b3b4b5700'u256
      doAssert(false)

    reject:
      let
        z = 0x1122334455667788991011121314151617181920aabbccddeeffb1b2b3b4b5700'u256
      doAssert(false)

    reject:
      const
        w = 1122334455667788991011121314151617181920'u128
      doAssert(false)

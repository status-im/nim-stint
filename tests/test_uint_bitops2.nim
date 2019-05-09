# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest

suite "Testing bitops2":
  test "Bitops give sane results":

    check:
      countOnes(0b01000100'u8.stuint(128)) == 2
      countOnes(0b01000100'u8.stuint(128) shl 100) == 2

      parity(0b00000001'u8.stuint(128)) == 1
      parity(0b00000001'u8.stuint(128) shl 100) == 1

      firstOne(0b00000010'u8.stuint(128)) == 2
      firstOne(0b00000010'u8.stuint(128) shl 100) == 102
      firstOne(0'u8.stuint(128)) == 0

      leadingZeros(0'u8.stuint(128)) == 128
      leadingZeros(0b00100000'u8.stuint(128)) == 128 - 6
      leadingZeros(0b00100000'u8.stuint(128) shl 100) == 128 - 106

      trailingZeros(0b00100000'u8.stuint(128)) == 5
      trailingZeros(0b00100000'u8.stuint(128) shl 100) == 105
      trailingZeros(0'u8.stuint(128)) == 128

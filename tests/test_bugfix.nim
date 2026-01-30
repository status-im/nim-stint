# Copyright 2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest2

suite "various bugfix":
  test "skipPrefixes bug":
    let x = "0b1010101".parse(UInt128, 2)
    let z = "0bcdef12345".parse(UInt128, 16)

    check x == 0b1010101.u128
    check z == 0x0bcdef12345.u128

    expect(AssertionDefect):
      discard "0bcdef12345".parse(UInt128, 10)

  test "high and low when number of bits is not a power of 2":
    check StUint[24].high.stuint(128) == 2.u128.pow(24) - 1
    check StUint[40].high.stuint(128) == 2.u128.pow(40) - 1
    check StUint[96].high.stuint(128) == 2.u128.pow(96) - 1

    check StInt[24].high.stint(128) == 2.i128.pow(23) - 1.i128
    check StInt[40].high.stint(128) == 2.i128.pow(39) - 1.i128
    check StInt[96].high.stint(128) == 2.i128.pow(95) - 1.i128

    check StInt[24].low.stint(128) == - 2.i128.pow(23)
    check StInt[40].low.stint(128) == - 2.i128.pow(39)
    check StInt[96].low.stint(128) == - 2.i128.pow(95)

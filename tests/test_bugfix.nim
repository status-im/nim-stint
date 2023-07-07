# Copyright 2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest

suite "various bugfix":
  test "skipPrefixes bug":
    let x = "0b1010101".parse(UInt128, 2)
    let z = "0bcdef12345".parse(UInt128, 16)
    
    check x == 0b1010101.u128
    check z == 0x0bcdef12345.u128
    
    expect(AssertionDefect):
      discard "0bcdef12345".parse(UInt128, 10)

# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./private/[bitops2_priv, datatypes]

func countOnes*(x: StUint): int {.inline.} = countOnes(x.data)
func parity*(x: StUint): int {.inline.} = parity(x.data)
func firstOne*(x: StUint): int {.inline.} = firstOne(x.data)
func leadingZeros*(x: StUint): int {.inline.} = leadingZeros(x.data)
func trailingZeros*(x: StUint): int {.inline.} = trailingZeros(x.data)

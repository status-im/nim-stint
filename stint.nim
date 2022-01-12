# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

# import stint/[bitops2, endians2, intops, io, modular_arithmetic, literals_stint]
# export bitops2, endians2, intops, io, modular_arithmetic, literals_stint

import stint/[io, uintops]
export io, uintops

type
  # Int128* = Stint[128]
  # Int256* = Stint[256]
  UInt128* = StUint[128]
  UInt256* = StUint[256]

func u128*(n: SomeInteger): UInt128 {.inline.} = n.stuint(128)
func u128*(s: string): UInt128 {.inline.} = s.parse(UInt128)

func u256*(n: SomeInteger): UInt256 {.inline.} = n.stuint(256)
func u256*(s: string): UInt256 {.inline.} = s.parse(UInt256)

# func i128*(n: SomeInteger): Int128 {.inline.} = n.stint(128)
# func i128*(s: string): Int128 {.inline.} = s.parse(Int128)

# func i256*(n: SomeInteger): Int256 {.inline.} = n.stint(256)
# func i256*(s: string): Int256 {.inline.} = s.parse(Int256)

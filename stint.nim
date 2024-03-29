# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import stint/[io, uintops, intops, literals_stint, modular_arithmetic, int_modarith]
export io, uintops, intops, literals_stint, modular_arithmetic, int_modarith

type
  Int128* = StInt[128]
  Int256* = StInt[256]
  UInt128* = StUint[128]
  UInt256* = StUint[256]

func u128*(n: SomeInteger): UInt128 {.inline.} = n.stuint(128)
func u128*(s: string): UInt128 {.inline.} = s.parse(UInt128)

func u256*(n: SomeInteger): UInt256 {.inline.} = n.stuint(256)
func u256*(s: string): UInt256 {.inline.} = s.parse(UInt256)

func i128*(n: SomeInteger): Int128 {.inline.} = n.stint(128)
func i128*(s: string): Int128 {.inline.} = s.parse(Int128)

func i256*(n: SomeInteger): Int256 {.inline.} = n.stint(256)
func i256*(s: string): Int256 {.inline.} = s.parse(Int256)

# According to nim manual, you can write something like 1234567890'u256
# or 1234567890'i256, and the number will be passed as string to the
# constructor

func `'i128`*(s: static string): Int128 {.inline.} = 
  customLiteral(Int128, s)

func `'i256`*(s: static string): Int256 {.inline.} = 
  customLiteral(Int256, s)
  
func `'u128`*(s: static string): UInt128 {.inline.} = 
  customLiteral(UInt128, s)

func `'u256`*(s: static string): UInt256 {.inline.} = 
  customLiteral(UInt256, s)

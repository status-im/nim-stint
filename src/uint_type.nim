# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

type
  # TODO: The following is a hacky workaround
  # due to:
  #   - https://github.com/nim-lang/Nim/issues/7230
  #   - https://github.com/nim-lang/Nim/issues/7378
  #   - https://github.com/nim-lang/Nim/issues/7379

  BitsHolder[bits: static[int]] = object

type
  MpUintImpl[bh] = object
    # TODO: when gcc/clang defines it use the builtin uint128
    when system.cpuEndian == littleEndian:
      when bh is BitsHolder[128]: lo*, hi*: uint64
      elif bh is BitsHolder[64]: lo*, hi*: uint32
      elif bh is BitsHolder[32]: lo*, hi*: uint16
      elif bh is BitsHolder[16]: lo*, hi*: uint8

      # The following cannot be implemented recursively yet
      elif bh is BitsHolder[256]: lo*, hi*: MpUintImpl[BitsHolder[128]]
      # else:
      #   Not implemented
    else:
      when bh is BitsHolder[128]: hi*, lo*: uint64
      elif bh is BitsHolder[64]: hi*, lo*: uint32
      elif bh is BitsHolder[32]: hi*, lo*: uint16
      elif bh is BitsHolder[16]: hi*, lo*: uint8

      # The following cannot be implemented recursively yet
      elif bh is BitsHolder[256]: hi*, lo*: MpUintImpl[BitsHolder[128]]
      # else:
      #   Not implemented

  MpUint*[bits: static[int]] = MpUintImpl[BitsHolder[bits]]

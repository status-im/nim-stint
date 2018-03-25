# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

type
  MpUint*{.packed.}[BaseUint] = object
    when system.cpuEndian == littleEndian:
      lo*, hi*: BaseUint
    else:
      hi*, lo*: BaseUint

  BaseUint* = SomeUnsignedInt or MpUint


  UInt128* = MpUint[uint64]
  UInt256* = MpUint[UInt128]

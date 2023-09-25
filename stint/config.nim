# Stint
# Copyright 2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

const
  stintNoIntrinsics* {.booldefine.} = false
    ## Use only native Nim code without intrinsics, emit or asm - useful for
    ## targets such as wasm and compilers with no native int128 support (and the
    ## vm!)

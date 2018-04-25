# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, ./bithacks, ./as_words,
        ./bithacks

func isZero*(n: SomeSignedInt): bool {.inline.} =
  n == 0

func isZero*(n: IntImpl): bool {.inline.} =
  asWords(n, ignoreEndianness = true):
    if n != 0:
      return false
  return true

func isNegative*(n: IntImpl): bool {.inline.} =
  ## Returns true if a number is negative:
  n.msb.bool

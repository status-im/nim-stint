# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, ./as_words

func isZero*(n: SomeUnsignedInt): bool {.inline.} =
  n == 0

func isZero*(n: UintImpl): bool {.inline.} =
  asWords(n, ignoreEndianness = true):
    if n != 0:
      return false
  return true

func `<`*(x, y: UintImpl): bool {.inline.}=
  # Lower comparison for multi-precision integers
  asWordsZip(x, y, ignoreEndianness = false):
    if x != y:
      return x < y
  return false # they're equal

func `==`*(x, y: UintImpl): bool {.inline.}=
  # Equal comparison for multi-precision integers
  asWordsZip(x, y, ignoreEndianness = true):
    if x != y:
      return false
  return true # they're equal

func `<=`*(x, y: UintImpl): bool {.inline.}=
  # Lower or equal comparison for multi-precision integers
  asWordsZip(x, y, ignoreEndianness = false):
    if x != y:
      return x < y
  return true # they're equal

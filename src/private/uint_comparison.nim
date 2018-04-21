# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./uint_type, ./as_words

func isZero*(n: SomeUnsignedInt): bool {.inline.} =
  n == 0

func isZero*(n: MpUintImpl): bool {.inline.} =
  for val in asWordsRaw(n):
    if val != 0:
      return false
  return true

func `<`*(x, y: MpUintImpl): bool {.inline.}=
  # Lower comparison for multi-precision integers
  for xw, yw in asWordsZip(x, y):
    if xw != yw:
      return xw < yw
  return false # they're equal

func `==`*(x, y: MpUintImpl): bool {.inline.}=
  # Equal comparison for multi-precision integers
  for xw, yw in asWordsRawZip(x, y):
    if xw != yw:
      return false
  return true # they're equal

func `<=`*(x, y: MpUintImpl): bool {.inline.}=
  # Lower or equal comparison for multi-precision integers
  for xw, yw in asWordsZip(x, y):
    if xw != yw:
      return xw < yw
  return  true # they're equal

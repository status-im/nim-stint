# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, ./as_words

func `not`*(x: IntImpl): IntImpl {.inline.}=
  ## Bitwise complement of unsigned integer x
  m_asWordsZip(result, x, ignoreEndianness = true):
    result = not x

func `or`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise or` of numbers x and y
  m_asWordsZip(result, x, y, ignoreEndianness = true):
    result = x or y

func `and`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise and` of numbers x and y
  m_asWordsZip(result, x, y, ignoreEndianness = true):
    result = x and y

func `xor`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise xor` of numbers x and y
  m_asWordsZip(result, x, y, ignoreEndianness = true):
    result = x xor y

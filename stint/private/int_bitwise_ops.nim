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
  {.push experimental: "forLoopMacros".}
  for wr, wx in asWords(result, x):
    wr = not wx
  {.pop.}

func `or`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise or` of numbers x and y
  {.push experimental: "forLoopMacros".}
  for wr, wx, wy in asWords(result, x, y):
    wr = wx or wy
  {.pop.}

func `and`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise and` of numbers x and y
  {.push experimental: "forLoopMacros".}
  for wr, wx, wy in asWords(result, x, y):
    wr = wx and wy
  {.pop.}

func `xor`*(x, y: IntImpl): IntImpl {.inline.}=
  ## `Bitwise xor` of numbers x and y
  {.push experimental: "forLoopMacros".}
  for wr, wx, wy in asWords(result, x, y):
    wr = wx xor wy
  {.pop.}

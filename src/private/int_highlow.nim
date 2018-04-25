# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./datatypes, ./as_signed_words

func low*(T: typedesc[UintImpl]): T {.inline.}=

  # The lowest signed int has representation
  # 0b1000_0000_0000_0000 ....
  # so we only have to set the most significant bit.
  type Msw = type result.most_significant_word
  when Msw is uint64:
    type U = int64
  else:
    type U = Msw

  result.most_significant_word = low(U)

func high*(T: typedesc[UintImpl]): T {.inline, noInit.}=

  # The lowest signed int has representation
  # 0b0111_1111_1111_1111 ....
  # so we only have to unset the most significant bit.
  not low(T)

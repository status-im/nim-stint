# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

import ../src/mpint, unittest

suite "Testing byte representation":
  test "Byte representation conforms to the platform endianness":
    let a = initMpUint(20182018, uint32)
    let b = 20182018'u64

    type AsBytes = array[8, byte]

    check cast[AsBytes](a) == cast[AsBytes](b)


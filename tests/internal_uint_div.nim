# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

# Test implementation of internal proc:

include ../stint/private/uint_div
import unittest

suite "implementation of internal division procecures":
  test "Division of 2 words by 1 - specific carry case (issue #30)":

    # // Reference implementation from glibc: udiv.h

    # #include <stdint.h>
    # typedef uint32_t USItype;

    # #define udiv_qrnnd(q, r, n1, n0, dx) /* d renamed to dx avoiding "=d" */\
    #   __asm__ ("divl %4"		     /* stringification in K&R C */	\
    # 	   : "=a" (q), "=d" (r)						\
    # 	   : "0" ((USItype)(n0)), "1" ((USItype)(n1)), "rm" ((USItype)(dx)))

    ################################

    # #include "udiv.h"
    # #include <stdio.h>
    # int main( int argc, const char* argv[] )
    # {
    #   UWtype q, r, n1, n0, d;

    #   q = 0;
    #   r = 0;
    #   n1 = 233;
    #   n0 = 1717253765;
    #   d = 2659025738;

    #   udiv_qrnnd(q, r, n1, n0, d);

    #   printf("q: %u\n", q);
    #   printf("r: %u\n", r);
    # }

    ###############################

    var q, r: uint32
    let
      n1 = uint32 233
      n0 = uint32 1717253765
      d = uint32 2659025738

    div2n1n(q, r, n1, n0, d)

    check:
      q == 376
      r == 2650956245'u32

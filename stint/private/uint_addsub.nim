# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./conversion, ./initialization,
        ./datatypes,
        ./uint_comparison,
        ./uint_bitwise_ops

# ############ Addition & Substraction ############ #

func `+`*(x, y: UintImpl): UintImpl {.inline.}
  # Forward declaration

func `+=`*(x: var UintImpl, y: UintImpl) {.inline.}=
  ## In-place addition for multi-precision unsigned int
  type SubTy = type x.lo
  x.lo += y.lo
  x.hi += (x.lo < y.lo).toSubtype(SubTy) + y.hi # This helps the compiler produce ADC (add with carry)

func `+`*(x, y: UintImpl): UintImpl {.inline.}=
  # Addition for multi-precision unsigned int
  result = x
  result += y

func `-`*(x, y: UintImpl): UintImpl {.inline.}=
  # Substraction for multi-precision unsigned int
  type SubTy = type x.lo
  result.lo = x.lo - y.lo
  result.hi = x.hi - y.hi - (x.lo < y.lo).toSubtype(SubTy) # This might (?) help the compiler produce SBB (sub with borrow)

func `-=`*(x: var UintImpl, y: UintImpl) {.inline.}=
  ## In-place substraction for multi-precision unsigned int
  x = x - y

func inc*(x: var UintImpl){.inline.}=
  x += one(type x)

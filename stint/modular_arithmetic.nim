# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./uint_public

func addmod_internal(a, b, m: Stuint): Stuint {.inline.}=
  ## Modular addition
  ## ⚠⚠ Assume a < m and b < m

  assert a < m
  assert b < m

  # We don't do a_m + b_m directly to avoid overflows
  let b_from_m = m - b

  if a >= b_from_m:
    return a - b_from_m
  return m - b_from_m + a

func submod_internal(a, b, m: Stuint): Stuint {.inline.}=
  ## Modular substraction
  ## ⚠⚠ Assume a < m and b < m

  assert a < m
  assert b < m

  # We don't do a_m - b_m directly to avoid underflows
  if a >= b:
    return a - b
  return m - b + a


func doublemod_internal(a, m: Stuint): Stuint {.inline.}=
  ## Double a modulo m. Assume a < m
  ## Internal proc - used in mulmod

  assert a < m

  result = a
  if a >= m - a:
    result -= m
  result += a

func mulmod_internal(a, b, m: Stuint): Stuint {.inline.}=
  ## Does (a * b) mod m. Assume a < m and b < m
  ## Internal proc - used in powmod

  assert a < m
  assert b < m

  var (a, b) = (a, b)

  if b > a:
    swap(a, b)

  while not b.isZero:
    if b.isOdd:
      result = result.addmod_internal(a, m)
    a = doublemod_internal(a, m)
    b = b shr 1

func powmod_internal(a, b, m: Stuint): Stuint {.inline.}=
  ## Compute ``(a ^ b) mod m``, assume a < m
  ## Internal proc

  assert a < m

  var (a, b) = (a, b)
  result = one(type a)

  while not b.isZero:
    if b.isOdd:
      result = result.mulmod_internal(a, m)
    b = b shr 1
    a = mulmod_internal(a, a, m)

func addmod*(a, b, m: Stuint): Stuint =
  ## Modular addition

  let a_m = if a < m: a
            else: a mod m
  let b_m = if b < m: b
            else: b mod m

  result = addmod_internal(a_m, b_m, m)

proc submod*(a, b, m: Stuint): Stuint =
  ## Modular substraction

  let a_m = if a < m: a
            else: a mod m
  let b_m = if b < m: b
            else: b mod m

  result = submod_internal(a_m, b_m, m)

func mulmod*(a, b, m: Stuint): Stuint =
  ## Modular multiplication

  let a_m = if a < m: a
            else: a mod m
  let b_m = if b < m: b
            else: b mod m

  result = mulmod_internal(a_m, b_m, m)

proc powmod*(a, b, m: Stuint): Stuint =
  ## Modular exponentiation

  let a_m = if a < m: a
            else: a mod m

  result = powmod_internal(a_m, b, m)

# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./uintops, private/datatypes

{.push raises: [], gcsafe.}

func addmod_internal(a, b, m: StUint): StUint {.inline.}=
  ## Modular addition.
  ##
  ## ⚠⚠ Assume a < m and b < m.

  doAssert a < m
  doAssert b < m

  # We don't do a_m + b_m directly to avoid overflows
  let b_from_m = m - b

  if a >= b_from_m:
    a - b_from_m
  else:
    m - b_from_m + a

func submod_internal(a, b, m: StUint): StUint {.inline.}=
  ## Modular substraction.
  ##
  ## ⚠⚠ Assume a < m and b < m.

  doAssert a < m
  doAssert b < m

  # We don't do a_m - b_m directly to avoid underflows
  if a >= b:
    a - b
  else:
    m - b + a

template reduce(x, m: StUint): StUint =
  # `x` and `m` multiply evaluated; bind expressions to a `let`.
  if x < m: x else: x mod m

func addmod*(a, b, m: StUint): StUint =
  ## Modular addition.

  let s = a + b
  if s >= a:
    reduce(s, m)
  else:
    if s < m:
      let d = s - m
      reduce(d, m)
    else:
      let t = zero(typeof m) - m
      addmod_internal(s mod m, reduce(t, m), m)

func submod*(a, b, m: StUint): StUint =
  ## Modular substraction.

  if a >= b:
    let d = a - b
    reduce(d, m)
  else:
    let u = b - a
    let r = reduce(u, m)
    if r.isZero: r
    else: m - r

func mulmod*(a, b, m: StUint): StUint =
  ## Modular multiplication.

  let
    ax = a.stuint(a.bits * 2)
    bx = b.stuint(b.bits * 2)
    mx = m.stuint(m.bits * 2)
    px = ax * bx

  divmod(px, mx).rem.stuint(a.bits)

func powmod*(a, b, m: StUint): StUint =
  ## Modular exponentiation.

  var (a, b) = (a, b)
  result = one(type a)

  while not b.isZero:
    if b.isOdd:
      result = result.mulmod(a, m)
    b = b shr 1
    a = mulmod(a, a, m)

{.pop.}

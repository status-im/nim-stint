# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../datatypes

# ############################################################
#
# Extended precision primitives on GCC & Clang (all CPU archs)
#
# ############################################################

static:
  doAssert GCC_Compatible
  doAssert sizeof(int) == 8

func div2n1n_128*(q, r: var uint64, n_hi, n_lo, d: uint64) {.inline.}=
  ## Division uint128 by uint64
  ## Warning ⚠️ :
  ##   - if n_hi == d, quotient does not fit in an uint64 and will throw SIGFPE on some platforms
  ##   - if n_hi > d result is undefined
  var dblPrec {.noInit.}: uint128
  {.emit:[dblPrec, " = (unsigned __int128)", n_hi," << 64 | (unsigned __int128)",n_lo,";"].}

  # Don't forget to dereference the var param in C mode
  when defined(cpp):
    {.emit:[q, " = (NU64)(", dblPrec," / ", d, ");"].}
    {.emit:[r, " = (NU64)(", dblPrec," % ", d, ");"].}
  else:
    {.emit:["*",q, " = (NU64)(", dblPrec," / ", d, ");"].}
    {.emit:["*",r, " = (NU64)(", dblPrec," % ", d, ");"].}

func mul_128*(hi, lo: var uint64, a, b: uint64) {.inline.} =
  ## Extended precision multiplication
  ## (hi, lo) <- a*b
  block:
    var dblPrec {.noInit.}: uint128
    {.emit:[dblPrec, " = (unsigned __int128)", a," * (unsigned __int128)", b,";"].}

    # Don't forget to dereference the var param in C mode
    when defined(cpp):
      {.emit:[hi, " = (NU64)(", dblPrec," >> ", 64'u64, ");"].}
      {.emit:[lo, " = (NU64)", dblPrec,";"].}
    else:
      {.emit:["*",hi, " = (NU64)(", dblPrec," >> ", 64'u64, ");"].}
      {.emit:["*",lo, " = (NU64)", dblPrec,";"].}

func muladd1_128*(hi, lo: var uint64, a, b, c: uint64) {.inline.} =
  ## Extended precision multiplication + addition
  ## (hi, lo) <- a*b + c
  ##
  ## Note: 0xFFFFFFFF_FFFFFFFF² -> (hi: 0xFFFFFFFFFFFFFFFE, lo: 0x0000000000000001)
  ##       so adding any c cannot overflow
  ##
  ## This is constant-time on most hardware
  ## See: https://www.bearssl.org/ctmul.html
  block:
    var dblPrec {.noInit.}: uint128
    {.emit:[dblPrec, " = (unsigned __int128)", a," * (unsigned __int128)", b, " + (unsigned __int128)",c,";"].}

    # Don't forget to dereference the var param in C mode
    when defined(cpp):
      {.emit:[hi, " = (NU64)(", dblPrec," >> ", 64'u64, ");"].}
      {.emit:[lo, " = (NU64)", dblPrec,";"].}
    else:
      {.emit:["*",hi, " = (NU64)(", dblPrec," >> ", 64'u64, ");"].}
      {.emit:["*",lo, " = (NU64)", dblPrec,";"].}

func muladd2_128*(hi, lo: var uint64, a, b, c1, c2: uint64) {.inline.}=
  ## Extended precision multiplication + addition + addition
  ## This is constant-time on most hardware except some specific one like Cortex M0
  ## (hi, lo) <- a*b + c1 + c2
  ##
  ## Note: 0xFFFFFFFF_FFFFFFFF² -> (hi: 0xFFFFFFFFFFFFFFFE, lo: 0x0000000000000001)
  ##       so adding 0xFFFFFFFFFFFFFFFF leads to (hi: 0xFFFFFFFFFFFFFFFF, lo: 0x0000000000000000)
  ##       and we have enough space to add again 0xFFFFFFFFFFFFFFFF without overflowing
  block:
    var dblPrec {.noInit.}: uint128
    {.emit:[
      dblPrec, " = (unsigned __int128)", a," * (unsigned __int128)", b,
               " + (unsigned __int128)",c1," + (unsigned __int128)",c2,";"
    ].}

    # Don't forget to dereference the var param in C mode
    when defined(cpp):
      {.emit:[hi, " = (NU64)(", dblPrec," >> ", 64'u64, ");"].}
      {.emit:[lo, " = (NU64)", dblPrec,";"].}
    else:
      {.emit:["*",hi, " = (NU64)(", dblPrec," >> ", 64'u64, ");"].}
      {.emit:["*",lo, " = (NU64)", dblPrec,";"].}

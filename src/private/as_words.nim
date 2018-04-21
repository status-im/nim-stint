# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./uint_type, macros

macro optim(x: typed): untyped =
  let size = getSize(x)

  if size > 64:
    result = quote do:
      array[`size` div 64, uint64]
  elif size == 64:
    result = quote do:
      uint64
  elif size == 32:
    result = quote do:
      uint32
  elif size == 16:
    result = quote do:
      uint16
  elif size == 8:
    result = quote do:
      uint8
  else:
    error "Unreachable path reached"

# The following iterators allow efficient iteration on multiprecision integers internal representation.
# Note: in case the size in one, hopefully the compiler optimizes it.
#       using a template is not more efficient due to having to allocate the injection variable.
#       This can be rewritten using macros though
#
# template asWordsRawZip*(x, y: MpUintImpl, xw, yw: untyped, body: untyped): untyped =
#   when optim(x) is array:
#     let
#       x_ptr = cast[ptr optim(x)](x.unsafeaddr)
#       y_ptr = cast[ptr optim(y)](y.unsafeaddr)

#     for i in 0..<x_ptr[].len:
#       let
#         xw{.inject.} = x_ptr[i]
#         yw{.inject.} = y_ptr[i]
#       body
#   else:
#     let
#       xw{.inject.} = cast[optim(x)](x)
#       yw{.inject.} = cast[optim(y)](y)
#     body

iterator asWordsRaw*(n: MpUintImpl): auto =
  ## Iterates over n, as an array of words.
  ## Input:
  ##   - n: The Multiprecision int
  ##   - nw: A word of the multi-precision int
  ##   - body: the operation you want to do
  ## Iteration is done from low to high, not taking endianness in account
  when optim(`n`) is array:
    for val in cast[optim(n)](n):
      yield val
  else:
    yield cast[optim(n)](n)

iterator asWordsRawZip*(x, y: MpUintImpl): auto =
  ## Iterates over x and y, as an array of words.
  ## Input:
  ##   - x, y: The multiprecision ints
  ## Iteration is done from low to high, not taking endianness in account
  when optim(x) is array:
    {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
    let
      x_ptr{.restrict.} = cast[ptr optim(x)](x.unsafeaddr)
      y_ptr{.restrict.} = cast[ptr optim(y)](y.unsafeaddr)

    for i in 0..<x_ptr[].len:
      yield (x_ptr[i], y_ptr[i])
  else:
    yield (cast[optim(x)](x), cast[optim(y)](y))

iterator m_asWordsRawZip*(m: var MpUintImpl, x: MpUintImpl): auto =
  ## Iterates over a mutable int m and x as an array of words.
  ## returning a !! Pointer !! of the proper type to m.
  # TODO return a var. This is a workaround because casting prevents returning a var
  ## Input:
  ##   - m: A mutable array
  ##   - x: The multiprecision ints
  ## Iteration is done from low to high, not taking endianness in account
  when optim(x) is array:
    {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
    let
      m_ptr{.restrict.} = cast[ptr optim(m)](m.unsafeaddr)
      x_ptr{.restrict.} = cast[ptr optim(x)](x.unsafeaddr)

    for i in 0..<x_ptr[].len:
      yield (m_ptr[i].addr, x_ptr[i])
  else:
    yield (cast[ptr optim(m)](m), cast[optim(x)](x))

iterator m_asWordsRawZip*(m: var MpUintImpl, x, y: MpUintImpl): auto =
  ## Iterates over a mutable int m and x, y as an array of words.
  ## returning a !! Pointer !! of the proper type to m.
  # TODO return a var
  ## Input:
  ##   - m: A mutable array
  ##   - x, y: The multiprecision ints
  ## Iteration is done from low to high, not taking endianness in account
  when optim(x) is array:
    {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
    let
      m_ptr{.restrict.} = cast[ptr optim(m)](m.unsafeaddr)
      x_ptr{.restrict.} = cast[ptr optim(x)](x.unsafeaddr)
      y_ptr{.restrict.} = cast[ptr optim(y)](y.unsafeaddr)

    for i in 0..<x_ptr[].len:
      yield (m_ptr[i].addr, x_ptr[i], y_ptr[i])
  else:
    yield (cast[ptr optim(m)](m), cast[optim(x)](x), cast[optim(y)](y))

iterator asWordsZip*(x, y: MpUintImpl): auto =
  ## Iterates over n, as an array of words.
  ## Input:
  ##   - x, y: The multiprecision ints
  ##   - xw, yw: a pair of word of the multi-precision ints
  ##   - body: the operation you want to do
  ## Iteration is done from Most significant byte to Least significant byte
  ## i.e. memory order for BigEndian, reverse for little endian
  when optim(x) is array:
    {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
    let
      x_ptr{.restrict.} = cast[ptr optim(x)](x.unsafeaddr)
      y_ptr{.restrict.} = cast[ptr optim(y)](y.unsafeaddr)

    when system.cpuEndian == bigEndian:
      for i in 0..<x_ptr[].len:
        yield (x_ptr[i], y_ptr[i])
    else: # littleEndian, the most significant bytes are on the right
      for i in countdown(x_ptr[].len - 1, 0):
        yield (x_ptr[i], y_ptr[i])
  else:
    yield (cast[optim(x)](x), cast[optim(y)](y))

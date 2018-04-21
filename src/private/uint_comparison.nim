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

func isZero*(n: SomeUnsignedInt): bool {.inline.} =
  n == 0

func isZero*(n: MpUintImpl): bool {.inline.} =

  when optim(`n`) is array:
    for val in cast[optim(n)](n):
      if val != 0:
        return false
    return true
  else:
    cast[optim(n)](n) == 0

func `<`*(x, y: MpUintImpl): bool {.noInit, inline.}=

  when optim(x) is array:
    let
      x_ptr = cast[ptr optim(x)](x.unsafeaddr)
      y_ptr = cast[ptr optim(y)](y.unsafeaddr)

    when system.cpuEndian == bigEndian:
      for i in 0..<x_ptr[].len:
        if x_ptr[i] >= y_ptr[i]:
          return false
      return true
    else: # littleEndian, the most signficant bytes are on the right
      for i in countdown(x_ptr[].len - 1, 0):
        if x_ptr[i] >= y_ptr[i]:
          return false
      return true
  else:
    cast[optim(x)](x) < cast[optim(y)](y)

func `==`*(x, y: MpUintImpl): bool {.noInit, inline.}=
  # Equal comparison for multi-precision integers

  when optim(x) is array:
    let
      x_ptr = cast[ptr optim(x)](x.unsafeaddr)
      y_ptr = cast[ptr optim(y)](y.unsafeaddr)

    for i in 0..<x_ptr[].len:
      if x_ptr[i] != y_ptr[i]:
        return false
    return true
  else:
    cast[optim(x)](x) < cast[optim(y)](y)

func `<=`*(x, y: MpUintImpl): bool {.noInit, inline.}=
  # Lower or equal comparison for multi-precision integers

  when optim(x) is array:
    let
      x_ptr = cast[ptr optim(x)](x.unsafeaddr)
      y_ptr = cast[ptr optim(y)](y.unsafeaddr)

    when system.cpuEndian == bigEndian:
      for i in 0..<x_ptr[].len:
        if x_ptr[i] > y_ptr[i]:
          return false
      return true
    else: # littleEndian, the most signficant bytes are on the right
      for i in countdown(x_ptr[].len - 1, 0):
        if x_ptr[i] > y_ptr[i]:
          return false
      return true
  else:
    cast[optim(x)](x) <= cast[optim(y)](y)

# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ../uint_type

# Compiler defined const: https://github.com/nim-lang/Nim/wiki/Consts-defined-by-the-compiler
const withBuiltins = defined(gcc) or defined(clang)

when withBuiltins:
  proc builtin_clz(n: cuint): cint {.importc: "__builtin_clz", nodecl.}
  proc builtin_clz(n: culong): cint {.importc: "__builtin_clzl", nodecl.}
  proc builtin_clz(n: culonglong): cint {.importc: "__builtin_clzll", nodecl.}
  type TbuiltinSupported = cuint or culong or culonglong
  # Warning ⚠: if n = 0, clz is undefined

template bit_length_impl[T: SomeUnsignedInt or Natural or int](n: T, result: int) =
  # For some reason using "SomeUnsignedInt or Natural" directly makes Nim compiler
  # throw a type mismatch in a proc, we use a template as a workaround
  # Plus the template doesn't match natural with int :/
  when withBuiltins and T is TbuiltinSupported:
    result = if n == T(0): 0                    # Removing this branch would make divmod 4x faster :/
             else: T.sizeof * 8 - builtin_clz(n)

  else:
    # The biggest optimization for the naive implementation
    # is making sure this is inline
    # This is the difference between returning in 2ms or 10+ second
    # on a 1000000000 times test loop.
    var x = n
    while x != T(0):
      x = x shr 1
      inc(result)

proc bit_length*(n: SomeUnsignedInt): int {.noSideEffect, inline.}=
  ## Calculates how many bits are necessary to represent the number
  bit_length_impl(n, result)

proc bit_length*(n: Natural): int {.noSideEffect, inline.}=
  ## Calculates how many bits are necessary to represent the number
  bit_length_impl(n, result)

proc bit_length*[T: MpUint](n: T): int {.noSideEffect.}=
  ## Calculates how many bits are necessary to represent the number

  const maxHalfRepr = n.lo.type.sizeof * 8 - 1

  # Changing the following to an if expression somehow transform the whole ASM to 5 branches
  # instead of the 4 expected (with the inline ASM from bit_length_impl)
  # Also there does not seems to be a way to generate a conditional mov
  if n.hi.bit_length == 0:
    n.lo.bit_length
  else:
    n.hi.bit_length + maxHalfRepr

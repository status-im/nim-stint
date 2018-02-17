# Copyright (c) 2018 Status Research & Development GmbH
# Distributed under the MIT License (license terms are at http://opensource.org/licenses/MIT).

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

  if n.hi.bit_length == 0:
    n.lo.bit_length
  else:
    n.hi.bit_length + maxHalfRepr
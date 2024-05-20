# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../../config, ../datatypes, ./compiletime_fallback

# ############################################################
#
#            Add-with-carry and Sub-with-borrow
#
# ############################################################
#
# This file implements add-with-carry and sub-with-borrow
#
# It is currently (Mar 2020) impossible to have the compiler
# generate optimal code in a generic way.
#
# On x86, addcarry_u64 intrinsic will generate optimal code
# except for GCC.
#
# On other CPU architectures inline assembly might be desirable.
# A compiler proof-of-concept is available in the "research" folder.
#
# See https://gcc.godbolt.org/z/2h768y
# ```C
# #include <stdint.h>
# #include <x86intrin.h>
#
# void add256(uint64_t a[4], uint64_t b[4]){
#   uint8_t carry = 0;
#   for (int i = 0; i < 4; ++i)
#     carry = _addcarry_u64(carry, a[i], b[i], &a[i]);
# }
# ```
#
# GCC
# ```asm
# add256:
#         movq    (%rsi), %rax
#         addq    (%rdi), %rax
#         setc    %dl
#         movq    %rax, (%rdi)
#         movq    8(%rdi), %rax
#         addb    $-1, %dl
#         adcq    8(%rsi), %rax
#         setc    %dl
#         movq    %rax, 8(%rdi)
#         movq    16(%rdi), %rax
#         addb    $-1, %dl
#         adcq    16(%rsi), %rax
#         setc    %dl
#         movq    %rax, 16(%rdi)
#         movq    24(%rsi), %rax
#         addb    $-1, %dl
#         adcq    %rax, 24(%rdi)
#         ret
# ```
#
# Clang
# ```asm
# add256:
#         movq    (%rsi), %rax
#         addq    %rax, (%rdi)
#         movq    8(%rsi), %rax
#         adcq    %rax, 8(%rdi)
#         movq    16(%rsi), %rax
#         adcq    %rax, 16(%rdi)
#         movq    24(%rsi), %rax
#         adcq    %rax, 24(%rdi)
#         retq
# ```

# ############################################################
#
#                     Intrinsics
#
# ############################################################

# Note: GCC before 2017 had incorrect codegen in some cases:
# - https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81300

const
  useIntrinsics = X86 and not stintNoIntrinsics
  useInt128 = GCC_Compatible and sizeof(int) == 8 and not stintNoIntrinsics

const
  newerNim = (NimMajor, NimMinor) > (1, 6)
  noExplicitPtrDeref = defined(cpp) or newerNim

when useIntrinsics:
  when defined(windows):
    {.pragma: intrinsics, header:"<intrin.h>", nodecl.}
  else:
    {.pragma: intrinsics, header:"<x86intrin.h>", nodecl.}

  func addcarry_u32(carryIn: Carry, a, b: uint32, sum: var uint32): Carry {.importc: "_addcarry_u32", intrinsics.}
  func subborrow_u32(borrowIn: Borrow, a, b: uint32, diff: var uint32): Borrow {.importc: "_subborrow_u32", intrinsics.}

  func addcarry_u64(carryIn: Carry, a, b: uint64, sum: var uint64): Carry {.importc: "_addcarry_u64", intrinsics.}
  func subborrow_u64(borrowIn: Borrow, a, b:uint64, diff: var uint64): Borrow {.importc: "_subborrow_u64", intrinsics.}

# ############################################################
#
#                     Public
#
# ############################################################

func addC*(cOut: var Carry, sum: var uint32, a, b: uint32, cIn: Carry) {.inline.} =
  ## Addition with carry
  ## (CarryOut, Sum) <- a + b + CarryIn
  template native =
    let dblPrec = uint64(cIn) + uint64(a) + uint64(b)
    sum = uint32(dblPrec and uint32.high)
    cOut = Carry(dblPrec shr 32)

  when nimvm:
    native
  else:
    when useIntrinsics:
      cOut = addcarry_u32(cIn, a, b, sum)
    else:
      native

func subB*(bOut: var Borrow, diff: var uint32, a, b: uint32, bIn: Borrow) {.inline.} =
  ## Substraction with borrow
  ## (BorrowOut, Diff) <- a - b - borrowIn
  template native =
    let dblPrec = uint64(a) - uint64(b) - uint64(bIn)
    diff = uint32(dblPrec and uint32.high)
    # On borrow the high word will be 0b1111...1111 and needs to be masked
    bOut = Borrow((dblPrec shr 32) and 1)

  when nimvm:
    native
  else:
    when useIntrinsics:
      bOut = subborrow_u32(bIn, a, b, diff)
    else:
      native

func addC*(cOut: var Carry, sum: var uint64, a, b: uint64, cIn: Carry) {.inline.} =
  ## Addition with carry
  ## (CarryOut, Sum) <- a + b + CarryIn
  when nimvm:
    addC_nim(cOut, sum, a, b, cIn)
  else:
    when useIntrinsics:
      cOut = addcarry_u64(cIn, a, b, sum)
    elif useInt128:
      var dblPrec {.noinit.}: uint128
      {.emit:[dblPrec, " = (unsigned __int128)", a," + (unsigned __int128)", b, " + (unsigned __int128)",cIn,";"].}

      # Don't forget to dereference the var param in C mode
      when noExplicitPtrDeref:
        {.emit:[cOut, " = (NU64)(", dblPrec," >> ", 64'u64, ");"].}
        {.emit:[sum, " = (NU64)", dblPrec,";"].}
      else:
        {.emit:["*",cOut, " = (NU64)(", dblPrec," >> ", 64'u64, ");"].}
        {.emit:["*",sum, " = (NU64)", dblPrec,";"].}
    else:
      addC_nim(cOut, sum, a, b, cIn)

func subB*(bOut: var Borrow, diff: var uint64, a, b: uint64, bIn: Borrow) {.inline.} =
  ## Substraction with borrow
  ## (BorrowOut, Diff) <- a - b - borrowIn
  when nimvm:
    subB_nim(bOut, diff, a, b, bIn)
  else:
    when useIntrinsics:
      bOut = subborrow_u64(bIn, a, b, diff)
    elif useInt128:
      var dblPrec {.noinit.}: uint128
      {.emit:[dblPrec, " = (unsigned __int128)", a," - (unsigned __int128)", b, " - (unsigned __int128)",bIn,";"].}

      # Don't forget to dereference the var param in C mode
      # On borrow the high word will be 0b1111...1111 and needs to be masked
      when noExplicitPtrDeref:
        {.emit:[bOut, " = (NU64)(", dblPrec," >> ", 64'u64, ") & 1;"].}
        {.emit:[diff, " = (NU64)", dblPrec,";"].}
      else:
        {.emit:["*",bOut, " = (NU64)(", dblPrec," >> ", 64'u64, ") & 1;"].}
        {.emit:["*",diff, " = (NU64)", dblPrec,";"].}
    else:
      subB_nim(bOut, diff, a, b, bIn)

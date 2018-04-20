#
#
#            Nim's Runtime Library
#        (c) Copyright 2017 Nim Authors
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## This module implements a series of low level methods for bit manipulation.
## By default, this module use compiler intrinsics to improve performance
## on supported compilers: ``GCC``, ``LLVM_GCC``, ``CLANG``, ``VCC``, ``ICC``.
##
## The module will fallback to pure nim procs incase the backend is not supported.
## You can also use the flag `noIntrinsicsBitOpts` to disable compiler intrinsics.
##
## This module is also compatible with other backends: ``Javascript``, ``Nimscript``
## as well as the ``compiletime VM``.
##
## As a result of using optimized function/intrinsics some functions can return
## undefined results if the input is invalid. You can use the flag `noUndefinedBitOpts`
## to force predictable behaviour for all input, causing a small performance hit.
##
## At this time only `fastLog2`, `firstSetBit, `countLeadingZeroBits`, `countTrailingZeroBits`
## may return undefined and/or platform dependant value if given invalid input.


# Bitops from the standard lib modified for MpInt use.
#   - No undefined behaviour or flag needed
#   - Note that for CountLeadingZero, it returns sizeof(input) * 8
#     instead of 0


const useBuiltins* = not defined(noIntrinsicsBitOpts)
# const noUndefined* = defined(noUndefinedBitOpts)
const useGCC_builtins* = (defined(gcc) or defined(llvm_gcc) or defined(clang)) and useBuiltins
const useICC_builtins* = defined(icc) and useBuiltins
const useVCC_builtins* = defined(vcc) and useBuiltins
const arch64* = sizeof(int) == 8


func fastlog2_nim(x: uint32): int {.inline.} =
  ## Quickly find the log base 2 of a 32-bit or less integer.
  # https://graphics.stanford.edu/%7Eseander/bithacks.html#IntegerLogDeBruijn
  # https://stackoverflow.com/questions/11376288/fast-computing-of-log2-for-64-bit-integers
  const lookup: array[32, uint8] = [0'u8, 9, 1, 10, 13, 21, 2, 29, 11, 14, 16, 18,
    22, 25, 3, 30, 8, 12, 20, 28, 15, 17, 24, 7, 19, 27, 23, 6, 26, 5, 4, 31]
  var v = x.uint32
  v = v or v shr 1 # first round down to one less than a power of 2
  v = v or v shr 2
  v = v or v shr 4
  v = v or v shr 8
  v = v or v shr 16
  result = lookup[uint32(v * 0x07C4ACDD'u32) shr 27].int

func fastlog2_nim(x: uint64): int {.inline.} =
  ## Quickly find the log base 2 of a 64-bit integer.
  # https://graphics.stanford.edu/%7Eseander/bithacks.html#IntegerLogDeBruijn
  # https://stackoverflow.com/questions/11376288/fast-computing-of-log2-for-64-bit-integers
  const lookup: array[64, uint8] = [0'u8, 58, 1, 59, 47, 53, 2, 60, 39, 48, 27, 54,
    33, 42, 3, 61, 51, 37, 40, 49, 18, 28, 20, 55, 30, 34, 11, 43, 14, 22, 4, 62,
    57, 46, 52, 38, 26, 32, 41, 50, 36, 17, 19, 29, 10, 13, 21, 56, 45, 25, 31,
    35, 16, 9, 12, 44, 24, 15, 8, 23, 7, 6, 5, 63]
  var v = x.uint64
  v = v or v shr 1 # first round down to one less than a power of 2
  v = v or v shr 2
  v = v or v shr 4
  v = v or v shr 8
  v = v or v shr 16
  v = v or v shr 32
  result = lookup[(v * 0x03F6EAF2CD271461'u64) shr 58].int


when useGCC_builtins:
  # Returns the number of leading 0-bits in x, starting at the most significant bit position. If x is 0, the result is undefined.
  proc builtin_clz*(x: cuint): cint {.importc: "__builtin_clz", cdecl.}
  proc builtin_clzll*(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}

elif useVCC_builtins:
  # Search the mask data from most significant bit (MSB) to least significant bit (LSB) for a set bit (1).
  proc bitScanReverse*(index: ptr culong, mask: culong): cuchar {.importc: "_BitScanReverse", header: "<intrin.h>", nosideeffect.}
  proc bitScanReverse64*(index: ptr culong, mask: uint64): cuchar {.importc: "_BitScanReverse64", header: "<intrin.h>", nosideeffect.}

  template vcc_scan_impl*(fnc: untyped; v: untyped): int =
    var index: culong
    discard fnc(index.addr, v)
    index.int

elif useICC_builtins:
  # Returns the number of leading 0-bits in x, starting at the most significant bit position. If x is 0, the result is undefined.
  proc bitScanReverse*(p: ptr uint32, b: uint32): cuchar {.importc: "_BitScanReverse", header: "<immintrin.h>", nosideeffect.}
  proc bitScanReverse64*(p: ptr uint32, b: uint64): cuchar {.importc: "_BitScanReverse64", header: "<immintrin.h>", nosideeffect.}

  template icc_scan_impl*(fnc: untyped; v: untyped): int =
    var index: uint32
    discard fnc(index.addr, v)
    index.int

func firstSetBit_nim(x: uint32): int {.inline.} =
  ## Returns the 1-based index of the least significant set bit of x, or if x is zero, returns zero.
  # https://graphics.stanford.edu/%7Eseander/bithacks.html#ZerosOnRightMultLookup
  const lookup: array[32, uint8] = [0'u8, 1, 28, 2, 29, 14, 24, 3, 30, 22, 20, 15,
    25, 17, 4, 8, 31, 27, 13, 23, 21, 19, 16, 7, 26, 12, 18, 6, 11, 5, 10, 9]
  var v = x.uint32
  var k = not v + 1 # get two's complement # cast[uint32](-cast[int32](v))
  result = 1 + lookup[uint32((v and k) * 0x077CB531'u32) shr 27].int

func firstSetBit_nim(x: uint64): int {.inline.} =
  ## Returns the 1-based index of the least significant set bit of x, or if x is zero, returns zero.
  # https://graphics.stanford.edu/%7Eseander/bithacks.html#ZerosOnRightMultLookup
  var v = uint64(x)
  var k = uint32(v and 0xFFFFFFFF'u32)
  if k == 0:
    k = uint32(v shr 32'u32) and 0xFFFFFFFF'u32
    result = 32
  result += firstSetBit_nim(k)

func firstSetBit(x: SomeInteger): int {.inline.} =
  ## Returns the 1-based index of the least significant set bit of x.
  ## If `x` is zero, when ``noUndefinedBitOpts`` is set, result is 0,
  ## otherwise result is undefined.
  # GCC builtin 'builtin_ffs' already handle zero input.
  when nimvm:
    # when noUndefined:
    if x == 0:
      return 0
    when sizeof(x) <= 4: result = firstSetBit_nim(x.uint32)
    else:                result = firstSetBit_nim(x.uint64)
  else:
    when not useGCC_builtins: # when noUndefined:
      if x == 0:
        return 0
    when useGCC_builtins:
      when sizeof(x) <= 4: result = builtin_ffs(cast[cint](x.cuint)).int
      else:                result = builtin_ffsll(cast[clonglong](x.culonglong)).int
    elif useVCC_builtins:
      when sizeof(x) <= 4:
        result = 1 + vcc_scan_impl(bitScanForward, x.culong)
      elif arch64:
        result = 1 + vcc_scan_impl(bitScanForward64, x.uint64)
      else:
        result = firstSetBit_nim(x.uint64)
    elif useICC_builtins:
      when sizeof(x) <= 4:
        result = 1 + icc_scan_impl(bitScanForward, x.uint32)
      elif arch64:
        result = 1 + icc_scan_impl(bitScanForward64, x.uint64)
      else:
        result = firstSetBit_nim(x.uint64)
    else:
      when sizeof(x) <= 4: result = firstSetBit_nim(x.uint32)
      else:                result = firstSetBit_nim(x.uint64)


func countLeadingZeroBits*(x: SomeInteger): int {.inline.} =
  ## Returns the number of leading zero bits in integer.
  ## If `x` is zero, when ``noUndefinedBitOpts`` is set, result is 0,
  ## otherwise result is undefined.

  # when noUndefined:
  if x == 0:
    return sizeof(x) * 8 # Note this differes from the stdlib which returns 0

  when nimvm:
      when sizeof(x) <= 4: result = sizeof(x)*8 - 1 - fastlog2_nim(x.uint32)
      else:                result = sizeof(x)*8 - 1 - fastlog2_nim(x.uint64)
  else:
    when useGCC_builtins:
      when sizeof(x) <= 4: result = builtin_clz(x.uint32).int - (32 - sizeof(x)*8)
      else:                result = builtin_clzll(x.uint64).int
    else:
      when sizeof(x) <= 4: result = sizeof(x)*8 - 1 - fastlog2_nim(x.uint32)
      else: result = sizeof(x)*8 - 1 - fastlog2_nim(x.uint64)



func countTrailingZeroBits*(x: SomeInteger): int {.inline.} =
  ## Returns the number of trailing zeros in integer.
  ## If `x` is zero, when ``noUndefinedBitOpts`` is set, result is 0,
  ## otherwise result is undefined.

  # when noUndefined:
  if x == 0:
    return 0

  when nimvm:
    result = firstSetBit(x) - 1
  else:
    when useGCC_builtins:
      when sizeof(x) <= 4: result = builtin_ctz(x.uint32).int
      else:                result = builtin_ctzll(x.uint64).int
    else:
      result = firstSetBit(x) - 1

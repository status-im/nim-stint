# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

# TODO: test if GCC/Clang support uint128 natively

# #### Overview
#
# Stint extends the default uint8, uint16, uint32, uint64 with power of 2 integers.
# Only limitation is your stack size so you can have uint128, uint256, uint512 ...
# Signed int are also possible.
#
# As a high-level API, Stint adheres to Nim and C conventions and uses the same operators like:
# `+`, `xor`, `not` ...
#
# #### Implementation
#
# Stint types are stored on the stack and have a structure
# similar to a binary tree of power of two unsigned integers
# with "high" and "low" words:
#
#                              Stuint[256]
#            hi: Stuint[128]                  lo: Stuint[128]
#     hihi: uint64    hilo: uint64    lohi: uint64    lolo: uint64
#
# This follows paper https://hal.archives-ouvertes.fr/hal-00582593v2
# "Recursive double-size fixed precision arithmetic" from Jul. 2016
# to implement an efficient fixed precision bigint for embedded devices, especially FPGAs.
#
# For testing purpose, the flag `-d:stint_test` can be passed at compile-time
# to switch the backend to uint32.
# In the future the default backend will become uint128 on supporting compilers.
#
# This has following benefits:
#   - BigEndian/LittleEndian support is trivial.
#   - Not having for loops help the compiler producing the most efficient instructions
#     like ADC (Add with Carry)
#   - Proving that the recursive structure works at depth 64 for uint32 backend means that
#     it would work at depth 128 for uint64 backend.
#     We can easily choose a uint16 or uint8 backend as well.
#   - Due to the recursive structure, testing operations when there is:
#       - no leaves(uint64)
#       - a root and leaves with no nodes (uint128)
#       - a root + intermediate nodes + leaves (uint256)
#     should be enough to ensure they work at all sizes, edge cases included.
#   - Adding a new backend like uint128 (GCC/Clang) or uint256 (LLVM instrinsics only) is just adding
#     a new case in the `uintImpl` template.
#   - All math implementations of the operations have a straightforward translation
#     to a high-low structure, including the fastest Karatsuba multiplication
#     and co-recursive division algorithm by Burnikel and Ziegler.
#     This makes translating those algorithms into Nim easier compared to an array backend.
#     It would also probably require less code and would be much easier to audit versus
#     the math reference papers.
#   - For implementation of algorithms, there is no issue to take subslices of the memory representation
#     with a recursive tree structure.
#     On the other side, returning a `var array[N div 2, uint64]` is problematic at the moment.
#   - Compile-time computation is possible while due to the previous issue
#     an array backend would be required to use var openArray[uint64]
#     i.e. pointers.
#   - Note that while shift-right and left can easily be done an array of bytes
#     this would have reduced performance compared to moving 64-bit words.
#     An efficient implementation on array of words would require checking the shift
#     versus a half-word to deal with carry-in/out from and to the adjacent words
#     similar to a recursive implementation.
#
# Iterations over the whole integers, for example for `==` is always unrolled.
# Due to being on the stack, any optimizing compiler should compile that to efficient memcmp
#
# When not to use Stint:
#
# 1. Constant-time arithmetics
#    - Do not use Stint if you need side-channels resistance,
#      This requires to avoid all branches (i.e. no booleans)
# 2. Arbitrary-precision with lots of small-values
#    - If you need arbitrary precision but most of the time you store mall values
#      you will waste a lot of memory unless you use an object variant of various Stint sizes.
#      type MyUint = object
#        case kind: int
#        of 0..64: uint64
#        of 66..128: ref Stuint[128]
#        of 129..256: ref Stuint[256]
#        ...
#
# Note: if you work with huge size, you can allocate stints on the heap with
#       for example `type HeapInt8192 = ref Stint[8192].
#       If you have a lot of computations and intermediate variables it's probably worthwhile
#       to explore creating an object pool to reuse the memory buffers.

template checkDiv2(bits: static[int]): untyped =
  # TODO: There is no need to check if power of 2 at each uintImpl instantiation, it slows compilation.
  #       However we easily get into nested templates instantiation if we use another
  #       template that first checks power-of-two and then calls the recursive uintImpl
  static:
    doAssert (bits and (bits-1)) == 0, $bits & " is not a power of 2"
    doAssert bits >= 8, "The number of bits in a should be greater or equal to 8"
  bits div 2

when defined(mpint_test): # TODO stint_test
  template uintImpl*(bits: static[int]): untyped =
    # Test version, StUint[64] = 2 uint32. Test the logic of the library

    when bits >= 128: UintImpl[uintImpl(checkDiv2(bits))]
    elif bits == 64: UintImpl[uint32]
    elif bits == 32: UintImpl[uint16]
    elif bits == 16: UintImpl[uint8]
    else: {.fatal: "Only power-of-2 >=16 supported when testing" .}

  template intImpl*(bits: static[int]): untyped =
    # Test version, StInt[64] = 2 uint32. Test the logic of the library
    # int is implemented using a signed hi part and an unsigned lo part, given
    # that the sign resides in hi

    when bits >= 128: IntImpl[intImpl(checkDiv2(bits)), uintImpl(checkDiv2(bits))]
    elif bits == 64: IntImpl[int32, uint32]
    elif bits == 32: IntImpl[int16, uint16]
    elif bits == 16: IntImpl[int8, uint8]
    else: {.fatal: "Only power-of-2 >=16 supported when testing" .}

else:
  template uintImpl*(bits: static[int]): untyped =
    mixin UintImpl
    when bits >= 128: UintImpl[uintImpl(checkDiv2(bits))]
    elif bits == 64: uint64
    elif bits == 32: uint32
    elif bits == 16: uint16
    elif bits == 8: uint8
    else: {.fatal: "Only power-of-2 >=8 supported" .}

  template intImpl*(bits: static[int]): untyped =
    # int is implemented using a signed hi part and an unsigned lo part, given
    # that the sign resides in hi

    when bits >= 128: IntImpl[intImpl(checkDiv2(bits)), uintImpl(checkDiv2(bits))]
    elif bits == 64: int64
    elif bits == 32: int32
    elif bits == 16: int16
    elif bits == 8: int8
    else: {.fatal: "Only power-of-2 >=8 supported" .}

type
  # ### Private ### #
  UintImpl*[BaseUint] = object
    when system.cpuEndian == littleEndian:
      lo*, hi*: BaseUint
    else:
      hi*, lo*: BaseUint

  IntImpl*[BaseInt, BaseUint] = object
    # Ints are implemented in terms of uints
    when system.cpuEndian == littleEndian:
      lo*: BaseUint
      hi*: BaseInt
    else:
      hi*: BaseInt
      lo*: BaseUint

  # ### Private ### #

  StUint*[bits: static[int]] = object
    data*: uintImpl(bits)

  StInt*[bits: static[int]] = object
    data*: intImpl(bits)

template applyHiLo*(a: UintImpl | IntImpl, c: untyped): untyped =
  ## Apply `c` to each of `hi` and `lo`
  var res: type a
  res.hi = c(a.hi)
  res.lo = c(a.lo)
  res

template applyHiLo*(a, b: UintImpl | IntImpl, c: untyped): untyped =
  ## Apply `c` to each of `hi` and `lo`
  var res: type a
  res.hi = c(a.hi, b.hi)
  res.lo = c(a.lo, b.lo)
  res

template leastSignificantWord*(num: SomeInteger): auto =
  num

func leastSignificantWord*(num: UintImpl | IntImpl): auto {.inline.} =
  when num.lo is UintImpl:
    num.lo.leastSignificantWord
  else:
    num.lo

func mostSignificantWord*(num: UintImpl | IntImpl): auto {.inline.} =
  when num.hi is (UintImpl | IntImpl):
    num.hi.mostSignificantWord
  else:
    num.hi

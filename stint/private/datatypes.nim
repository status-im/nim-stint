# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

# TODO: test if GCC/Clang support uint128 natively

import macros
# The macro uintImpl must be exported

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
#     a new case in the `uintImpl` macro.
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
#     an array backend would be required to use var openarray[uint64]
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

when not defined(stint_test):
  macro uintImpl*(bits: static[int]): untyped =
    # Release version, word size is uint64 (even on 32-bit arch).
    assert (bits and (bits-1)) == 0, $bits & " is not a power of 2"
    assert bits >= 8, "The number of bits in a should be greater or equal to 8"

    if bits >= 128:
      let inner = getAST(uintImpl(bits div 2))
      result = newTree(nnkBracketExpr, ident("UintImpl"), inner)
    elif bits == 64:
      result = ident("uint64")
    elif bits == 32:
      result = ident("uint32")
    elif bits == 16:
      result = ident("uint16")
    elif bits == 8:
      result = ident("uint8")
    else:
      error "Fatal: unreachable"

  macro intImpl*(bits: static[int]): untyped =
    # Release version, word size is uint64 (even on 32-bit arch).
    # Note that int of size 128+ are implemented in terms of unsigned ints
    # Signed operations are built on top of that.

    if bits >= 128:
      let inner = getAST(uintImpl(bits div 2))
      result = newTree(nnkBracketExpr, ident("IntImpl"), inner)
    elif bits == 64:
      result = ident("int64")
    elif bits == 32:
      result = ident("int32")
    elif bits == 16:
      result = ident("int16")
    elif bits == 8:
      result = ident("int8")
    else:
      error "Fatal: unreachable"
else:
  macro uintImpl*(bits: static[int]): untyped =
    # Test version, word size is uint32. Test the logic of the library.
    assert (bits and (bits-1)) == 0, $bits & " is not a power of 2"
    assert bits >= 16, "The number of bits in a should be greater or equal to 16"

    if bits >= 128:
      let inner = getAST(uintImpl(bits div 2))
      result = newTree(nnkBracketExpr, ident("UintImpl"), inner)
    elif bits == 64:
      result = newTree(nnkBracketExpr, ident("UintImpl"), ident("uint32"))
    elif bits == 32:
      result = newTree(nnkBracketExpr, ident("UintImpl"), ident("uint16"))
    elif bits == 16:
      result = newTree(nnkBracketExpr, ident("UintImpl"), ident("uint8"))
    else:
      error "Fatal: unreachable"

  macro intImpl*(bits: static[int]): untyped =
    # Test version, word size is uint32. Test the logic of the library.
    # Note that ints are implemented in terms of unsigned ints
    # Signed operations will be built on top of that.
    assert (bits and (bits-1)) == 0, $bits & " is not a power of 2"
    assert bits >= 16, "The number of bits in a should be greater or equal to 16"

    if bits >= 128:
      let inner = getAST(uintImpl(bits div 2)) # IntImpl is built on top of UintImpl
      result = newTree(nnkBracketExpr, ident("IntImpl"), inner)
    elif bits == 64:
      result = newTree(nnkBracketExpr, ident("IntImpl"), ident("uint32"))
    elif bits == 32:
      result = newTree(nnkBracketExpr, ident("IntImpl"), ident("uint16"))
    elif bits == 16:
      result = newTree(nnkBracketExpr, ident("IntImpl"), ident("uint8"))
    else:
      error "Fatal: unreachable"

proc getSize*(x: NimNode): static[int] =
  # Default Nim's `sizeof` doesn't always work at compile-time, pending PR https://github.com/nim-lang/Nim/pull/5664
  var multiplier = 1
  var node = x.getTypeInst

  while node.kind == nnkBracketExpr:
    assert eqIdent(node[0], "UintImpl") or eqIdent(node[0], "IntImpl"), (
      "getSize only supports primitive integers, Stint and Stuint")
    multiplier *= 2
    node = node[1]

  # node[1] has the type
  # size(node[1]) * multiplier is the size in byte

  # For optimization we cast to the biggest possible uint
  result =  if eqIdent(node, "uint64") or eqIdent(node, "int64"): multiplier * 64
            elif eqIdent(node, "uint32") or eqIdent(node, "int32"): multiplier * 32
            elif eqIdent(node, "uint16") or eqIdent(node, "int16"): multiplier * 16
            elif eqIdent(node, "uint8") or eqIdent(node, "int8"): multiplier * 8
            elif eqIdent(node, "int") or eqIdent(node, "uint"):
              multiplier * 8 * sizeof(int)
            else:
              assert false, "Error when computing the size. Found: " & $node
              0

macro getSize*(x: typed): untyped =
  let size = getSize(x)
  result = quote do:
    `size`

type
  # ### Private ### #
  BaseUint* = UintImpl or SomeUnsignedInt

  UintImpl*[Baseuint] = object
    when system.cpuEndian == littleEndian:
      lo*, hi*: BaseUint
    else:
      hi*, lo*: BaseUint

  IntImpl*[Baseuint] = object
    # Ints are implemented in terms of uints
    when system.cpuEndian == littleEndian:
      lo*, hi*: BaseUint
    else:
      hi*, lo*: BaseUint
  # ### Private ### #

  StUint*[bits: static[int]] = object
    data*: uintImpl(bits)

  StInt*[bits: static[int]] = object
    data*: intImpl(bits)

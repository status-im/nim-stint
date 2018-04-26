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

when defined(mpint_test):
  macro uintImpl*(bits: static[int]): untyped =
    # Test version, StUint[64] = 2 uint32. Test the logic of the library
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
    # Test version, StInt[64] = 2 uint32. Test the logic of the library
    # Note that ints are implemented in terms of unsigned ints
    # Signed operatiosn will be built on top of that.
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

else:
  macro uintImpl*(bits: static[int]): untyped =
    # Release version, StUint[64] = uint64.
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
    # Release version, StInt[64] = int64.
    # Note that int of size 128+ are implemented in terms of unsigned ints
    # Signed operations will be built on top of that.

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

proc getSize*(x: NimNode): static[int] =

  # Size of doesn't always work at compile-time, pending PR https://github.com/nim-lang/Nim/pull/5664

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

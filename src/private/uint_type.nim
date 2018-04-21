# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

# TODO: test if GCC/Clang support uint128 natively

import macros


# The macro getMpUintImpl must be exported

when defined(mpint_test):
  macro getMpUintImpl*(bits: static[int]): untyped =
    # Test version, mpuint[64] = 2 uint32. Test the logic of the library
    assert (bits and (bits-1)) == 0, $bits & " is not a power of 2"
    assert bits >= 16, "The number of bits in a should be greater or equal to 16"

    if bits >= 128:
      let inner = getAST(getMpUintImpl(bits div 2))
      result = newTree(nnkBracketExpr, ident("MpUintImpl"), inner)
    elif bits == 64:
      result = newTree(nnkBracketExpr, ident("MpUintImpl"), ident("uint32"))
    elif bits == 32:
      result = newTree(nnkBracketExpr, ident("MpUintImpl"), ident("uint16"))
    elif bits == 16:
      result = newTree(nnkBracketExpr, ident("MpUintImpl"), ident("uint8"))
    else:
      error "Fatal: unreachable"
else:
  macro getMpUintImpl*(bits: static[int]): untyped =
    # Release version, mpuint[64] = uint64.
    assert (bits and (bits-1)) == 0, $bits & " is not a power of 2"
    assert bits >= 8, "The number of bits in a should be greater or equal to 8"

    if bits >= 128:
      let inner = getAST(getMpUintImpl(bits div 2))
      result = newTree(nnkBracketExpr, ident("MpUintImpl"), inner)
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

proc getSize*(x: NimNode): static[int] =

  # Size of doesn't always work at compile-time, pending PR https://github.com/nim-lang/Nim/pull/5664
  echo "getSize"
  echo x.getTypeInst.treerepr

  var multiplier = 1
  var node = x.getTypeInst

  while node.kind == nnkBracketExpr:
    assert eqIdent(node[0], "MpuintImpl")
    multiplier *= 2
    node = node[1]

  # node[1] has the type
  # size(node[1]) * multiplier is the size in byte

  # For optimization we cast to the biggest possible uint
  result =  if eqIdent(node, "uint64"): multiplier * 64
            elif eqIdent(node, "uint32"): multiplier * 32
            elif eqIdent(node, "uint16"): multiplier * 16
            elif  eqIdent(node, "uint8"): multiplier * 8
            else:
              assert false, "Error when computing the size. Found: " & $node
              0

macro getSize*(x: typed): untyped =
  let size = getSize(x)
  result = quote do:
    `size`

type
  # ### Private ### #
  # If this is not in the same type section
  # the compiler has trouble
  BaseUint* = MpUintImpl or SomeUnsignedInt

  MpUintImpl*[Baseuint] = object
    when system.cpuEndian == littleEndian:
      lo*, hi*: BaseUint
    else:
      hi*, lo*: BaseUint
  # ### Private ### #

  MpUint*[bits: static[int]] = object
    data*: getMpUintImpl(bits)
    # wrapped in object to avoid recursive calls

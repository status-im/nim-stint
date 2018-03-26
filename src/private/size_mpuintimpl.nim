# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./uint_type, macros


proc size_mpuintimpl*(x: NimNode): static[int] =

  # Size of doesn't always work at compile-time, pending PR https://github.com/nim-lang/Nim/pull/5664

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
            else: multiplier * 8

macro size_mpuintimpl*(x: typed): untyped =
  let size = size_mpuintimpl(x)
  result = quote do:
    `size`

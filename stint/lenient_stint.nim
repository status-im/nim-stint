# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

## This file provide optional syntactic sugar to work with operations on mixed precision integers (for example uint256 + uint)

import ./int_public, ./uint_public, macros

# TODO: deprecate

type Signedness = enum
  BothSigned, IntOnly, UintOnly

macro make_mixed_types_ops(op: untyped, ResultTy: untyped, sign: static[Signedness], switchInputs: static[bool]): untyped =
  # ResultTy must be "InputType" or a real type like bool

  let isInputType = eqIdent(ResultTy, "InputType")
  result = newStmtList()

  if sign != IntOnly:
    let ResultTy =  if not isInputType: ResultTy
                    else: nnkBracketExpr.newTree(
                      newIdentNode("StUint"),
                      newIdentNode("bits")
                    )

    result.add quote do:
      proc `op`*[bits: static[int]](a: Stuint[bits], b: SomeInteger): `ResultTy` {.inline.}=
        `op`(a, b.stuint(bits))

    if switchInputs:
      result.add quote do:
        proc `op`*[bits: static[int]](a: SomeInteger, b: Stuint[bits]): `ResultTy` {.inline.}=
          `op`(a.stuint(bits), b)

  if sign != UintOnly:
    let ResultTy =  if not isInputType: ResultTy
                    else: nnkBracketExpr.newTree(
                      newIdentNode("StInt"),
                      newIdentNode("bits")
                    )

    result.add quote do:
      proc `op`*[bits: static[int]](a: Stint[bits], b: SomeInteger): `ResultTy` {.inline.}=
        `op`(a, b.stint(bits))

    if switchInputs:
      result.add quote do:
        proc `op`*[bits: static[int]](a: SomeInteger, b: Stint[bits]): `ResultTy` {.inline.}=
          `op`(a.stint(bits), b)

make_mixed_types_ops(`+`, InputType, BothSigned, switchInputs = true)
make_mixed_types_ops(`+=`, InputType, BothSigned, switchInputs = false)
make_mixed_types_ops(`-`, InputType, BothSigned, switchInputs = true)
make_mixed_types_ops(`-=`, InputType, BothSigned, switchInputs = false)
make_mixed_types_ops(`*`, InputType, BothSigned, switchInputs = true)
make_mixed_types_ops(`div`, InputType, BothSigned, switchInputs = false)
make_mixed_types_ops(`mod`, InputType, BothSigned, switchInputs = false)
make_mixed_types_ops(divmod, InputType, BothSigned, switchInputs = false)

make_mixed_types_ops(`<`, bool, BothSigned, switchInputs = true)
make_mixed_types_ops(`<=`, bool, BothSigned, switchInputs = true)
make_mixed_types_ops(`==`, bool, BothSigned, switchInputs = true)

make_mixed_types_ops(`or`, InputType, BothSigned, switchInputs = true)
make_mixed_types_ops(`and`, InputType, BothSigned, switchInputs = true)
make_mixed_types_ops(`xor`, InputType, BothSigned, switchInputs = true)

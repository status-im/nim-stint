# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

## This file provides syntactic sugar to work with literals

import ./intops, macros

type Signedness = enum
  BothSigned, IntOnly, UintOnly

macro make_mixed_types_ops(op: untyped, ResultTy: untyped, sign: static[Signedness], switchInputs: static[bool]): untyped =
  # ResultTy must be "InputType" or a real type like bool

  let isInputType = eqIdent(ResultTy, "InputType")
  result = newStmtList()

  # Workaround for int{lit} in quote do block
  let intLit = nnkCurlyExpr.newTree(
    newIdentNode("int"),
    newIdentNode("lit")
  )

  if sign != IntOnly:
    let ResultTy =  if not isInputType: ResultTy
                    else: nnkBracketExpr.newTree(
                      newIdentNode("StUint"),
                      newIdentNode("bits")
                    )

    result.add quote do:
      proc `op`*[bits: static[int]](a: Stuint[bits], b: `intLit`): `ResultTy` {.inline.}=
        `op`(a, b.stuint(bits))

    if switchInputs:
      result.add quote do:
        proc `op`*[bits: static[int]](a: `intLit`, b: Stuint[bits]): `ResultTy` {.inline.}=
          `op`(a.stuint(bits), b)

  if sign != UintOnly:
    let ResultTy =  if not isInputType: ResultTy
                    else: nnkBracketExpr.newTree(
                      newIdentNode("StInt"),
                      newIdentNode("bits")
                    )

    result.add quote do:
      proc `op`*[bits: static[int]](a: Stint[bits], b: `intLit`): `ResultTy` {.inline.}=
        `op`(a, b.stuint(bits))

    if switchInputs:
      result.add quote do:
        proc `op`*[bits: static[int]](a: `intLit`, b: Stint[bits]): `ResultTy` {.inline.}=
          `op`(a.stuint(bits), b)

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

# Specialization / fast path for comparison to zero
# Note system.nim has templates to transform > and >= into <= and <
template mtoIsZero*{a == 0}(a: StUint or Stint): bool = a.isZero
template mtoIsZero*{0 == a}(a: StUint or Stint): bool = a.isZero

template mtoIsNeg*{a < 0}(a: Stint): bool = a.isNegative
template mtoIsNegOrZero*{a <= 0}(a: Stint): bool = a.isZero or a.isNegative

template mtoIsPos*{0 < a}(a: Stint): bool = not(a.isZero or a.isNegative)
template mtoIsPosOrZero*{0 <= a}(a: Stint): bool = not a.isNegative

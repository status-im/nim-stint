# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./datatypes, ./int_negabs, ./uint_div, ./int_comparison, ./compiletime_helpers

# Here are the expected signs for division/modulo by opposite signs and both negative numbers
#   in EVM
#       Parity: https://github.com/paritytech/parity/blob/684322cd6f210684b890055c43d56bb1bc8cae15/ethcore/evm/src/interpreter/mod.rs#L729-L756
#         - SDIV is sign(a) xor sign(b)
#         - SMOD is sign(a)
#       Go-Ethereum: https://github.com/ethereum/go-ethereum/blob/ba1030b6b84f810c04a82221a1b1c0a3dbf499a8/core/vm/instructions.go#L76-L104
#         - SDIV is "if same sign, div(abs(a), abs(b)), else -div(abs(a), abs(b))
#         - SMOD is "sign(a)"
#
#   in Nim
#       echo "10 div 3: " & $(10 div 3) # 3
#       echo "10 mod 3: " & $(10 mod 3) # 1
#       echo '\n'
#       echo "10 div -3: " & $(10 div -3) # -3
#       echo "10 mod -3: " & $(10 mod -3) # 1
#       echo '\n'
#       echo "-10 div 3: " & $(-10 div 3) # -3
#       echo "-10 mod 3: " & $(-10 mod 3) # -1
#       echo '\n'
#       echo "-10 div -3: " & $(-10 div -3) # 3
#       echo "-10 mod -3: " & $(-10 mod -3) # -1
#       echo '\n'

func divmod*(x, y: SomeSignedInt): tuple[quot, rem: SomeSignedInt] {.inline.}=
  # hopefully the compiler fuse that in a single op
  (x div y, x mod y)

proc divmod*[T, T2](x, y: IntImpl[T, T2]): tuple[quot, rem: IntImpl[T, T2]] =
  ## Divmod operation for multi-precision signed integer

  when nimvm:
    let res = divmod(
      convert[UintImpl[T2]](x.abs),
      convert[UintImpl[T2]](y.abs))
    result.quot = convert[type result.quot](res.quot)
    result.rem  = convert[type result.rem](res.rem)
  else:
    result = cast[type result](divmod(
      cast[UintImpl[T2]](x.abs),
      cast[UintImpl[T2]](y.abs)
      ))

  if (x.isNegative xor y.isNegative):
    # If opposite signs
    result.quot = -result.quot
  if x.isNegative:
    result.rem = -result.rem

func `div`*(x, y: IntImpl): IntImpl {.inline.} =
  ## Division operation for multi-precision signed integer
  divmod(x,y).quot

func `mod`*(x, y: IntImpl): IntImpl {.inline.} =
  ## Division operation for multi-precision signed integer
  divmod(x,y).rem

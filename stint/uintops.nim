# Stint
# Copyright 2018-2020 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Status lib
  stew/bitops2,
  # Internal
  ./private/datatypes,
  ./private/primitives/addcarry_subborrow

export StUint

# Initialization
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func setZero*(a: var StUint) =
  ## Set ``a`` to 0
  zeroMem(a[0].addr, sizeof(a))

func setOne*(a: var StUint) =
  ## Set ``a`` to 1
  when cpuEndian == littleEndian:
    a.limbs[0] = 1
    when a.limbs.len > 1:
      zeroMem(a.limbs[1].addr, (a.limbs.len - 1) * sizeof(SecretWord))
  else:
    a.limbs[^1] = 1
    when a.limbs.len > 1:
      zeroMem(a.limbs[0].addr, (a.len - 1) * sizeof(SecretWord))

func zero*[bits: static[int]](T: typedesc[Stuint[bits]]): T {.inline.} =
  ## Returns the zero of the input type
  discard

func one*[bits: static[int]](T: typedesc[Stuint[bits]]): T {.inline.} =
  ## Returns the one of the input type
  result.limbs.setOne()

func high*[bits](_: typedesc[Stuint[bits]]): Stuint[bits] {.inline.} =
  for wr in leastToMostSig(result):
    wr = high(Word)
func low*[bits](_: typedesc[Stuint[bits]]): Stuint[bits] {.inline.} =
  discard

{.pop.}
# Comparisons
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func isZero*(a: Stuint): bool =
  for word in leastToMostSig(a):
    if word != 0:
      return false
  return true

func `==`*(a, b: Stuint): bool {.inline.} =
  ## Unsigned `equal` comparison
  for wa, wb in leastToMostSig(a, b):
    if wa != wb:
      return false
  return true

func `<`*(a, b: Stuint): bool {.inline.} =
  ## Unsigned `less than` comparison
  var diff: Word
  var borrow: Borrow
  for wa, wb in leastToMostSig(a, b):
    subB(borrow, diff, wa, wb, borrow)
  return bool(borrow)

func `<=`*(a, b: Stuint): bool {.inline.} =
  ## Unsigned `less or equal` comparison
  not(a < b)

func isOdd*(a: Stuint): bool {.inline.} =
  ## Returns true if input is off
  ## false otherwise
  bool(a.leastSignificantWord and 1)

func isEven*(a: Stuint): bool {.inline.} =
  ## Returns true if input is zero
  ## false otherwise
  not a.isOdd

{.pop.}
# Bitwise operations
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func `not`*(a: Stuint): Stuint =
  ## Bitwise complement of unsigned integer a
  ## i.e. flips all bits of the input
  for wr, wa in leastToMostSig(result, a):
    wr = not wa

func `or`*(a, b: Stuint): Stuint =
  ## `Bitwise or` of numbers a and b
  for wr, wa, wb in leastToMostSig(result, a, b):
    wr = wa or wb

func `and`*(a, b: Stuint): Stuint =
  ## `Bitwise and` of numbers a and b
  for wr, wa, wb in leastToMostSig(result, a, b):
    wr = wa and wb

func `xor`*(a, b: Stuint): Stuint =
  ## `Bitwise xor` of numbers x and y
  for wr, wa, wb in leastToMostSig(result, a, b):
    wr = wa xor wb

func `shr`*(a: Stuint, k: SomeInteger): Stuint =
  ## Shift right by k.
  ##
  ## k MUST be less than the base word size (2^32 or 2^64)
  # Note: for speed, loading a[i] and a[i+1]
  #       instead of a[i-1] and a[i]
  #       is probably easier to parallelize for the compiler
  #       (antidependence WAR vs loop-carried dependence RAW)
  when cpuEndian == littleEndian:
    for i in 0 ..< a.limbs.len-1:
      result.limbs[i] = (a.limbs[i] shr k) or (a.limbs[i+1] shl (WordBitWidth - k))
    result.limbs[^1] = a.limbs[^1] shr k
  else:
    for i in countdown(a.limbs.len-1, 1):
      result.limbs[i] = (a.limbs[i] shr k) or (a.limbs[i-1] shl (WordBitWidth - k))
    result.limbs[0] = a.limbs[0] shr k

func `shl`*(a: Stuint, k: SomeInteger): Stuint =
  ## Compute the `shift left` operation of x and k
  when cpuEndian == littleEndian:
    result.limbs[0] = a.limbs[0] shl k
    for i in 1 ..< a.limbs.len:
      result.limbs[i] = (a.limbs[i] shl k) or (a.limbs[i-1] shr (WordBitWidth - k))
  else:
    result.limbs[^1] = a.limbs[^1] shl k
    for i in countdown(a.limbs.len-2, 0):
      result.limbs[i] = (a.limbs[i] shl k) or (a.limbs[i+1] shr (WordBitWidth - k))

func countOnes*(x: Stuint): int {.inline.} =
  result = 0
  for wx in leastToMostSig(x):
    result += countOnes(wx)

func parity*(x: Stuint): int {.inline.} =
  result = parity(x.limbs[0])
  for i in 1 ..< x.limbs.len:
    result = result xor parity(x.limbs[i])

func leadingZeros*(x: Stuint): int {.inline.} =
  result = 0
  for word in mostToLeastSig(x):
    let zeroCount = word.leadingZeros()
    result += zeroCount
    if zeroCount != WordBitWidth:
      return

func trailingZeros*(x: Stuint): int {.inline.} =
  result = 0
  for word in leastToMostSig(x):
    let zeroCount = word.leadingZeros()
    result += zeroCount
    if zeroCount != WordBitWidth:
      return

func firstOne*(x: Stuint): int {.inline.} =
  result = trailingZeros(x)
  if result == x.limbs.len * WordBitWidth:
    result = 0
  else:
    result += 1

{.pop.}
# Addsub
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func `+`*(a, b: Stuint): Stuint =
  # Addition for multi-precision unsigned int
  var carry = Carry(0)
  for wr, wa, wb in leastToMostSig(result, a, b):
    addC(carry, wr, wa, wb, carry)

func `+=`*(a: var Stuint, b: Stuint) =
  ## In-place addition for multi-precision unsigned int
  var carry = Carry(0)
  for wa, wb in leastToMostSig(a, b):
    addC(carry, wa, wa, wb, carry)

func `-`*(a, b: Stuint): Stuint =
  # Substraction for multi-precision unsigned int
  var borrow = Borrow(0)
  for wr, wa, wb in leastToMostSig(result, a, b):
    subB(borrow, wr, wa, wb, borrow)

func `-=`*(a: var Stuint, b: Stuint) =
  ## In-place substraction for multi-precision unsigned int
  var borrow = Borrow(0)
  for wa, wb in leastToMostSig(a, b):
    subB(borrow, wa, wa, wb, borrow)

func inc*(a: var Stuint, w: Word = 1) =
  var carry = Carry(0)
  when cpuEndian == littleEndian:
    addC(carry, x.limbs[0], x.limbs[0], w, carry)
    for i in 1 ..< x.len:
      addC(carry, x.limbs[i], x.limbs[i], 0, carry)

{.pop.}
# Multiplication
# --------------------------------------------------------
import ./private/uint_mul
{.push raises: [], inline, noInit, gcsafe.}

func `*`*(a, b: Stuint): Stuint {.inline.} =
  ## Integer multiplication
  result.limbs.prod(a.limbs, b.limbs)

{.pop.}
# Division & Modulo
# --------------------------------------------------------

# Exponentiation
# --------------------------------------------------------

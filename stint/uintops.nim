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
  ./private/uint_shift,
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
  not(b < a)

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

template clearExtraBits(a: var StUint) =
  ## A Stuint is stored in an array of 32 of 64-bit word
  ## If we do bit manipulation at the word level,
  ## for example a 8-bit stuint stored in a 64-bit word
  ## we need to clear the upper 56-bit
  when a.bits != a.limbs.len * WordBitWidth:
    const posExtraBits = a.bits - (a.limbs.len-1) * WordBitWidth
    const mask = (Word(1) shl posExtraBits) - 1
    mostSignificantWord(a) = mostSignificantWord(a) and mask

func `not`*(a: Stuint): Stuint =
  ## Bitwise complement of unsigned integer a
  ## i.e. flips all bits of the input
  for wr, wa in leastToMostSig(result, a):
    wr = not wa
  result.clearExtraBits()

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
  result.clearExtraBits()

func countOnes*(a: Stuint): int =
  result = 0
  for wa in leastToMostSig(a):
    result += countOnes(wa)

func parity*(a: Stuint): int =
  result = parity(a.limbs[0])
  for i in 1 ..< a.limbs.len:
    result = result xor parity(a.limbs[i])

func leadingZeros*(a: Stuint): int =
  result = 0

  # Adjust when we use only part of the word size
  var extraBits = WordBitWidth * a.limbs.len - a.bits

  for word in mostToLeastSig(a):
    let zeroCount = word.leadingZeros()
    if extraBits > 0:
      result += zeroCount - min(extraBits, WordBitWidth)
      extraBits -= WordBitWidth
    else:
      result += zeroCount
    if zeroCount != WordBitWidth:
      break

func trailingZeros*(a: Stuint): int =
  result = 0
  for word in leastToMostSig(a):
    let zeroCount = word.trailingZeros()
    result += zeroCount
    if zeroCount != WordBitWidth:
      break

  when a.limbs.len * WordBitWidth != a.bits:
    if result > a.bits:
      result = a.bits

func firstOne*(a: Stuint): int =
  result = trailingZeros(a)
  if result == a.limbs.len * WordBitWidth:
    result = 0
  else:
    result += 1

{.pop.} # End noInit
{.push raises: [], inline, gcsafe.}

func `shr`*(a: Stuint, k: SomeInteger): Stuint =
  ## Shift right by k bits
  if k < WordBitWidth:
    result.limbs.shrSmall(a.limbs, k)
    return

  # w = k div WordBitWidth, shift = k mod WordBitWidth
  let w     = k shr static(log2trunc(uint32(WordBitWidth)))
  let shift = k and (WordBitWidth - 1)

  if shift == 0:
    result.limbs.shrWords(a.limbs, w)
  else:
    result.limbs.shrLarge(a.limbs, w, shift)

func `shl`*(a: Stuint, k: SomeInteger): Stuint =
  ## Shift left by k bits
  if k < WordBitWidth:
    result.limbs.shlSmall(a.limbs, k)
    result.clearExtraBits()
    return

  # w = k div WordBitWidth, shift = k mod WordBitWidth
  let w     = k shr static(log2trunc(uint32(WordBitWidth)))
  let shift = k and (WordBitWidth - 1)

  if shift == 0:
    result.limbs.shlWords(a.limbs, w)
  else:
    result.limbs.shlLarge(a.limbs, w, shift)

  result.clearExtraBits()

{.pop.}

# Addsub
# --------------------------------------------------------
{.push raises: [], inline, noInit, gcsafe.}

func `+`*(a, b: Stuint): Stuint =
  ## Addition for multi-precision unsigned int
  var carry = Carry(0)
  for wr, wa, wb in leastToMostSig(result, a, b):
    addC(carry, wr, wa, wb, carry)
  result.clearExtraBits()

func `+=`*(a: var Stuint, b: Stuint) =
  ## In-place addition for multi-precision unsigned int
  var carry = Carry(0)
  for wa, wb in leastToMostSig(a, b):
    addC(carry, wa, wa, wb, carry)
  a.clearExtraBits()

func `-`*(a, b: Stuint): Stuint =
  ## Substraction for multi-precision unsigned int
  var borrow = Borrow(0)
  for wr, wa, wb in leastToMostSig(result, a, b):
    subB(borrow, wr, wa, wb, borrow)
  result.clearExtraBits()

func `-=`*(a: var Stuint, b: Stuint) =
  ## In-place substraction for multi-precision unsigned int
  var borrow = Borrow(0)
  for wa, wb in leastToMostSig(a, b):
    subB(borrow, wa, wa, wb, borrow)
  a.clearExtraBits()

func inc*(a: var Stuint, w: Word = 1) =
  var carry = Carry(0)
  when cpuEndian == littleEndian:
    addC(carry, a.limbs[0], a.limbs[0], w, carry)
    for i in 1 ..< a.limbs.len:
      addC(carry, a.limbs[i], a.limbs[i], 0, carry)
  a.clearExtraBits()

func `+`*(a: Stuint, b: SomeUnsignedInt): Stuint =
  ## Addition for multi-precision unsigned int
  ## with an unsigned integer
  result = a
  result.inc(Word(b))

func `+=`*(a: var Stuint, b: SomeUnsignedInt) =
  ## In-place addition for multi-precision unsigned int
  ## with an unsigned integer
  a.inc(Word(b))

{.pop.}
# Multiplication
# --------------------------------------------------------
# Multiplication is implemented in a separate file at the limb-level
# - It's too big to be inlined (especially with unrolled loops)
# - It's implemented at the limb-level so that
#   in the future Stuint[254] and Stuint256] share a common codepath

import ./private/uint_mul
{.push raises: [], inline, noInit, gcsafe.}

func `*`*(a, b: Stuint): Stuint =
  ## Integer multiplication
  result.limbs.prod(a.limbs, b.limbs)
  result.clearExtraBits()

{.pop.}
# Division & Modulo
# --------------------------------------------------------

# Exponentiation
# --------------------------------------------------------

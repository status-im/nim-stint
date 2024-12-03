# Stint
# Copyright 2018-2023 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  # Standard library
  std/[typetraits, algorithm, hashes],
  # Internal
  stew/staticfor,
  ./private/datatypes,
  ./uintops, ./endians2

export endians2

from stew/byteutils import toHex

# Helpers
# --------------------------------------------------------
{.push raises: [], gcsafe.}

template leastSignificantWord*(a: SomeBigInteger): Word =
  mixin limbs
  a.limbs[0]

template mostSignificantWord*(a: SomeBigInteger): Word =
  mixin limbs
  a.limbs[^1]

template signedWordType*(_: type SomeBigInteger): type =
  SignedWord

template wordType*(_: type SomeBigInteger): type =
  Word

template hash*(num: StUint|StInt): Hash =
  mixin hash, limbs
  hash(num.limbs)

func swap*(a, b: var (StUint|StInt)) =
  staticFor i, 0..<a.len:
    swap(a.limbs[i], b.limbs[i])

{.pop.}

# Constructors
# --------------------------------------------------------
{.push raises: [], inline, gcsafe.}

func stuint*[T: SomeInteger](n: T, bits: static[int]): StUint[bits] {.inline.}=
  ## Converts an integer to an arbitrary precision integer.
  when sizeof(n) > sizeof(Word):
    result.limbs[0] = Word(n and Word.high.T)
    result.limbs[1] = Word(n shr WordBitWidth)
  else:
    result.limbs[0] = Word(n)

func stint*[T: SomeInteger](n: T, bits: static[int]): StInt[bits] {.inline.}=
  ## Converts an integer to an arbitrary precision signed integer.
  when T is SomeUnsignedInt:
    result.impl = stuint(n, bits)
  else:
    if n < 0:
      if n == low(T):
        # special case, bug #92 workaround
        result.impl = stuint(high(T), bits) + stuint(1, bits)
      else:
        result.impl = stuint(-n, bits)
      result.negate
    else:
      result.impl = stuint(n, bits)

func to*(a: SomeInteger, T: typedesc[StInt]): T =
  stint(a, result.bits)

func to*(a: SomeUnsignedInt, T: typedesc[StUint]): T =
  stuint(a, result.bits)

{.pop.}

# Conversions
# --------------------------------------------------------
{.push raises: [], gcsafe.}

func truncate*(num: StUint, T: typedesc[SomeInteger]): T {.inline.}=
  ## Extract the int, uint, int8-int64 or uint8-uint64 portion of a multi-precision integer.
  ## Note that int and uint are 32-bit on 32-bit platform.
  ## For unsigned result type, result is modulo 2^(sizeof T in bit)
  ## For signed result type, result is undefined if input does not fit in the target type.
  when T is SomeSignedInt and sizeof(T) <= sizeof(Word):
    result = T(num.leastSignificantWord() and Word(T.high))
  else:
    result = T(num.leastSignificantWord())
  when sizeof(T) > sizeof(Word):
    result = result or (T(num.limbs[1]) shl WordBitWidth)

func truncate*(num: StInt, T: typedesc[SomeInteger]): T {.inline.}=
  ## Extract the int, uint, int8-int64 or uint8-uint64 portion of a multi-precision integer.
  ## Note that int and uint are 32-bit on 32-bit platform.
  ## For unsigned result type, result is modulo 2^(sizeof T in bit)
  ## For signed result type, result is undefined if input does not fit in the target type.
  let n = num.abs
  when sizeof(T) > sizeof(Word):
    result = T(n.leastSignificantWord())
  else:
    result = T(n.leastSignificantWord() and Word(T.high))

  if num.isNegative:
    when T is SomeUnsignedInt:
      raise newException(OverflowDefect, "cannot truncate negative number to unsigned integer")
    elif sizeof(T) <= sizeof(Word):
      if n.leastSignificantWord() == Word(T.high) + 1:
        result = low(T)
      else:
        result = -result
    else:
      if n == stint(T.high, num.bits) + 1'u:
        result = low(T)
      else:
        #result = result or (T(num.limbs[1]) shl WordBitWidth)
        result = -result
  else:
    when sizeof(T) > sizeof(Word):
      result = result or (T(num.limbs[1]) shl WordBitWidth)

func stuint*(a: StUint, bits: static[int]): StUint[bits] {.inline.} =
  ## unsigned int to unsigned int conversion
  ## smaller to bigger bits conversion will have the same value
  ## bigger to smaller bits conversion, the result is truncated
  when bits <= a.bits:
    for i in 0 ..< result.len:
      result[i] = a[i]
  else:
    for i in 0 ..< a.len:
      result[i] = a[i]

func stuint*(a: StInt, bits: static[int]): StUint[bits] {.inline.} =
  ## signed int to unsigned int conversion
  ## bigger to smaller bits conversion, the result is truncated
  if a.isNegative:
    raise newException(OverflowDefect, "Cannot convert negative number to unsigned int")
  stuint(a.impl, bits)

func smallToBig(a: StInt, bits: static[int]): StInt[bits] =
  if a.isNegative:
    result.impl = stuint(a.neg.impl, bits)
    result.negate
  else:
    result.impl = stuint(a.impl, bits)

func stint*(a: StInt, bits: static[int]): StInt[bits] =
  ## signed int to signed int conversion
  ## will raise exception if input does not fit into destination
  when a.bits < bits:
    if a.isNegative:
      result.impl = stuint(a.neg.impl, bits)
      result.negate
    else:
      result.impl = stuint(a, bits)
  elif a.bits > bits:
    template checkNegativeRange() =
      const dmin = smallToBig((type result).low, a.bits)
      if a < dmin: raise newException(RangeDefect, "value out of range")

    template checkPositiveRange() =
      const dmax = smallToBig((type result).high, a.bits)
      if a > dmax: raise newException(RangeDefect, "value out of range")

    if a.isNegative:
      checkNegativeRange()
      result.impl = stuint(a.neg.impl, bits)
      result.negate
    else:
      checkPositiveRange()
      result.impl = stuint(a, bits)
  else:
    result = a

func stint*(a: StUint, bits: static[int]): StInt[bits] {.inline.} =
  ## signed int to unsigned int conversion
  ## will raise exception if input does not fit into destination

  const dmax = stuint((type result).high, a.bits)
  if a > dmax: raise newException(RangeDefect, "value out of range")
  result.impl = stuint(a, bits)

{.pop.}

# Serializations to/from string
# --------------------------------------------------------
{.push gcsafe.}

func readHexChar(c: char): int8 {.inline.}=
  ## Converts an hex char to an int
  case c
  of '0'..'9': result = int8 ord(c) - ord('0')
  of 'a'..'f': result = int8 ord(c) - ord('a') + 10
  of 'A'..'F': result = int8 ord(c) - ord('A') + 10
  else:
    raise newException(ValueError,
                       "[" & $c & "] is not a hexadecimal character")

func skipPrefixes(current_idx: var int, str: string, radix: range[2..16]) {.inline.} =
  ## Returns the index of the first meaningful char in `hexStr` by skipping
  ## "0x" prefix

  if str.len < 2:
    return

  doAssert current_idx == 0, "skipPrefixes only works for prefixes (position 0 and 1 of the string)"
  if str[0] == '0':
    if str[1] in {'x', 'X'}:
      doAssert radix == 16, "Parsing mismatch, 0x prefix is only valid for a hexadecimal number (base 16)"
      current_idx = 2
    elif str[1] in {'o', 'O'}:
      doAssert radix == 8, "Parsing mismatch, 0o prefix is only valid for an octal number (base 8)"
      current_idx = 2
    elif str[1] in {'b', 'B'}:
      if radix == 2:
        current_idx = 2
      elif radix == 16:
        # allow something like "0bcdef12345" which is a valid hex
        current_idx = 0
      else:
        doAssert false, "Parsing mismatch, 0b prefix is only valid for a binary number (base 2), or hex number"

func nextNonBlank(current_idx: var int, s: string) {.inline.} =
  ## Move the current index, skipping white spaces and "_" characters.

  const blanks = {' ', '_'}

  inc current_idx
  while current_idx < s.len and s[current_idx] in blanks:
    inc current_idx

func readDecChar(c: char): int8 {.inline.}=
  ## Converts a decimal char to an int
  # specialization without branching for base <= 10.
  case c
  of '0'..'9':
    int8(ord(c) - ord('0'))
  else:
    raise newException(ValueError, "[" & $c & "] is not a decimal character")

func parse*[bits: static[int]](input: string,
                               T: typedesc[StUint[bits]],
                               radix: static[uint8] = 10): T =
  ## Parse a string and store the result in a Stint[bits] or StUint[bits].

  static: doAssert (radix >= 2) and radix <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  # TODO: we can special case hex result/input as an array of bytes
  #       and be much faster

  const base = radix.uint8.stuint(bits)
  var curr = 0 # Current index in the string
  skipPrefixes(curr, input, radix)

  while curr < input.len:
    # TODO: overflow detection
    when radix <= 10:
      result = result * base + input[curr].readDecChar.stuint(bits)
    else:
      result = result * base + input[curr].readHexChar.stuint(bits)
    nextNonBlank(curr, input)

func parse*[bits: static[int]](input: string,
                               T: typedesc[StInt[bits]],
                               radix: static[uint8] = 10): T =
  ## Parse a string and store the result in a Stint[bits] or StUint[bits].

  static: doAssert (radix >= 2) and radix <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)
  # TODO: we can special case hex result/input as an array of bytes
  #       and be much faster

  # For conversion we require overflowing operations (for example for negative hex numbers)
  const base = radix.int8.stuint(bits)

  var
    curr = 0 # Current index in the string
    isNeg = false
    noOverflow: StUint[bits]

  if input[curr] == '-':
    doAssert radix == 10, "Negative numbers are only supported with base 10 input."
    isNeg = true
    inc curr
  else:
    skipPrefixes(curr, input, radix)

  while curr < input.len:
    # TODO: overflow detection
    when radix <= 10:
      noOverflow = noOverflow * base + input[curr].readDecChar.stuint(bits)
    else:
      noOverflow = noOverflow * base + input[curr].readHexChar.stuint(bits)
    nextNonBlank(curr, input)

  result.impl = noOverflow
  if isNeg:
    result.negate

func fromHex*(T: typedesc[StUint|StInt], s: string): T {.inline.} =
  ## Convert an hex string to the corresponding unsigned integer
  parse(s, type result, radix = 16)

func fromDecimal*(T: typedesc[StUint|StInt], s: string): T {.inline.} =
  parse(s, type result, radix = 10)

func hexToUint*[bits: static[int]](hexString: string): StUint[bits] {.inline.} =
  ## Convert an hex string to the corresponding unsigned integer
  parse(hexString, type result, radix = 16)

func toString*[bits: static[int]](num: StUint[bits], radix: static[uint8] = 10): string =
  ## Convert a Stint or StUint to string.
  ## In case of negative numbers:
  ##   - they are prefixed with "-" for base 10.
  ##   - if not base 10, they are returned raw in two-complement form.

  static: doAssert (radix >= 2) and radix <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  const hexChars = "0123456789abcdef"
  const base = radix.uint8.stuint(bits)

  result = ""
  var (q, r) = divmod(num, base)

  while true:
    when bits <= 64:
      result.add hexChars[r.leastSignificantWord()]
    else:
      result.add hexChars[r.truncate(int)]
    if q.isZero:
      break
    (q, r) = divmod(q, base)

  reverse(result)

func toString*[bits: static[int]](num: StInt[bits], radix: static[uint8] = 10): string =
  ## Convert a Stint or StUint to string.
  ## In case of negative numbers:
  ##   - they are prefixed with "-" for base 10.
  ##   - if not base 10, they are returned raw in two-complement form.
  let isNeg = num.isNegative
  if radix == 10 and isNeg:
    "-" & toString(num.neg.impl, radix)
  else:
    toString(num.impl, radix)

func `$`*(num: StInt or StUint): string {.inline.}=
  toString(num, 10)

func toHex*[bits: static[int]](num: StInt[bits] or StUint[bits]): string {.inline.}=
  ## Convert to a hex string.
  ## Output is considered a big-endian base 16 string.
  ## Leading zeros are stripped. Use dumpHex instead if you need the in-memory representation
  toString(num, 16)

func dumpHex*(a: StInt or StUint, order: static[Endianness] = bigEndian): string =
  ## Stringify an int to hex.
  ## Note. Leading zeros are not removed. Use toString(n, base = 16)/toHex instead.
  ##
  ## You can specify bigEndian or littleEndian order.
  ## i.e. in bigEndian:
  ## - 1.uint64 will be 00000001
  ## - (2.uint128)^64 + 1 will be 0000000100000001
  ##
  ## in littleEndian:
  ## - 1.uint64 will be 01000000
  ## - (2.uint128)^64 + 1 will be 0100000001000000
  let bytes = a.toBytes(order)
  result = bytes.toHex()

{.pop.}

# Serializations to/from bytes
# --------------------------------------------------------
{.push raises: [], inline, noinit, gcsafe.}

export fromBytes, toBytes, fromBytesLE, toBytesLE, fromBytesBE, toBytesBE

func readUintBE*[bits: static[int]](ba: openArray[byte]): StUint[bits] {.noinit, inline.}=
  ## Convert a big-endian array of (bits div 8) Bytes to an UInt[bits] (in native host endianness)
  ## Input:
  ##   - a big-endian openArray of size (bits div 8) at least
  ## Returns:
  ##   - A unsigned integer of the same size with `bits` bits
  (typeof result).fromBytesBE(ba)

template initFromBytesBE*(x: var StUint, ba: openArray[byte]) =
  x = endians2.fromBytesBE(type x, ba)

func readUintLE*[bits: static[int]](ba: openArray[byte]): StUint[bits] {.noinit, inline.}=
  ## Convert a lettle-endian array of (bits div 8) Bytes to an UInt[bits] (in native host endianness)
  ## Input:
  ##   - a little-endian openArray of size (bits div 8) at least
  ## Returns:
  ##   - A unsigned integer of the same size with `bits` bits
  result = (typeof result).fromBytesLE(ba)

template toByteArrayLE*[bits: static[int]](n: StUint[bits]): array[bits div 8, byte] {.deprecated: "endians2.toBytesLE".} =
  ## Convert a Uint[bits] to to a little-endian array of bits div 8 bytes
  ## Input:
  ##   - an unsigned integer
  ## Returns:
  ##   - a little-endian array of the same size
  n.toBytesLE()

template initFromBytesLE*(x: var StUint, ba: openArray[byte]) =
  x = fromBytesLE(type x, ba)

#---------------Byte Serialization of Signed Integer ---------------------------

func readIntBE*[bits: static[int]](ba: openArray[byte]): StInt[bits] {.noinit, inline.}=
  ## Convert a big-endian array of (bits div 8) Bytes to an Int[bits] (in native host endianness)
  ## Input:
  ##   - a big-endian openArray of size (bits div 8) at least
  ## Returns:
  ##   - A signed integer of the same size with `bits` bits
  result.impl = (typeof result.impl).fromBytesBE(ba)

template initFromBytesBE*(x: var StInt, ba: openArray[byte]) =
  x = fromBytesBE(type x, ba)

func readIntLE*[bits: static[int]](ba: openArray[byte]): StInt[bits] {.noinit, inline.}=
  ## Convert a lettle-endian array of (bits div 8) Bytes to an Int[bits] (in native host endianness)
  ## Input:
  ##   - a little-endian openArray of size (bits div 8) at least
  ## Returns:
  ##   - A signed integer of the same size with `bits` bits
  result.impl = (typeof result.impl).fromBytesLE(ba)

template toByteArrayLE*[bits: static[int]](n: StInt[bits]): array[bits div 8, byte] {.deprecated: "endians2.toBytesLE".} =
  ## Convert a Int[bits] to to a little-endian array of bits div 8 bytes
  ## Input:
  ##   - an signed integer
  ## Returns:
  ##   - a little-endian array of the same size
  result = n.impl.toBytesLE()

template initFromBytesLE*(x: var StInt, ba: openArray[byte]) =
  x = fromBytesLE(type x, ba)

{.pop.}

include
  ./private/custom_literal

func customLiteral*(T: type SomeBigInteger, s: static string): T =
  when s.len == 0:
    doAssert(false, "customLiteral cannot accept param with zero length")

  const radix = getRadix(s)
  type TT = T
  when isOverflow(TT, s, radix):
    {.error: "Stint custom literal overlow detected" .}

  parse(s, T, radix)

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
  ./private/datatypes,
  ./uintops, ./endians2

from stew/byteutils import toHex

template leastSignificantWord*(a: SomeBigInteger): Word =
  a.limbs[0]

template mostSignificantWord*(a: SomeBigInteger): Word =
  a.limbs[^1]

template signedWordType*(_: type SomeBigInteger): type =
  SignedWord

template wordType*(_: type SomeBigInteger): type =
  Word

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
    result.imp = stuint(n, bits)
  else:
    if n < 0:
      if n == low(T):
        # special case, bug #92 workaround
        result.imp = stuint(high(T), bits) + stuint(1, bits)
      else:
        result.imp = stuint(-n, bits)
      result.negate
    else:
      result.imp = stuint(n, bits)

func to*(a: SomeInteger, T: typedesc[StInt]): T =
  stint(a, result.bits)

func to*(a: SomeUnsignedInt, T: typedesc[StUint]): T =
  stuint(a, result.bits)

func truncate*(num: StInt or StUint, T: typedesc[SomeInteger]): T {.inline.}=
  ## Extract the int, uint, int8-int64 or uint8-uint64 portion of a multi-precision integer.
  ## Note that int and uint are 32-bit on 32-bit platform.
  ## For unsigned result type, result is modulo 2^(sizeof T in bit)
  ## For signed result type, result is undefined if input does not fit in the target type.
  result = T(num.leastSignificantWord())

func stuint*(a: StUint, bits: static[int]): StUint[bits] {.inline.} =
  ## unsigned int to unsigned int conversion
  ## smaller to bigger bits conversion will have the same value
  ## bigger to smaller bits conversion, the result is truncated
  for i in 0 ..< result.len:
    result[i] = a[i]

# func StUint*(a: StInt, bits: static[int]): StUint[bits] {.inline.} =
#   ## signed int to unsigned int conversion
#   ## current behavior is cast-like, copying bit pattern
#   ## or truncating if input does not fit into destination
#   const N = bitsof(x.data)
#   when N < bits:
#     when N <= 64:
#       type T = StUint[N]
#       result = StUint(convert[T](a).data, bits)
#     else:
#       smallToBig(result.data, a.data)
#   elif N > bits:
#     when bits <= 64:
#       result = StUint(x.truncate(type(result.data)), bits)
#     else:
#       bigToSmall(result.data, a.data)
#   else:
#     result = convert[type(result)](a)

# func stint*(a: StInt, bits: static[int]): StInt[bits] {.inline.} =
#   ## signed int to signed int conversion
#   ## will raise exception if input does not fit into destination
#   const N = bitsof(a.data)
#   when N < bits:
#     when N <= 64:
#       result = stint(a.data, bits)
#     else:
#       if a.isNegative:
#         smallToBig(result.data, (-a).data)
#         result = -result
#       else:
#         smallToBig(result.data, a.data)
#   elif N > bits:
#     template checkNegativeRange() =
#       # due to bug #92, we skip negative range check
#       when false:
#         const dmin = stint((type result).low, N)
#         if a < dmin: raise newException(RangeError, "value out of range")

#     template checkPositiveRange() =
#       const dmax = stint((type result).high, N)
#       if a > dmax: raise newException(RangeError, "value out of range")

#     when bits <= 64:
#       if a.isNegative:
#         checkNegativeRange()
#         result = stint((-a).truncate(type(result.data)), bits)
#         result = -result
#       else:
#         checkPositiveRange()
#         result = stint(a.truncate(type(result.data)), bits)
#     else:
#       if a.isNegative:
#         checkNegativeRange()
#         bigToSmall(result.data, (-a).data)
#         result = -result
#       else:
#         checkPositiveRange()
#         bigToSmall(result.data, a.data)
#   else:
#     result = a

# func stint*(a: StUint, bits: static[int]): StInt[bits] {.inline.} =
#   const N = bitsof(a.data)
#   const dmax = StUint((type result).high, N)
#   if a > dmax: raise newException(RangeError, "value out of range")
#   when N < bits:
#     when N <= 64:
#       result = stint(a.data, bits)
#     else:
#       smallToBig(result.data, a.data)
#   elif N > bits:
#     when bits <= 64:
#       result = stint(a.truncate(type(result.data)), bits)
#     else:
#       bigToSmall(result.data, a.data)
#   else:
#     result = convert[type(result)](a)

func readHexChar(c: char): int8 {.inline.}=
  ## Converts an hex char to an int
  case c
  of '0'..'9': result = int8 ord(c) - ord('0')
  of 'a'..'f': result = int8 ord(c) - ord('a') + 10
  of 'A'..'F': result = int8 ord(c) - ord('A') + 10
  else:
    raise newException(ValueError, $c & "is not a hexadecimal character")

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
      doAssert radix == 2, "Parsing mismatch, 0b prefix is only valid for a binary number (base 2)"
      current_idx = 2

func nextNonBlank(current_idx: var int, s: string) {.inline.} =
  ## Move the current index, skipping white spaces and "_" characters.

  const blanks = {' ', '_'}

  inc current_idx
  while current_idx < s.len and s[current_idx] in blanks:
    inc current_idx

func readDecChar(c: range['0'..'9']): int {.inline.}=
  ## Converts a decimal char to an int
  # specialization without branching for base <= 10.
  ord(c) - ord('0')

func parse*[bits: static[int]](input: string, T: typedesc[StUint[bits]], radix: static[uint8] = 10): T =
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

func parse*[bits: static[int]](input: string, T: typedesc[StInt[bits]], radix: static[int8] = 10): T =
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

  result.imp = noOverflow
  if isNeg:
    result.negate

func fromHex*(T: typedesc[StUint|StInt], s: string): T {.inline.} =
  ## Convert an hex string to the corresponding unsigned integer
  parse(s, type result, radix = 16)

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

func toString*[bits: static[int]](num: StInt[bits], radix: static[int8] = 10): string =
  ## Convert a Stint or StUint to string.
  ## In case of negative numbers:
  ##   - they are prefixed with "-" for base 10.
  ##   - if not base 10, they are returned raw in two-complement form.
  let isNeg = num.isNegative
  if radix == 10 and isNeg:
    "-" & toString(num.neg.imp, radix)
  else:
    toString(num.imp, radix)

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

export fromBytes, toBytes

func readUintBE*[bits: static[int]](ba: openArray[byte]): StUint[bits] {.noinit, inline.}=
  ## Convert a big-endian array of (bits div 8) Bytes to an UInt[bits] (in native host endianness)
  ## Input:
  ##   - a big-endian openArray of size (bits div 8) at least
  ## Returns:
  ##   - A unsigned integer of the same size with `bits` bits
  result = (typeof result).fromBytesBE(ba)

func toByteArrayBE*[bits: static[int]](n: StUint[bits]): array[bits div 8, byte] {.noinit, inline.}=
  ## Convert a uint[bits] to to a big-endian array of bits div 8 bytes
  ## Input:
  ##   - an unsigned integer
  ## Returns:
  ##   - a big-endian array of the same size
  result = n.toBytesBE()

template hash*(num: StUint|StInt): Hash =
  # TODO:
  # `hashData` is not particularly efficient.
  # Explore better hashing solutions in nim-stew.
  hashData(unsafeAddr num, sizeof num)

func fromBytesBE*(T: type StUint, ba: openArray[byte], allowPadding: static[bool] = true): T {.noinit, inline.}=
  result = readUintBE[T.bits](ba)
  when allowPadding:
    result = result shl ((sizeof(T) - ba.len) * 8)

template initFromBytesBE*(x: var StUint, ba: openArray[byte], allowPadding: static[bool] = true) =
  x = fromBytesBE(type x, ba, allowPadding)

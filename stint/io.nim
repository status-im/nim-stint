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
  typetraits, algorithm, hashes,
  # Status libraries
  # stew/byteutils,
  # Internal
  ./private/datatypes,
  # ./private/int_negabs,
  # ./private/compiletime_helpers,
  # ./intops,
  ./uintops, ./endians2

from stew/byteutils import toHex # Why are we exporting readHexChar in byteutils?

template leastSignificantWord*(a: SomeBigInteger): Word =
  a.limbs[0]

template mostSignificantWord*(a: SomeBigInteger): Word =
  a.limbs[^1]

template signedWordType*(_: type SomeBigInteger): type =
  SignedWord

template wordType*(_: type SomeBigInteger): type =
  Word

template static_check_size(T: typedesc[SomeInteger], bits: static[int]) =
  # To avoid a costly runtime check, we refuse storing into StUint types smaller
  # than the input type.

  static: doAssert sizeof(T) * 8 <= bits, "Input type (" & $T &
            ") cannot be stored in a multi-precision " &
            $bits & "-bit integer." &
            "\nUse a smaller input type instead. This is a compile-time check" &
            " to avoid a costly run-time bit_length check at each StUint initialization."

func stuint*[T: SomeInteger](n: T, bits: static[int]): StUint[bits] {.inline.}=
  ## Converts an integer to an arbitrary precision integer.
  result.limbs[0] = Word(n)
  when sizeof(n) > sizeof(Word):
    result.limbs[1] = Word(n) shr WordBitWidth

# func stint*[T: SomeInteger](n: T, bits: static[int]): StInt[bits] {.inline.}=
#   ## Converts an integer to an arbitrary precision signed integer.
#
#   when result.data is IntImpl:
#     static_check_size(T, bits)
#     when T is SomeSignedInt:
#       if n < 0:
#         # TODO: when bits >= 128, cannot create from
#         # low(int8-64)
#         # see: status-im/nim-stint/issues/92
#         assignLo(result.data, -n)
#         result = -result
#       else:
#         assignLo(result.data, n)
#     else:
#       assignLo(result.data, n)
#   else:
#     result.data = (type result.data)(n)

# func to*(a: SomeInteger, T: typedesc[Stint]): T =
#   stint(a, result.bits)

func to*(a: SomeUnsignedInt, T: typedesc[StUint]): T =
  stuint(a, result.bits)

func truncate*(num: Stint or StUint, T: typedesc[SomeInteger]): T {.inline.}=
  ## Extract the int, uint, int8-int64 or uint8-uint64 portion of a multi-precision integer.
  ## Note that int and uint are 32-bit on 32-bit platform.
  ## For unsigned result type, result is modulo 2^(sizeof T in bit)
  ## For signed result type, result is undefined if input does not fit in the target type.
  result = T(num.leastSignificantWord())

func toInt*(num: Stint or StUint): int {.inline, deprecated:"Use num.truncate(int) instead".}=
  num.truncate(int)

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

# func parse*[bits: static[int]](input: string, T: typedesc[Stint[bits]], radix: static[int8] = 10): T =
#   ## Parse a string and store the result in a Stint[bits] or StUint[bits].

#   static: doAssert (radix >= 2) and radix <= 16, "Only base from 2..16 are supported"
#   # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

#   # TODO: we can special case hex result/input as an array of bytes
#   #       and be much faster

#   # For conversion we require overflowing operations (for example for negative hex numbers)
#   const base = radix.int8.StUint(bits)

#   var
#     curr = 0 # Current index in the string
#     isNeg = false
#     no_overflow: StUint[bits]

#   if input[curr] == '-':
#     doAssert radix == 10, "Negative numbers are only supported with base 10 input."
#     isNeg = true
#     inc curr
#   else:
#     skipPrefixes(curr, input, radix)

#   while curr < input.len:
#     # TODO: overflow detection
#     when radix <= 10:
#       no_overflow = no_overflow * base + input[curr].readDecChar.StUint(bits)
#     else:
#       no_overflow = no_overflow * base + input[curr].readHexChar.StUint(bits)
#     nextNonBlank(curr, input)

#   # TODO: we can't create the lowest int this way
#   if isNeg:
#     result = -convert[T](no_overflow)
#   else:
#     result = convert[T](no_overflow)

func fromHex*(T: typedesc[StUint|Stint], s: string): T {.inline.} =
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

# func toString*[bits: static[int]](num: Stint[bits], radix: static[int8] = 10): string =
#   ## Convert a Stint or StUint to string.
#   ## In case of negative numbers:
#   ##   - they are prefixed with "-" for base 10.
#   ##   - if not base 10, they are returned raw in two-complement form.

#   static: doAssert (radix >= 2) and radix <= 16, "Only base from 2..16 are supported"
#   # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

#   const hexChars = "0123456789abcdef"
#   const base = radix.int8.StUint(bits)

#   result = ""

#   type T = StUint[bits]
#   let isNeg = num.isNegative
#   let num = convert[T](if radix == 10 and isNeg: -num
#             else: num)

#   var (q, r) = divmod(num, base)

#   while true:
#     when bitsof(r.data) <= 64:
#       result.add hexChars[r.data.int]
#     else:
#       result.add hexChars[r.truncate(int)]
#     if q.isZero:
#       break
#     (q, r) = divmod(q, base)

#   if isNeg and radix == 10:
#     result.add '-'

#   reverse(result)

# func `$`*(num: Stint or StUint): string {.inline.}=
#   when num.data is SomeInteger:
#     $num.data
#   else:
#     toString(num, 10)

func toHex*[bits: static[int]](num: Stint[bits] or StUint[bits]): string {.inline.}=
  ## Convert to a hex string.
  ## Output is considered a big-endian base 16 string.
  ## Leading zeros are stripped. Use dumpHex instead if you need the in-memory representation
  toString(num, 16)

func dumpHex*(a: Stint or StUint, order: static[Endianness] = bigEndian): string =
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

func readUintBE*[bits: static[int]](ba: openArray[byte]): StUint[bits] {.noInit, inline.}=
  ## Convert a big-endian array of (bits div 8) Bytes to an UInt[bits] (in native host endianness)
  ## Input:
  ##   - a big-endian openArray of size (bits div 8) at least
  ## Returns:
  ##   - A unsigned integer of the same size with `bits` bits
  result = (typeof result).fromBytesBE(ba)

func toByteArrayBE*[bits: static[int]](n: StUint[bits]): array[bits div 8, byte] {.noInit, inline.}=
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

func fromBytesBE*(T: type StUint, ba: openArray[byte], allowPadding: static[bool] = true): T {.noInit, inline.}=
  result = readUintBE[T.bits](ba)
  when allowPadding:
    result = result shl ((sizeof(T) - ba.len) * 8)

template initFromBytesBE*(x: var StUint, ba: openArray[byte], allowPadding: static[bool] = true) =
  x = fromBytesBE(type x, ba, allowPadding)

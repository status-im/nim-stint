# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ./private/datatypes,
  ./private/int_negabs,
  ./private/as_words,
  ./int_public, ./uint_public,
  typetraits, algorithm

template static_check_size(T: typedesc[SomeInteger], bits: static[int]) =
  # To avoid a costly runtime check, we refuse storing into StUint types smaller
  # than the input type.

  static: assert sizeof(T) * 8 <= bits, "Input type (" & $T &
            ") cannot be stored in a multi-precision " &
            $bits & "-bit integer." &
            "\nUse a smaller input type instead. This is a compile-time check" &
            " to avoid a costly run-time bit_length check at each StUint initialization."

template assign_least_significant_words[T: SomeInteger](result: var (Stuint|Stint), n: T) =
  template lsw_result: untyped = least_significant_word(result.data)
  template slsw_result: untyped = second_least_significant_word(result.data)

  const wordSize = lsw_result.getSize
  when sizeof(T) * 8 <= wordSize:
    lsw_result = (type lsw_result)(n)
  else: # We try to store an int64 in 2 x uint32 or 4 x uint16
        # For now we only support assignation from 64 to 2x32 bit
    const
      size = getSize(T)
      halfSize = size div 2
      halfMask = (1.T shl halfSize) - 1.T

    lsw_result = (type lsw_result)(n and halfMask)
    slsw_result = (type slsw_result)(n shr halfSize)

func stuint*[T: SomeInteger](n: T, bits: static[int]): StUint[bits] {.inline.}=
  ## Converts an integer to an arbitrary precision integer.

  assert n >= 0.T
  when result.data is UintImpl:
    static_check_size(T, bits)
    assign_least_significant_words(result, n)
  else:
    result.data = (type result.data)(n)

func stint*[T: SomeInteger](n: T, bits: static[int]): StInt[bits] {.inline.}=
  ## Converts an integer to an arbitrary precision signed integer.

  when result.data is IntImpl:
    static_check_size(T, bits)
    when T is SomeSignedInt:
      if n < 0:
        assign_least_significant_words(result, -n)
        result = -result
      else:
        assign_least_significant_words(result, n)
    else:
      assign_least_significant_words(result, n)
  else:
    result.data = (type result.data)(n)

func to*(x: SomeInteger, T: typedesc[Stint]): T =
  stint(x, result.bits)

func to*(x: SomeUnsignedInt, T: typedesc[StUint]): T =
  stuint(x, result.bits)

func toInt*(num: Stint or StUint): int {.inline.}=
  # Returns as int. Result is modulo 2^(sizeof(int)
  num.data.least_significant_word.int

func readHexChar(c: char): int8 {.inline.}=
  ## Converts an hex char to an int
  case c
  of '0'..'9': result = int8 ord(c) - ord('0')
  of 'a'..'f': result = int8 ord(c) - ord('a') + 10
  of 'A'..'F': result = int8 ord(c) - ord('A') + 10
  else:
    raise newException(ValueError, $c & "is not a hexadecimal character")

func skipPrefixes(current_idx: var int, str: string, base: range[2..16]) {.inline.} =
  ## Returns the index of the first meaningful char in `hexStr` by skipping
  ## "0x" prefix

  assert current_idx == 0, "skipPrefixes only works for prefixes (position 0 and 1 of the string)"
  if str[0] == '0':
    if str[1] in {'x', 'X'}:
      assert base == 16, "Parsing mismatch, 0x prefix is only valid for a hexadecimal number (base 16)"
      current_idx = 2
    elif str[1] in {'o', 'O'}:
      assert base == 8, "Parsing mismatch, 0o prefix is only valid for an octal number (base 8)"
      current_idx = 2
    elif str[1] in {'b', 'B'}:
      assert base == 2, "Parsing mismatch, 0b prefix is only valid for a binary number (base 2)"
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

func parse*[bits: static[int]](input: string, T: typedesc[Stuint[bits]], base: static[uint8]): T =
  ## Parse a string and store the result in a Stint[bits] or Stuint[bits].

  static: assert (base >= 2) and base <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  # TODO: we can special case hex result/input as an array of bytes
  #       and be much faster

  const radix = base.uint8.stuint(bits)
  var curr = 0 # Current index in the string
  skipPrefixes(curr, input, base)

  while curr < input.len:
    # TODO: overflow detection
    when base <= 10:
      result = result * radix + input[curr].readDecChar.stuint(bits)
    else:
      result = result * radix + input[curr].readHexChar.stuint(bits)
    nextNonBlank(curr, input)

func parse*[bits: static[int]](input: string, T: typedesc[Stint[bits]], base: static[int8]): T =
  ## Parse a string and store the result in a Stint[bits] or Stuint[bits].

  static: assert (base >= 2) and base <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  # TODO: we can special case hex result/input as an array of bytes
  #       and be much faster

  # For conversion we require overflowing operations (for example for negative hex numbers)
  const radix = base.int8.stuint(bits)

  var
    curr = 0 # Current index in the string
    isNeg = false
    no_overflow: Stuint[bits]

  if input[curr] == '-':
    assert base == 10, "Negative numbers are only supported with base 10 input."
    isNeg = true
    inc curr
  else:
    skipPrefixes(curr, input, base)

  while curr < input.len:
    # TODO: overflow detection
    when base <= 10:
      no_overflow = no_overflow * radix + input[curr].readDecChar.stuint(bits)
    else:
      no_overflow = no_overflow * radix + input[curr].readHexChar.stuint(bits)
    nextNonBlank(curr, input)

  # TODO: we can't create the lowest int this way
  if isNeg:
    result = -cast[Stint[bits]](no_overflow)
  else:
    result = cast[Stint[bits]](no_overflow)

func parse*[bits: static[int]](input: string, T: typedesc[Stint[bits]|Stuint[bits]]): T {.inline.}=
  ## Parse a string and store the result in a Stint[bits] or Stuint[bits].
  ## Input is considered a decimal string.
  # TODO: Have a default static argument in the previous proc. Currently we get
  #       "Cannot evaluate at compile-time" in several places (2018-04-26).
  parse(input, T, 10)

func fromHex*(T: type StUint, s: string): T {.inline.} =
  ## Convert an hex string to the corresponding unsigned integer
  parse(s, type result, base = 16)

func hexToUint*[bits: static[int]](hexString: string): Stuint[bits] {.inline.} =
  ## Convert an hex string to the corresponding unsigned integer
  parse(hexString, type result, base = 16)

func toString*[bits: static[int]](num: StUint[bits], base: static[uint8]): string =
  ## Convert a Stint or Stuint to string.
  ## In case of negative numbers:
  ##   - they are prefixed with "-" for base 10.
  ##   - if not base 10, they are returned raw in two-complement form.

  static: assert (base >= 2) and base <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  const hexChars = "0123456789abcdef"
  const radix = base.uint8.stuint(bits)

  result = ""
  var (q, r) = divmod(num, radix)

  while true:
    result.add hexChars[r.toInt]
    if q.isZero:
      break
    (q, r) = divmod(q, radix)

  reverse(result)

func toString*[bits: static[int]](num: Stint[bits], base: static[int8]): string =
  ## Convert a Stint or Stuint to string.
  ## In case of negative numbers:
  ##   - they are prefixed with "-" for base 10.
  ##   - if not base 10, they are returned raw in two-complement form.

  static: assert (base >= 2) and base <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  const hexChars = "0123456789abcdef"
  const radix = base.int8.stint(bits)

  result = ""

  let isNeg = num.isNegative
  let num = if base == 10 and isNeg: -num
            else: num

  var (q, r) = divmod(num, radix)

  while true:
    result.add hexChars[r.toInt]
    if q.isZero:
      break
    (q, r) = divmod(q, radix)

  if isNeg:
    result.add '-'

  reverse(result)

func toString*[bits: static[int]](num: Stint[bits] or StUint[bits]): string {.inline.}=
  ## Convert to a string.
  ## Output is considered a decimal string.
  #
  # TODO: Have a default static argument in the previous proc. Currently we get
  #       "Error: type mismatch: got <int, type StInt[128]>, required type static[int]"
  when num.data is SomeInteger:
    $num.data
  else:
    toString(num, 10)

func `$`*(num: Stint or StUint): string {.inline.}=
  when num.data is SomeInteger:
    $num.data
  else:
    toString(num, 10)

func toHex*[bits: static[int]](num: Stint[bits] or StUint[bits]): string {.inline.}=
  ## Convert to a hex string.
  ## Output is considered a big-endian base 16 string.
  ## Leading zeros are stripped. Use dumpHex instead if you need the in-memory representation
  toString(num, 16)

func dumpHex*(x: Stint or StUint, order: static[Endianness]): string =
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

  const
    hexChars = "0123456789abcdef"
    size = getSize(x.data) div 8

  {.pragma: restrict, codegenDecl: "$# __restrict $#".}
  let bytes {.restrict.}= cast[ptr array[size, byte]](x.unsafeaddr)

  result = newString(2*size)

  for i in 0 ..< size:
    when order == system.cpuEndian:
      result[2*i] = hexChars[int bytes[i] shr 4 and 0xF]
      result[2*i+1] = hexChars[int bytes[i] and 0xF]
    else:
      result[2*i] = hexChars[int bytes[bytes[].high - i] shr 4 and 0xF]
      result[2*i+1] = hexChars[int bytes[bytes[].high - i] and 0xF]

func dumpHex*(x: Stint or StUint): string {.inline.}=
  ## Stringify an int to hex.
  ## By default, dump is done in bigEndian order.
  dumpHex(x, bigEndian)
  # TODO: Have a default static argument in the previous proc. Currently we get
  #       "Cannot evaluate at compile-time".

proc initFromBytesBE*[bits: static[int]](val: var Stuint[bits], ba: openarray[byte], allowPadding: static[bool] = true) =
  ## Initializes a UInt[bits] value from a byte buffer storing a big-endian
  ## representation of a number.
  ##
  ## If `allowPadding` is set to false, the input array must be exactly
  ## (bits div 8) bytes long. Otherwise, it may be shorter and the remaining
  ## bytes will be assumed to be zero.

  const N = bits div 8

  when not allowPadding:
    assert(ba.len == N)
  else:
    assert ba.len <= N

  {.pragma: restrict, codegenDecl: "$# __restrict $#".}
  let r_ptr {.restrict.} = cast[ptr array[N, byte]](val.addr)

  when system.cpuEndian == bigEndian:
    # TODO: due to https://github.com/status-im/nim-stint/issues/38
    # We can't cast a stack byte array to stuint with a convenient proc signature.
    when allowPadding:
      let baseIdx = N - val.len
      for i, b in ba: r_ptr[baseIdx + i] = b
    else:
      for i, b in ba: r_ptr[i] = b
  else:
    when allowPadding:
      let baseIdx = ba.len - 1
      for i, b in ba: r_ptr[baseIdx - i] = b
    else:
      for i, b in ba: r_ptr[N-1 - i] = b

func significantBytesBE*(val: openarray[byte]): int =
  ## Returns the number of significant trailing bytes in a big endian
  ## representation of a number.
  for i in 0 ..< val.len:
    if val[i] != 0:
      return val.len - i

  return 1

func fromBytesBE*(T: type Stuint, ba: openarray[byte],
                  allowPadding: static[bool] = true): T =
  ## This function provides a convenience wrapper around `initFromBytesBE`.
  result.initFromBytesBE(ba, allowPadding)

func readUintBE*[bits: static[int]](ba: openarray[byte]): Stuint[bits] =
  ## Convert a big-endian array of (bits div 8) Bytes to an UInt[bits] (in native host endianness)
  ## Input:
  ##   - a big-endian openarray of size (bits div 8) at least
  ## Returns:
  ##   - A unsigned integer of the same size with `bits` bits
  ##
  ## ⚠ If the openarray length is bigger than bits div 8, part converted is undefined behaviour.
  result.initFromBytesBE(ba, false)

func toByteArrayBE*[bits: static[int]](n: StUint[bits]): array[bits div 8, byte] =
  ## Convert a uint[bits] to to a big-endian array of bits div 8 bytes
  ## Input:
  ##   - an unsigned integer
  ## Returns:
  ##   - a big-endian array of the same size

  const N = bits div 8

  when system.cpuEndian == bigEndian:
    result = cast[type result](n)
  else:
    {.pragma: restrict, codegenDecl: "$# __restrict $#".}
    let n_ptr {.restrict.} = cast[ptr array[N, byte]](n.unsafeAddr)
    for i in 0 ..< N:
      result[N-1 - i] = n_ptr[i]

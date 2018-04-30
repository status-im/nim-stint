# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.
{.pragma: fooPragma.}
import
  ./private/datatypes,
  ./private/int_negabs,
  ./private/initialization,
  ./private/[as_words, as_signed_words],
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

func stuint*[T: SomeInteger](n: T, bits: static[int]): StUint[bits] {.inline.}=
  assert n >= 0.T
  when result.data is UintImpl:
    static_check_size(T, bits)

    let r_ptr = cast[ptr array[bits div (sizeof(T) * 8), T]](result.addr)
    when system.cpuEndian == littleEndian:
      # "Least significant byte is at the beginning"
      r_ptr[0] = n
    else:
      r_ptr[r_ptr[].len - 1] = n
  else:
    result.data = (type result.data)(n)

func stint*[T: SomeInteger](n: T, bits: static[int]): StInt[bits] {.inline.}=

  when result.data is IntImpl:
    static_check_size(T, bits)

    let r_ptr = cast[ptr array[bits div (sizeof(T) * 8), T]](result.addr)
    when system.cpuEndian == littleEndian:
      # "Least significant byte is at the beginning"
      if n < 0:
        r_ptr[0] = -n
        result = -result
      else:
        r_ptr[0] = n
    else:
      if n < 0:
        r_ptr[r_ptr[].len - 1] = -n
        result = -result
      else:
        r_ptr[r_ptr[].len - 1] = n
  else:
    result.data = (type result.data)(n)

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
  while s[current_idx] in blanks and current_idx < s.len:
    inc current_idx

func readDecChar(c: range['0'..'9']): int {.inline.}=
  ## Converts a decimal char to an int
  # specialization without branching for base <= 10.
  ord(c) - ord('0')

func unsafeConv[bits: static[int]](n: range[0..16], T: typedesc[Stint[bits]|Stuint[bits]]): T =
  ## Fast convert a small int to a Stint/Stuint
  ## This assumes that the int always fit.
  ## Purpose:
  ##   - Converting bases in the range [2..16]
  ##   - Converting decimal/hexadecimal in range [0..15]

  let r_ptr = cast[ptr array[bits div 8, byte]](result.addr)
  when system.cpuEndian == littleEndian:
    r_ptr[0] = n.byte
  else:
    r_ptr[r_ptr[].len - 1] = n.byte

func parse*[bits: static[int]](T: typedesc[Stuint[bits]], input: string, base: static[int]): T =
  ## Parse a string and store the result in a Stint[bits] or Stuint[bits].

  static: assert (base >= 2) and base <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  # TODO: we can special case hex result/input as an array of bytes
  #       and be much faster

  let radix = unsafeConv(base, T)
  var curr = 0 # Current index in the string
  skipPrefixes(curr, input, base)

  while curr < input.len:
    # TODO: overflow detection
    when base <= 10:
      result = result * radix + input[curr].readDecChar.unsafeConv(T)
    else:
      result = result * radix + input[curr].readHexChar.unsafeConv(T)
    nextNonBlank(curr, input)

func parse*[bits: static[int]](T: typedesc[Stint[bits]], input: string, base: static[int]): T =
  ## Parse a string and store the result in a Stint[bits] or Stuint[bits].

  static: assert (base >= 2) and base <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  # TODO: we can special case hex result/input as an array of bytes
  #       and be much faster

  # For conversion we require overflowing operations (for example for negative hex numbers)
  let radix = unsafeConv(base, Stuint[bits])

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
      no_overflow = no_overflow * radix + input[curr].readDecChar.unsafeConv(Stuint[bits])
    else:
      no_overflow = no_overflow * radix + input[curr].readHexChar.unsafeConv(Stuint[bits])
    nextNonBlank(curr, input)

  # TODO: we can't create the lowest int this way
  if isNeg:
    result = -cast[Stint[bits]](no_overflow)
  else:
    result = cast[Stint[bits]](no_overflow)

func parse*[bits: static[int]](T: typedesc[Stint[bits]|Stuint[bits]], input: string): T {.inline, fooPragma.}=
  ## Parse a string and store the result in a Stint[bits] or Stuint[bits].
  ## Input is considered a decimal string.
  # TODO: Have a default static argument in the previous proc. Currently we get
  #       "Cannot evaluate at compile-time" in several places (2018-04-26).
  parse(T, input, 10)

func toString*[bits: static[int]](num: StUint[bits], base: static[int]): string =
  ## Convert a Stint or Stuint to string.
  ## In case of negative numbers:
  ##   - they are prefixed with "-" for base 10.
  ##   - if not base 10, they are returned raw in two-complement form.

  static: assert (base >= 2) and base <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  const hexChars = "0123456789abcdef"
  let radix = unsafeConv(base, type num)

  result = ""
  var (q, r) = divmod(num, radix)

  while true:
    result.add hexChars[r.toInt]
    if q.isZero:
      break
    (q, r) = divmod(q, radix)

  reverse(result)

func toString*[bits: static[int]](num: Stint[bits], base: static[int]): string =
  ## Convert a Stint or Stuint to string.
  ## In case of negative numbers:
  ##   - they are prefixed with "-" for base 10.
  ##   - if not base 10, they are returned raw in two-complement form.

  static: assert (base >= 2) and base <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  const hexChars = "0123456789abcdef"
  let radix = unsafeConv(base, type num)

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

func toString*[bits: static[int]](num: Stint[bits] or StUint[bits]): string {.inline, fooPragma.}=
  ## Convert to a string.
  ## Output is considered a decimal string.
  #
  # TODO: Have a default static argument in the previous proc. Currently we get
  #       "Error: type mismatch: got <int, type StInt[128]>, required type static[int]"
  toString(num, 10)

func dumpHex*(x: Stint or StUint, order: static[Endianness]): string =
  ## Stringify an int to hex.
  ## Note. Leading 0 are not removed. Use toString(n, base = 16) instead.
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

  {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
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

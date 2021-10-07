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
  ./private/compiletime_helpers,
  ./intops,
  typetraits, algorithm, hashes

template static_check_size(T: typedesc[SomeInteger], bits: static[int]) =
  # To avoid a costly runtime check, we refuse storing into StUint types smaller
  # than the input type.

  static: doAssert sizeof(T) * 8 <= bits, "Input type (" & $T &
            ") cannot be stored in a multi-precision " &
            $bits & "-bit integer." &
            "\nUse a smaller input type instead. This is a compile-time check" &
            " to avoid a costly run-time bit_length check at each StUint initialization."

func assignLo(result: var (UintImpl | IntImpl), n: SomeInteger) {.inline.} =
  when result.lo is UintImpl:
    assignLo(result.lo, n)
  else:
    result.lo = (type result.lo)(n)

func stuint*[T: SomeInteger](n: T, bits: static[int]): StUint[bits] {.inline.}=
  ## Converts an integer to an arbitrary precision integer.

  doAssert n >= 0.T
  when result.data is UintImpl:
    static_check_size(T, bits)
    assignLo(result.data, n)
  else:
    result.data = (type result.data)(n)

func stint*[T: SomeInteger](n: T, bits: static[int]): StInt[bits] {.inline.}=
  ## Converts an integer to an arbitrary precision signed integer.

  when result.data is IntImpl:
    static_check_size(T, bits)
    when T is SomeSignedInt:
      if n < 0:
        # TODO: when bits >= 128, cannot create from
        # low(int8-64)
        # see: status-im/nim-stint/issues/92
        assignLo(result.data, -n)
        result = -result
      else:
        assignLo(result.data, n)
    else:
      assignLo(result.data, n)
  else:
    result.data = (type result.data)(n)

func to*(x: SomeInteger, T: typedesc[Stint]): T =
  stint(x, result.bits)

func to*(x: SomeUnsignedInt, T: typedesc[StUint]): T =
  stuint(x, result.bits)

func truncate*(num: Stint or StUint, T: typedesc[SomeInteger]): T {.inline.}=
  ## Extract the int, uint, int8-int64 or uint8-uint64 portion of a multi-precision integer.
  ## Note that int and uint are 32-bit on 32-bit platform.
  ## For unsigned result type, result is modulo 2^(sizeof T in bit)
  ## For signed result type, result is undefined if input does not fit in the target type.
  static:
    doAssert bitsof(T) <= bitsof(num.data.leastSignificantWord)

  when nimvm:
    let data = num.data.leastSignificantWord
    vmIntCast[T](data)
  else:
    cast[T](num.data.leastSignificantWord)

func toInt*(num: Stint or StUint): int {.inline, deprecated:"Use num.truncate(int) instead".}=
  num.truncate(int)

func bigToSmall(result: var (UintImpl | IntImpl), x: auto) {.inline.} =
  when bitsof(x) == bitsof(result):
    when type(result) is type(x):
      result = x
    else:
      result = convert[type(result)](x)
  else:
    bigToSmall(result, x.lo)

func smallToBig(result: var (UintImpl | IntImpl), x: auto) {.inline.} =
  when bitsof(x) == bitsof(result):
    when type(result) is type(x):
      result = x
    else:
      result = convert[type(result)](x)
  else:
    smallToBig(result.lo, x)

func stuint*(x: StUint, bits: static[int]): StUint[bits] {.inline.} =
  ## unsigned int to unsigned int conversion
  ## smaller to bigger bits conversion will have the same value
  ## bigger to smaller bits conversion, the result is truncated
  const N = bitsof(x.data)
  when N < bits:
    when N <= 64:
      result = stuint(x.data, bits)
    else:
      smallToBig(result.data, x.data)
  elif N > bits:
    when bits <= 64:
      result = stuint(x.truncate(type(result.data)), bits)
    else:
      bigToSmall(result.data, x.data)
  else:
    result = x

func stuint*(x: StInt, bits: static[int]): StUint[bits] {.inline.} =
  ## signed int to unsigned int conversion
  ## current behavior is cast-like, copying bit pattern
  ## or truncating if input does not fit into destination
  const N = bitsof(x.data)
  when N < bits:
    when N <= 64:
      type T = StUint[N]
      result = stuint(convert[T](x).data, bits)
    else:
      smallToBig(result.data, x.data)
  elif N > bits:
    when bits <= 64:
      result = stuint(x.truncate(type(result.data)), bits)
    else:
      bigToSmall(result.data, x.data)
  else:
    result = convert[type(result)](x)

func stint*(x: StInt, bits: static[int]): StInt[bits] {.inline.} =
  ## signed int to signed int conversion
  ## will raise exception if input does not fit into destination
  const N = bitsof(x.data)
  when N < bits:
    when N <= 64:
      result = stint(x.data, bits)
    else:
      if x.isNegative:
        smallToBig(result.data, (-x).data)
        result = -result
      else:
        smallToBig(result.data, x.data)
  elif N > bits:
    template checkNegativeRange() =
      # due to bug #92, we skip negative range check
      when false:
        const dmin = stint((type result).low, N)
        if x < dmin: raise newException(ValueError, "value out of range")

    template checkPositiveRange() =
      const dmax = stint((type result).high, N)
      if x > dmax: raise newException(ValueError, "value out of range")

    when bits <= 64:
      if x.isNegative:
        checkNegativeRange()
        result = stint((-x).truncate(type(result.data)), bits)
        result = -result
      else:
        checkPositiveRange()
        result = stint(x.truncate(type(result.data)), bits)
    else:
      if x.isNegative:
        checkNegativeRange()
        bigToSmall(result.data, (-x).data)
        result = -result
      else:
        checkPositiveRange()
        bigToSmall(result.data, x.data)
  else:
    result = x

func stint*(x: StUint, bits: static[int]): StInt[bits] {.inline.} =
  const N = bitsof(x.data)
  const dmax = stuint((type result).high, N)
  if x > dmax: raise newException(ValueError, "value out of range")
  when N < bits:
    when N <= 64:
      result = stint(x.data, bits)
    else:
      smallToBig(result.data, x.data)
  elif N > bits:
    when bits <= 64:
      result = stint(x.truncate(type(result.data)), bits)
    else:
      bigToSmall(result.data, x.data)
  else:
    result = convert[type(result)](x)

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
  # Always called from a context where radix is known at compile-time
  # and checked within 2..16 and so cannot throw a RangeDefect at runtime

  if str.len < 2:
    return

  doAssert current_idx == 0, "skipPrefixes only works for prefixes (position 0 and 1 of the string)"
  if str[0] == '0':
    if str[1] in {'x', 'X'}:
      if radix != 16:
        raise newException(ValueError,"Parsing mismatch, 0x prefix is only valid for a hexadecimal number (base 16)")
      current_idx = 2
    elif str[1] in {'o', 'O'}:
      if radix != 8:
        raise newException(ValueError, "Parsing mismatch, 0o prefix is only valid for an octal number (base 8)")
      current_idx = 2
    elif str[1] in {'b', 'B'}:
      if radix != 2:
        raise newException(ValueError, "Parsing mismatch, 0b prefix is only valid for a binary number (base 2)")
      current_idx = 2

func nextNonBlank(current_idx: var int, s: string) {.inline.} =
  ## Move the current index, skipping white spaces and "_" characters.

  const blanks = {' ', '_'}

  inc current_idx
  while current_idx < s.len and s[current_idx] in blanks:
    inc current_idx

func readDecChar(c: char): int {.inline.}=
  ## Converts a decimal char to an int
  # specialization without branching for base <= 10.
  if c notin {'0'..'9'}:
    raise newException(ValueError, "Character out of '0'..'9' range")
  ord(c) - ord('0')

func parse*[bits: static[int]](input: string, T: typedesc[Stuint[bits]], radix: static[uint8] = 10): T =
  ## Parse a string and store the result in a Stint[bits] or Stuint[bits].

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

func parse*[bits: static[int]](input: string, T: typedesc[Stint[bits]], radix: static[int8] = 10): T =
  ## Parse a string and store the result in a Stint[bits] or Stuint[bits].

  static: doAssert (radix >= 2) and radix <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  # TODO: we can special case hex result/input as an array of bytes
  #       and be much faster

  # For conversion we require overflowing operations (for example for negative hex numbers)
  const base = radix.int8.stuint(bits)

  var
    curr = 0 # Current index in the string
    isNeg = false
    no_overflow: Stuint[bits]

  if input[curr] == '-':
    doAssert radix == 10, "Negative numbers are only supported with base 10 input."
    isNeg = true
    inc curr
  else:
    skipPrefixes(curr, input, radix)

  while curr < input.len:
    # TODO: overflow detection
    when radix <= 10:
      no_overflow = no_overflow * base + input[curr].readDecChar.stuint(bits)
    else:
      no_overflow = no_overflow * base + input[curr].readHexChar.stuint(bits)
    nextNonBlank(curr, input)

  # TODO: we can't create the lowest int this way
  if isNeg:
    result = -convert[T](no_overflow)
  else:
    result = convert[T](no_overflow)

func fromHex*(T: typedesc[StUint|Stint], s: string): T {.inline.} =
  ## Convert an hex string to the corresponding unsigned integer
  parse(s, type result, radix = 16)

func hexToUint*[bits: static[int]](hexString: string): Stuint[bits] {.inline.} =
  ## Convert an hex string to the corresponding unsigned integer
  parse(hexString, type result, radix = 16)

func toString*[bits: static[int]](num: StUint[bits], radix: static[uint8] = 10): string =
  ## Convert a Stint or Stuint to string.
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
    when bitsof(r.data) <= 64:
      result.add hexChars[r.data.int]
    else:
      result.add hexChars[r.truncate(int)]
    if q.isZero:
      break
    (q, r) = divmod(q, base)

  reverse(result)

func toString*[bits: static[int]](num: Stint[bits], radix: static[int8] = 10): string =
  ## Convert a Stint or Stuint to string.
  ## In case of negative numbers:
  ##   - they are prefixed with "-" for base 10.
  ##   - if not base 10, they are returned raw in two-complement form.

  static: doAssert (radix >= 2) and radix <= 16, "Only base from 2..16 are supported"
  # TODO: use static[range[2 .. 16]], not supported at the moment (2018-04-26)

  const hexChars = "0123456789abcdef"
  const base = radix.int8.stuint(bits)

  result = ""

  type T = Stuint[bits]
  let isNeg = num.isNegative
  let num = convert[T](if radix == 10 and isNeg: -num
            else: num)

  var (q, r) = divmod(num, base)

  while true:
    when bitsof(r.data) <= 64:
      result.add hexChars[r.data.int]
    else:
      result.add hexChars[r.truncate(int)]
    if q.isZero:
      break
    (q, r) = divmod(q, base)

  if isNeg and radix == 10:
    result.add '-'

  reverse(result)

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

func dumpHex*(x: Stint or StUint, order: static[Endianness] = bigEndian): string =
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
    size = bitsof(x.data) div 8

  result = newString(2*size)

  when nimvm:
    for i in 0 ..< size:
      when order == system.cpuEndian:
        let byte = x.data.getByte(i)
      else:
        let byte = x.data.getByte(size - 1 - i)
      result[2*i] = hexChars[int byte shr 4 and 0xF]
      result[2*i+1] = hexChars[int byte and 0xF]
  else:
    {.pragma: restrict, codegenDecl: "$# __restrict $#".}
    let bytes {.restrict.}= cast[ptr array[size, byte]](x.unsafeaddr)

    for i in 0 ..< size:
      when order == system.cpuEndian:
        result[2*i] = hexChars[int bytes[i] shr 4 and 0xF]
        result[2*i+1] = hexChars[int bytes[i] and 0xF]
      else:
        result[2*i] = hexChars[int bytes[bytes[].high - i] shr 4 and 0xF]
        result[2*i+1] = hexChars[int bytes[bytes[].high - i] and 0xF]

proc initFromBytesBE*[bits: static[int]](val: var Stuint[bits], ba: openarray[byte], allowPadding: static[bool] = true) =
  ## Initializes a UInt[bits] value from a byte buffer storing a big-endian
  ## representation of a number.
  ##
  ## If `allowPadding` is set to false, the input array must be exactly
  ## (bits div 8) bytes long. Otherwise, it may be shorter and the remaining
  ## bytes will be assumed to be zero.

  const N = bits div 8

  when not allowPadding:
    doAssert(ba.len == N)
  else:
    doAssert ba.len <= N
    when system.cpuEndian == bigEndian:
      let baseIdx = N - val.len
    else:
      let baseIdx = ba.len - 1

  when nimvm:
    when system.cpuEndian == bigEndian:
      when allowPadding:
        for i, b in ba: val.data.setByte(baseIdx + i, b)
      else:
        for i, b in ba: val.data.setByte(i, b)
    else:
      when allowPadding:
        for i, b in ba: val.data.setByte(baseIdx - i, b)
      else:
        for i, b in ba: val.data.setByte(N-1 - i, b)
  else:
    {.pragma: restrict, codegenDecl: "$# __restrict $#".}
    let r_ptr {.restrict.} = cast[ptr array[N, byte]](val.addr)

    when system.cpuEndian == bigEndian:
      # TODO: due to https://github.com/status-im/nim-stint/issues/38
      # We can't cast a stack byte array to stuint with a convenient proc signature.
      when allowPadding:
        for i, b in ba: r_ptr[baseIdx + i] = b
      else:
        for i, b in ba: r_ptr[i] = b
    else:
      when allowPadding:
        for i, b in ba: r_ptr[baseIdx - i] = b
      else:
        for i, b in ba: r_ptr[N-1 - i] = b

func significantBytesBE*(val: openarray[byte]): int {.deprecated.}=
  ## Returns the number of significant trailing bytes in a big endian
  ## representation of a number.
  # TODO: move that in https://github.com/status-im/nim-byteutils
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

  when nimvm:
    for i in 0 ..< N:
      when system.cpuEndian == bigEndian:
        result[i] = n.data.getByte(i)
      else:
        result[i] = n.data.getByte(N - 1 - i)
  else:
    when system.cpuEndian == bigEndian:
      result = cast[type result](n)
    else:
      {.pragma: restrict, codegenDecl: "$# __restrict $#".}
      let n_ptr {.restrict.} = cast[ptr array[N, byte]](n.unsafeAddr)
      for i in 0 ..< N:
        result[N-1 - i] = n_ptr[i]

template hash*(num: StUint|StInt): Hash =
  # TODO:
  # `hashData` is not particularly efficient.
  # Explore better hashing solutions in nim-stew.
  hashData(unsafeAddr num, sizeof num)


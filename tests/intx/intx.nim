import strutils
from os import DirSep

const intxPath = currentSourcePath.rsplit(DirSep, 1)[0]
{.passc: "-I" & intxPath.}
{.passc: "-std=c++20".}

const INTX_HEADER = intxPath & "/intx.hpp"

static:
  debugEcho INTX_HEADER
  
type
  UInt*[NumBits: static[int]] {.importcpp: "intx::uint<'0>", header: INTX_HEADER.} = object
  
  TTInt = UInt

  stdString {.importc: "std::string", header: "<string.h>".} = object

proc `+`*(a, b: TTInt): TTInt {.importcpp: "(# + #)".}
proc `-`*(a, b: TTInt): TTInt {.importcpp: "(# - #)".}
proc `*`*(a, b: TTInt): TTInt {.importcpp: "(# * #)".}
proc `/`*(a, b: TTInt): TTInt {.importcpp: "(# / #)".}
proc `div`*(a, b: TTInt): TTInt {.importcpp: "(# / #)".}
proc `mod`*(a, b: TTInt): TTInt {.importcpp: "(# % #)".}

proc `==`*(a, b: TTInt): bool {.importcpp: "(# == #)".}
proc `<`*(a, b: TTInt): bool {.importcpp: "(# < #)".}
proc `<=`*(a, b: TTInt): bool {.importcpp: "(# <= #)".}

proc `+=`*(a: var TTInt, b: TTInt) {.importcpp: "# += #".}
proc `-=`*(a: var TTInt, b: TTInt) {.importcpp: "# -= #".}
proc `*=`*(a: var TTInt, b: TTInt) {.importcpp: "# *= #".}
proc `/=`*(a: var TTInt, b: TTInt) {.importcpp: "# /= #".}

proc `and`*(a, b: TTInt): TTInt {.importcpp: "(# & #)".}
proc `or`*(a, b: TTInt): TTInt {.importcpp: "(# | #)".}
proc `xor`*(a, b: TTInt): TTInt {.importcpp: "(# ^ #)".}

proc `|=`*(a: var TTInt, b: TTInt) {.importcpp: "(# |= #)".}
proc `&=`*(a: var TTInt, b: TTInt) {.importcpp: "(# &= #)".}
proc `^=`*(a: var TTInt, b: TTInt) {.importcpp: "(# ^= #)".}

proc `shl`*(a: UInt, b: uint64): UInt {.importcpp: "(# << #)".}
proc `shr`*(a: UInt, b: uint64): UInt {.importcpp: "(# >> #)".}
proc pow*(a, b: TTInt): TTInt {.importcpp: "exp(#,#)".}

proc ToString(a: TTInt, base: cint): stdString {.importcpp: "to_string", header: INTX_HEADER.}
proc toString*(a: TTInt, base: int = 10): string =
  let tmp = a.ToString(cint(base))
  var tmps: cstring
  {.emit: """
  `tmps` = const_cast<char*>(`tmp`.c_str());
  """.}
  result = $tmps

proc `$`*(a: TTInt): string {.inline.} = a.toString()
proc initUInt[T](a: uint64): T {.importcpp: "'0{#}".}

proc pow*(a: UInt, b: uint64): UInt =
  pow(a, initUInt[UInt](b))

#[
proc FromString(a: var TTInt, s: cstring, base: uint) {.importcpp, header: INTX_HEADER.}
proc fromString*(a: var TTInt, s: cstring, base: int = 10) = a.FromString(s, uint(base))
proc fromHex*(a: var TTInt, s: string) {.inline.} = a.fromString(s, 16)

proc initInt[T](a: int64): T {.importcpp: "'0((int)#)".}

proc initInt[T](a: cstring): T {.importcpp: "'0(#)".}

template defineIntConstructor(typ: typedesc, name: untyped{nkIdent}) =
  template name*(a: int64): typ = initInt[typ](a)
  template name*(a: cstring): typ = initInt[typ](a)
  template `+`*(a: typ, b: int): typ = a + initInt[typ](b)
  template `+`*(a: int, b: typ): typ = initInt[typ](a) + b
  template `-`*(a: typ, b: int): typ = a - initInt[typ](b)
  template `-`*(a: int, b: typ): typ = initInt[typ](a) - b
  template `+=`*(a: var typ, b: int) = a += initInt[typ](b)
  template `-=`*(a: var typ, b: int) = a -= initInt[typ](b)

defineIntConstructor(Int256, i256)
defineIntConstructor(Int512, i512)
defineIntConstructor(Int1024, i1024)
defineIntConstructor(Int2048, i2048)

template defineUIntConstructor(typ: typedesc, name: untyped{nkIdent}) =
  template name*(a: uint64): typ = initUInt[typ](a)
  template name*(a: cstring): typ = initInt[typ](a)
  template `+`*(a: typ, b: int): typ = a + initUInt[typ](b)
  template `+`*(a: int, b: typ): typ = initUInt[typ](a) + b
  template `-`*(a: typ, b: int): typ = a - initUInt[typ](b)
  template `-`*(a: int, b: typ): typ = initUInt[typ](a) - b
  template `+=`*(a: var typ, b: uint) = a += initUInt[typ](b)
  template `-=`*(a: var typ, b: uint) = a -= initUInt[typ](b)

defineUIntConstructor(UInt256, u256)
defineUIntConstructor(UInt512, u512)
defineUIntConstructor(UInt1024, u1024)
defineUIntConstructor(UInt2048, u2048)

proc `-`*(a: Int): Int {.importcpp: "(- #)".}

proc pow*(a: Int, b: int): Int =
  var tmp = a
  tmp.inplacePow(initInt[Int](b))
  result = tmp

proc pow*(a: UInt, b: uint64): UInt =
  var tmp = a
  tmp.inplacePow(initUInt[UInt](b))
  result = tmp

proc `shl`*(a: Int, b: int): Int {.importcpp: "(# << #)".}
proc `shr`*(a: Int, b: int): Int {.importcpp: "(# >> #)".}


proc getInt*(a: Int): int {.importcpp: "ToInt", header: INTX_HEADER.}
proc getUInt*(a: UInt): uint64 {.importcpp: "ToUInt", header: INTX_HEADER.}

proc setZero*(a: var TTInt) {.importcpp: "SetZero", header: INTX_HEADER.}
proc setOne*(a: var TTInt) {.importcpp: "SetOne", header: INTX_HEADER.}
proc setMin*(a: var TTInt) {.importcpp: "SetMin", header: INTX_HEADER.}
proc setMax*(a: var TTInt) {.importcpp: "SetMax", header: INTX_HEADER.}
proc clearFirstBits*(a: var TTInt, n: uint) {.importcpp: "ClearFirstBits", header: INTX_HEADER.}

template max*[T: TTInt]: TTInt =
  var r = initInt[T](0)
  r.setMax()
  r



proc hexToUInt*[N](hexStr: string): UInt[N] {.inline.} = result.fromHex(hexStr)
proc toHex*(a: TTInt): string {.inline.} = a.toString(16)

proc toByteArrayBE*[N](num: UInt[N]): array[N div 8, byte] {.noSideEffect, noinit, inline.} =
  ## Convert a TTInt (in native host endianness) to a big-endian byte array
  const N = result.len
  for i in 0 ..< N:
    {.unroll: 4.}
    result[i] = byte getUInt(num shr uint((N-1-i) * 8))

proc readUIntBE*[N](ba: openArray[byte]): UInt[N] {.noSideEffect, inline.} =
  ## Convert a big-endian array of Bytes to an UInt256 (in native host endianness)
  const sz = N div 8
  assert(ba.len >= sz)
  for i in 0 ..< sz:
    {.unroll: 4.}
    result = result shl 8 or initUInt[UInt[N]](ba[i])

proc inc*(a: var TTInt, n = 1) {.inline.} =
  when a is Int:
    a += initInt[type a](n)
  else:
    a += initUInt[type a](n.uint)

proc dec*(a: var TTInt, n = 1) {.inline.} =
  when a is Int:
    a -= initInt[type a](n)
  else:
    a -= initUInt[type a](n.uint)
]#

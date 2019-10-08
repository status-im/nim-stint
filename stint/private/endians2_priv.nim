import ./bitops2_priv, ./datatypes, ./uint_bitwise_ops

import stew/endians2
export endians2

func swapBytes*(x: UintImpl): UintImpl {.inline.} =
  let lo = swapBytes(x.hi)
  let hi = swapBytes(x.lo)

  UintImpl(hi: hi, lo: lo)

func copyMem(x: UintImpl): auto {.compileTime.} =
  const size = bitsof(x) div 8
  var ret: array[size, byte]

  type DT = type x.leastSignificantWord
  for i in 0 ..< size:
    let pos = i * 8
    ret[i] = byte((x shr pos).leastSignificantWord and 0xFF.DT)
  ret

func toBytes*(x: UintImpl, endian: Endianness = system.cpuEndian): auto {.inline.} =
  # TODO can't use bitsof in return type (compiler bug?), hence return auto
  var ret: array[bitsof(x) div 8, byte]
  when nimvm:
    if endian == system.cpuEndian:
      ret = copyMem(x)
    else:
      let v = swapBytes(x)
      ret = copyMem(v)
  else:
    if endian == system.cpuEndian:
      copyMem(addr ret[0], unsafeAddr x, ret.len)
    else:
      let v = swapBytes(x)
      copyMem(addr ret[0], unsafeAddr v, ret.len)
  ret

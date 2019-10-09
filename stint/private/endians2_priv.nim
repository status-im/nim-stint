import ./bitops2_priv, ./datatypes, ./compiletime_helpers
import stew/endians2
export endians2

func swapBytes*(x: UintImpl): UintImpl {.inline.} =
  let lo = swapBytes(x.hi)
  let hi = swapBytes(x.lo)

  UintImpl(hi: hi, lo: lo)

func toBytes*(x: UintImpl, endian: Endianness = system.cpuEndian): auto {.inline.} =
  # TODO can't use bitsof in return type (compiler bug?), hence return auto
  var ret: array[bitsof(x) div 8, byte]
  when nimvm:
    if endian == system.cpuEndian:
      copyToArray(ret, x)
    else:
      let v = swapBytes(x)
      copyToArray(ret, v)
  else:
    if endian == system.cpuEndian:
      copyMem(addr ret[0], unsafeAddr x, ret.len)
    else:
      let v = swapBytes(x)
      copyMem(addr ret[0], unsafeAddr v, ret.len)
  ret

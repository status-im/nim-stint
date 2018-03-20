
import ./mem_corrupt_bug_type, ./mem_corrupt_bug_convert
import ./mem_corrupt_bug_add

import typetraits

# Comment the following to remove the memory corruption
proc naiveMul*(x, y: uint8): MpUint[16] =
  # Multiplication in extended precision
  result = toMpuint(x.uint16 * y.uint16)

proc naiveMul*(x, y: uint16): MpUint[32] =
  # Multiplication in extended precision
  result = toMpuint(x.uint32 * y.uint32)
  debugEcho "naiveMul cast16:" & $result

proc `*`*(x, y: MpUint): MpUint =
  ## Multiplication for multi-precision unsigned uint

  result = naiveMul(x.lo, y.lo)
  result.hi += (naiveMul(x.hi, y.lo) + naiveMul(x.lo, y.hi)).lo

  debugEcho "Within `*` result: " & $result
  debugEcho "Within `*` result type: " & $result.type.name



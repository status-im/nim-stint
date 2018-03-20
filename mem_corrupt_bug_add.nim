import ./mem_corrupt_bug_type

proc `+=`*(x: var MpUint, y: MpUint) =
  ## In-place addition for multi-precision unsigned int
  type SubT = type x.lo
  let tmp = x.lo

  x.lo += y.lo
  x.hi += SubT(x.lo < tmp) + y.hi

proc `+`*(x, y: MpUint): MpUint =
  # Addition for multi-precision unsigned int
  result = x
  result += y

  debugEcho "+: " & $result



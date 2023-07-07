import
  ../../stint,
  ./intx

export intx

template asSt*(val: UInt): auto =
  type TargetType = StUint[val.NumBits]
  cast[ptr TargetType](unsafeAddr val)[]

template asTT*[N: static[int]](arr: array[N, uint64]): auto =
  type TargetType = UInt[N * 64]
  cast[ptr TargetType](unsafeAddr arr[0])[]

template asTT*(x: StUint): auto =
  type TargetType = UInt[x.bits]
  var arr = x.toBytes(cpuEndian)
  cast[ptr TargetType](addr arr[0])[]

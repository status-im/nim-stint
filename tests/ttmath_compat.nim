import ../stint, ttmath
export ttmath

template asSt*(val: UInt): auto =
  type TargetType = StUint[val.NumBits]
  cast[ptr TargetType](unsafeAddr val)[]

template asSt*(val: Int): auto =
  type TargetType = StInt[val.NumBits]
  cast[ptr TargetType](unsafeAddr val)[]

template asTT*[N: static[int]](arr: array[N, uint64]): auto =
  type TargetType = UInt[N * 64]
  cast[ptr TargetType](unsafeAddr arr[0])[]

template asTT*[N: static[int]](arr: array[N, int64]): auto =
  type TargetType = Int[N * 64]
  cast[ptr TargetType](unsafeAddr arr[0])[]


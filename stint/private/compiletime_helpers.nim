import ./datatypes, ./uint_bitwise_ops

func convertImpl[T: SomeInteger](x: SomeInteger): T {.compileTime.} =
  cast[T](x)

func convertImpl[T: IntImpl|UintImpl](x: IntImpl|UintImpl): T {.compileTime.} =
  result.hi = convertImpl[type(result.hi)](x.hi)
  result.lo = x.lo

template convert*[T](x: UintImpl|IntImpl|SomeInteger): T =
  when nimvm:
    # this is a workaround Nim VM inability to cast
    # something non integer
    convertImpl[T](x)
  else:
    cast[T](x)
    
func getByte*(x: SomeInteger, pos: int): byte {.compileTime.} =
  type DT = type x
  byte((x shr (pos * 8)) and 0xFF.DT)

func getByte*(x: UintImpl | IntImpl, pos: int): byte {.compileTime.} =
  type DT = type x.leastSignificantWord
  byte((x shr (pos * 8)).leastSignificantWord and 0xFF.DT)

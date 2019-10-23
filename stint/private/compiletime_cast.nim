import ./datatypes

# this module should be in compiletime_helpers
# but the cyclic dependency of compiletime_helpers
# and int_bitwise_ops make things complicated

func convertImpl[T: SomeInteger](x: SomeInteger): T {.compileTime.} =
  cast[T](x)

func convertImpl[T: IntImpl|UintImpl](x: IntImpl|UintImpl): T {.compileTime.} =
  result.hi = convertImpl[type(result.hi)](x.hi)
  result.lo = x.lo

func convertImpl[T: Stuint|Stint](x: StUint|StInt): T {.compileTime.} =
  result.data = convertImpl[type(result.data)](x.data)

template convert*[T](x: Stuint|Stint|UintImpl|IntImpl|SomeInteger): T =
  when nimvm:
    # this is a workaround Nim VM inability to cast
    # something non integer
    convertImpl[T](x)
  else:
    cast[T](x)
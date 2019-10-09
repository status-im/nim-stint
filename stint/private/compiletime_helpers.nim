import ./datatypes, ./uint_bitwise_ops, ./bitops2_priv

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

proc setByte*(x: var SomeInteger, pos: int, b: byte) {.compileTime.} =
  type DT = type x
  x = x or (DT(b) shl (pos*8))

type SomeIntImpl = UintImpl | IntImpl
func setByte*(x: var SomeIntImpl, pos: int, b: byte) {.compileTime.} =
  proc putFirstByte(x: var SomeInteger, b: byte) =
    type DT = type x
    x = x or b.DT

  proc putFirstByte(x: var UintImpl, b: byte) =
    putFirstByte(x.lo, b)

  var cx: type x
  cx.putFirstByte(b)
  x = x or (cx shl (pos*8))

func copyToArray*(ret: var openArray[byte], x: UintImpl) {.compileTime.} =
  const size = bitsof(x) div 8
  doAssert ret.len >= size
  for i in 0 ..< size:
    ret[i] = x.getByte(i)

func copyFromArray*(x: var UintImpl, data: openArray[byte]) {.compileTime.} =
  const size = bitsof(x) div 8
  doAssert data.len >= size
  for i in 0 ..< size:
    x.setByte(i, data[i])

func copyFromArray*(x: var SomeInteger, data: openArray[byte]) {.compileTime.} =
  const size = bitsof(x) div 8
  doAssert data.len >= size
  for i in 0 ..< size:
    x.setByte(i, data[i])

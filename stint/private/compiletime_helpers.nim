import
  ./datatypes, ./uint_bitwise_ops, ./bitops2_priv, ./int_bitwise_ops,
  ./compiletime_cast

export compiletime_cast

func getByte*(x: SomeInteger, pos: int): byte {.compileTime.} =
  type DT = type x
  when bitsof(DT) == 8:
    cast[byte](x)
  else:
    byte((x shr (pos * 8)) and 0xFF.DT)

func getByte*(x: UintImpl | IntImpl, pos: int): byte {.compileTime.} =
  type DT = type x.leastSignificantWord
  when bitsof(DT) == 8:
    cast[byte](x.leastSignificantWord)
  else:
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

template vmIntCast*[T](data: SomeInteger): T =
  type DT = type data
  const
    bits = bitsof(T)
    DTbits = bitsof(DT)

  # we use esoteric type juggling here to trick the Nim VM
  when bits == 64:
    when DTbits == 64:
      cast[T](data)
    else:
      cast[T](uint64(data and DT(0xFFFFFFFF_FFFFFFFF)))
  elif bits == 32:
    when DTbits == 32:
      cast[T](data)
    else:
      cast[T](uint32(data and DT(0xFFFFFFFF)))
  elif bits == 16:
    when DTbits == 16:
      cast[T](data)
    else:
      cast[T](uint16(data and DT(0xFFFF)))
  else:
    when DTBits == 8:
      cast[T](data)
    else:
      cast[T](uint8(data and DT(0xFF)))

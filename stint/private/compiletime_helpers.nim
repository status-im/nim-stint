import ./datatypes, ./uint_bitwise_ops

func getByte*(x: SomeInteger, pos: int): byte {.compileTime.} =
  type DT = type x
  byte((x shr (pos * 8)) and 0xFF.DT)

func getByte*(x: UintImpl | IntImpl, pos: int): byte {.compileTime.} =
  type DT = type x.leastSignificantWord
  byte((x shr (pos * 8)).leastSignificantWord and 0xFF.DT)

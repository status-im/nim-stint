import ../src/mpint, times


# Warmup on normal int
var start = cpuTime()
block:
  var foo = 123
  for i in 0 ..< 10_000_000:
    foo += i*i mod 456
    foo = foo mod 789

# Compiler shouldn't optimize away the results as cpuTime rely on sideeffects
var stop = cpuTime()
echo "Warmup: " & $(stop - start) & "s"

####################################


start = cpuTime()
block:
  var foo = 123.initMpUint(64)
  for i in 0 ..< 10_000_000:
    let i2 = i.initMpUint(64)
    foo += i2 * i2 mod 456.initMpUint(64)
    foo = foo mod 789.initMpUint(64)

stop = cpuTime()
echo "Library: " & $(stop - start) & "s"

# On my i5-5257 broadwell with the flags:
# nim c -d:release -d:mpint_test
# Warmup: 0.040888s
# Library: 5.838267s

when defined(bench_ttmath):
  # need C++
  import ttmath

  template tt_u256(a: int): UInt[256] = ttmath.u256(a.uint)

  start = cpuTime()
  block:
    var foo = 123.tt_u256
    for i in 0 ..< 10_000_000:
      let i2 = i.tt_u256
      foo += i2 * i2 mod 456.tt_u256
      foo = foo mod 789.tt_u256

  stop = cpuTime()
  echo "TTMath: " & $(stop - start) & "s"

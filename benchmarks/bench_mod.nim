import ../stint, times


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
  var foo = 123.u256
  for i in 0 ..< 10_000_000:
    foo += i.u256 * i.u256 mod 456.u256
    foo = foo mod 789.u256

stop = cpuTime()
echo "Library: " & $(stop - start) & "s"

when defined(bench_ttmath):
  # need C++
  import ttmath

  template tt_u256(a: int): UInt[256] = ttmath.u256(a.uint)

  start = cpuTime()
  block:
    var foo = 123.tt_u256
    for i in 0 ..< 10_000_000:
      foo += i.tt_u256 * i.tt_u256 mod 456.tt_u256
      foo = foo mod 789.tt_u256

  stop = cpuTime()
  echo "TTMath: " & $(stop - start) & "s"

# On my i5-5257 broadwell with the flags:
# nim c -d:release -d:bench_ttmath
# Warmup: 0.04060799999999999s
# Library: 0.9576759999999999s
# TTMath: 0.758443s


# After PR #54 for compile-time evaluation
# which includes loop unrolling but may bloat the code
# Warmup: 0.03993500000000001s
# Library: 0.848464s

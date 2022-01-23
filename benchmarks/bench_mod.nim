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

let a = [123'u64, 123'u64, 123'u64, 123'u64]
let m = [456'u64, 456'u64, 456'u64, 45'u64]

let aU256 = cast[Stuint[256]](a)
let mU256 = cast[Stuint[256]](m)

start = cpuTime()
block:
  var foo = aU256
  for i in 0 ..< 10_000_000:
    foo += (foo * foo) mod mU256

stop = cpuTime()
echo "Library: " & $(stop - start) & "s"

when defined(bench_ttmath):
  # need C++
  import ttmath, ../tests/ttmath_compat

  template tt_u256(a: int): UInt[256] = ttmath.u256(a.uint)

  start = cpuTime()
  block:
    var foo = a.astt()
    let mU256 = m.astt()
    for i in 0 ..< 10_000_000:
      foo += (foo * foo) mod mU256

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

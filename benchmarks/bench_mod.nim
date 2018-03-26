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

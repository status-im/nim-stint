import ../stint, std/[times, monotimes]

template bench(desc: string, body: untyped) =
  let start = getMonotime()
  body
  let stop = getMonotime()
  echo desc,": ", inMilliseconds(stop-start), " ms"

# Warmup on normal int to ensure max CPU freq
# Complex enough that the compiler doesn't optimize it away

proc warmup() =
  var foo = 123
  bench "Warmup":
    for i in 0 ..< 10_000_000:
      foo += i*i mod 456
      foo = foo mod 789

warmup()
####################################

let a = [123'u64, 123'u64, 123'u64, 123'u64]
let m = [456'u64, 456'u64, 456'u64, 45'u64]

proc add_stint(a, m: array[4, uint64]) =
  let aU256 = cast[Stuint[256]](a)
  let mU256 = cast[Stuint[256]](m)

  bench "Add (stint)":
    var foo = aU256
    for i in 0 ..< 100_000_000:
      foo += mU256
      foo += aU256

proc mul_stint(a, m: array[4, uint64]) =
  let aU256 = cast[Stuint[256]](a)
  let mU256 = cast[Stuint[256]](m)

  bench "Mul (stint)":
    var foo = aU256
    for i in 0 ..< 100_000_000:
      foo += (foo * foo)

proc mod_stint(a, m: array[4, uint64]) =
  let aU256 = cast[Stuint[256]](a)
  let mU256 = cast[Stuint[256]](m)

  bench "Mod (stint)":
    var foo = aU256
    for i in 0 ..< 100_000_000:
      foo += (foo * foo) mod mU256

add_stint(a, m)
mul_stint(a, m)
mod_stint(a, m)

when defined(bench_ttmath):
  # need C++
  import ttmath, ../tests/ttmath_compat

  proc add_ttmath(a, m: array[4, uint64]) =
    let aU256 = a.astt()
    let mU256 = m.astt()

    bench "Add (ttmath)":
      var foo = aU256
      for i in 0 ..< 100_000_000:
        foo += mU256
        foo += aU256

  proc mul_ttmath(a, m: array[4, uint64]) =
    let aU256 = a.astt()
    let mU256 = m.astt()

    bench "Mul (ttmath)":
      var foo = aU256
      for i in 0 ..< 100_000_000:
        foo += (foo * foo)

  proc mod_ttmath(a, m: array[4, uint64]) =
    let aU256 = a.astt()
    let mU256 = m.astt()

    bench "Mod (ttmath)":
      var foo = aU256
      for i in 0 ..< 100_000_000:
        foo += (foo * foo) mod mU256

  add_ttmath(a, m)
  mul_ttmath(a, m)
  mod_ttmath(a, m)
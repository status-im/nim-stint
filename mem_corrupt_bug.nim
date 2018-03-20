import  ./mem_corrupt_bug_add,
        ./mem_corrupt_bug_mul

when isMainModule:

  import typetraits
  import ./mem_corrupt_bug_convert

  let a = toMpUint(10'u32)

  echo "a: " & $a
  echo "a+a: " & $(a+a)

  let z = a * a
  echo "a * a: " & $z # How did the result value change?
  echo "a * a type: " & $z.type.name

  # Compile without release: memory corruption
  # In release: no corruption
  # Comment out the "naiveMul" in mul_impl: no corruption
  echo "Is memory corrupted: " & $(z != toMpUint(100'u32))

# Output on my machine
#
# a: (lo: 10, hi: 0)
# +: (lo: 20, hi: 0)
# a+a: (lo: 20, hi: 0)
# naiveMul cast16:(lo: 100, hi: 0)
# naiveMul cast16:(lo: 0, hi: 0)
# naiveMul cast16:(lo: 0, hi: 0)
# +: (lo: 0, hi: 0)
# Within `*` result: (lo: 100, hi: 0)
# Within `*` result type: MpUint[32]
# a * a: (lo: 100, hi: 3924)
# a * a type: MpUint[32]
# Is memory corrupted: true

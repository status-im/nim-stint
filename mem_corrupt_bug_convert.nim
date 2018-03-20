import ./mem_corrupt_bug_type

# Commenting the uint16 proc (that is never called)
# Or
# Removing the inline pragma of the uint32 proc solves the issue

proc toMpUint*(n: uint16): MpUint[16] {.inline.}=
  ## Cast an integer to the corresponding size MpUint
  cast[MpUint[16]](n)

proc toMpUint*(n: uint32): MpUint[32] {.inline.}=
  ## Cast an integer to the corresponding size MpUint
  cast[MpUint[32]](n)

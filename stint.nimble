packageName   = "stint"
version       = "0.0.1"
author        = "Status Research & Development GmbH"
description   = "Efficient stack-based multiprecision int in Nim"
license       = "Apache License 2.0 or MIT"
skipDirs      = @["tests", "benchmarks"]
### Dependencies

# TODO test only requirements don't work: https://github.com/nim-lang/nimble/issues/482
requires "nim >= 0.19",
         "stew"
 #, "https://github.com/alehander42/nim-quicktest >= 0.18.0", "https://github.com/status-im/nim-ttmath"

proc test(args, path: string) =
  if not dirExists "build":
    mkDir "build"
  let styleCheckStyle =
    if (NimMajor, NimMinor) < (1, 6):
      "hint"
    else:
      "error"
  exec "nim " & getEnv("TEST_LANG", "c") & " " & getEnv("NIMFLAGS") & " " & args &
    " --outdir:build -r --hints:off --warnings:off --skipParentCfg" &
    " --styleCheck:usages --styleCheck:" & styleCheckStyle & " " & path

task test, "Run all tests - test and production implementation":
  # Run tests for internal procs - test implementation (StUint[64] = 2x uint32
  test "-d:stint_test", "tests/internal.nim"
  # Run tests for internal procs - prod implementation (StUint[64] = uint64
  test "", "tests/internal.nim"
  # Run all tests - test implementation (StUint[64] = 2x uint32
  test "-d:stint_test", "tests/all_tests.nim"
  # Run all tests - prod implementation (StUint[64] = uint64
  test "--threads:on", "tests/all_tests.nim"

  ## quicktest-0.20.0/quicktest.nim(277, 30) Error: cannot evaluate at compile time: BUILTIN_NAMES
  ##
  # # Run random tests (debug mode) - test implementation (StUint[64] = 2x uint32)
  # test "-d:stint_test", "tests/property_based.nim"
  # # Run random tests (release mode) - test implementation (StUint[64] = 2x uint32)
  # test "-d:stint_test -d:release", "tests/property_based.nim"
  # # Run random tests Uint256 (debug mode) vs TTMath (StUint[256] = 8 x uint32)
  # test "", "tests/property_based.nim"
  # # Run random tests Uint256 (release mode) vs TTMath (StUint[256] = 4 x uint64)
  # test "-d:release", "tests/property_based.nim"

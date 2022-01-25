packageName   = "stint"
version       = "0.0.1"
author        = "Status Research & Development GmbH"
description   = "Efficient stack-based multiprecision int in Nim"
license       = "Apache License 2.0 or MIT"
skipDirs      = @["tests", "benchmarks"]
### Dependencies

# TODO test only requirements don't work: https://github.com/nim-lang/nimble/issues/482
requires "nim >= 1.6.0",
         "stew"
 #, "https://github.com/alehander42/nim-quicktest >= 0.18.0", "https://github.com/status-im/nim-ttmath"

proc test(args, path: string) =
  if not dirExists "build":
    mkDir "build"

  exec "nim " & getEnv("TEST_LANG", "c") & " " & getEnv("NIMFLAGS") & " " & args &
    " --outdir:build -r --hints:off --warnings:off --skipParentCfg" &
    " --styleCheck:usages --styleCheck:error " & path
  if (NimMajor, NimMinor) > (1, 6):
    exec "nim " & getEnv("TEST_LANG", "c") & " " & getEnv("NIMFLAGS") & " " & args &
      " --outdir:build -r --mm:refc --hints:off --warnings:off --skipParentCfg" &
      " --styleCheck:usages --styleCheck:error " & path

task test_internal, "Run tests for internal procs":
  test "internal"

task test_public_api, "Run all tests - prod implementation (StUint[64] = uint64":
  test "all_tests"

task test_uint256_ttmath, "Run random tests Uint256 vs TTMath":
  requires "https://github.com/alehander42/nim-quicktest >= 0.18.0", "https://github.com/status-im/nim-ttmath"
  switch("define", "release")
  test "uint256_ttmath", "cpp"

task test, "Run all tests - test and production implementation":
  exec "nimble test_internal"
  exec "nimble test_public_api"
  ## TODO test only requirements don't work: https://github.com/nim-lang/nimble/issues/482
  # exec "nimble test_property_debug"
  # exec "nimble test_property_release"
  # exec "nimble test_property_uint256_debug"
  # exec "nimble test_property_uint256_release"

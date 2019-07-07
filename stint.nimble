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

proc test(name: string, lang: string = "c") =
  if not dirExists "build":
    mkDir "build"
  --run
  switch("out", ("./build/" & name))
  setCommand lang, "tests/" & name & ".nim"

task test_internal_debug, "Run tests for internal procs - test implementation (StUint[64] = 2x uint32":
  switch("define", "stint_test")
  test "internal"

task test_internal_release, "Run tests for internal procs - prod implementation (StUint[64] = uint64":
  test "internal"

task test_debug, "Run all tests - test implementation (StUint[64] = 2x uint32":
  switch("define", "stint_test")
  test "all_tests"

task test_release, "Run all tests - prod implementation (StUint[64] = uint64":
  test "all_tests"

task test_property_debug, "Run random tests (debug mode) - test implementation (StUint[64] = 2x uint32)":
  requires "https://github.com/alehander42/nim-quicktest >= 0.18.0"
  switch("define", "stint_test")
  test "property_based"

task test_property_release, "Run random tests (release mode) - test implementation (StUint[64] = 2x uint32)":
  requires "https://github.com/alehander42/nim-quicktest >= 0.18.0"
  switch("define", "stint_test")
  switch("define", "release")
  test "property_based"

task test_property_uint256_debug, "Run random tests Uint256 (debug mode) vs TTMath (StUint[256] = 8 x uint32)":
  # TODO: another reference implementation?
  requires "https://github.com/alehander42/nim-quicktest >= 0.18.0", "https://github.com/status-im/nim-ttmath"
  test "property_based", "cpp"

task test_property_uint256_release, "Run random tests Uint256 (release mode) vs TTMath (StUint[256] = 4 x uint64)":
  # TODO: another reference implementation?
  requires "https://github.com/alehander42/nim-quicktest >= 0.18.0", "https://github.com/status-im/nim-ttmath"
  switch("define", "release")
  test "property_based", "cpp"

task test, "Run all tests - test and production implementation":
  exec "nimble test_internal_debug"
  exec "nimble test_internal_release"
  exec "nimble test_debug"
  exec "nimble test_release"
  ## TODO test only requirements don't work: https://github.com/nim-lang/nimble/issues/482
  # exec "nimble test_property_debug"
  # exec "nimble test_property_release"
  # exec "nimble test_property_uint256_debug"
  # exec "nimble test_property_uint256_release"

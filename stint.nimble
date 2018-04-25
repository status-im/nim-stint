packageName   = "stint"
version       = "0.0.1"
author        = "Status Research & Development GmbH"
description   = "Efficient stack-based multiprecision int in Nim"
license       = "Apache License 2.0 or MIT"
srcDir        = "src"

### Dependencies

# TODO remove test only requirements: https://github.com/nim-lang/nimble/issues/482
requires "nim >= 0.18", "https://github.com/alehander42/nim-quicktest >= 0.0.9", "https://github.com/status-im/nim-ttmath#master"

proc test(name: string, lang: string = "c") =
  if not dirExists "build":
    mkDir "build"
  if not dirExists "nimcache":
    mkDir "nimcache"
  --run
  --nimcache: "nimcache"
  switch("out", ("./build/" & name))
  setCommand lang, "tests/" & name & ".nim"

task test_debug, "Run all tests - test implementation (StUint[64] = 2x uint32":
  switch("define", "mpint_test")
  test "all_tests"

task test_release, "Run all tests - prod implementation (StUint[64] = uint64":
  test "all_tests"

task test_property_debug, "Run random tests (normal mode) - test implementation (StUint[64] = 2x uint32)":
  requires "quicktest > 0.0.8"
  switch("define", "mpint_test")
  test "property_based"

task test_property_release, "Run random tests (release mode) - test implementation (StUint[64] = 2x uint32)":
  requires "quicktest > 0.0.8"
  switch("define", "mpint_test")
  switch("define", "release")
  test "property_based"

task test_property_uint256_debug, "Run random tests (normal mode) vs TTMath on Uint256":
  # TODO: another reference implementation?
  requires "quicktest > 0.0.8"
  test "property_based", "cpp"

task test_property_uint256_release, "Run random tests (release mode) vs TTMath on Uint256":
  # TODO: another reference implementation?
  requires "quicktest > 0.0.8"
  switch("define", "release")
  test "property_based", "cpp"

task test, "Run all tests - test and production implementation":
  exec "nimble test_debug"
  exec "nimble test_release"
  exec "nimble test_property_debug"
  exec "nimble test_property_release"
  # TODO: ttmath tests, but importing both together raises illegal storage access

packageName   = "stint"
version       = "2.0.0"
author        = "Status Research & Development GmbH"
description   = "Efficient stack-based multiprecision int in Nim"
license       = "Apache License 2.0 or MIT"
skipDirs      = @["tests", "benchmarks"]
### Dependencies

# TODO test only requirements don't work: https://github.com/nim-lang/nimble/issues/482
requires "nim >= 1.6.12",
         "stew"

let nimc = getEnv("NIMC", "nim") # Which nim compiler to use
let lang = getEnv("NIMLANG", "c") # Which backend (c/cpp/js)
let flags = getEnv("NIMFLAGS", "") # Extra flags for the compiler
let verbose = getEnv("V", "") notin ["", "0"]

from os import quoteShell

let cfg =
  " --styleCheck:usages --styleCheck:error" &
  (if verbose: "" else: " --verbosity:0 --hints:off") &
  " --skipParentCfg --skipUserCfg --outdir:build " &
  quoteShell("--nimcache:build/nimcache/$projectName")


proc build(args, path: string) =
  exec nimc & " " & lang & " " & cfg & " " & flags & " " & args & " " & path

proc run(args, path: string) =
  build args & " --mm:refc -r", path
  if (NimMajor, NimMinor) > (1, 6):
    build args & " --mm:orc -r", path

proc test(path: string) =
  for config in ["", "-d:stintNoIntrinsics"]:
    for mode in ["-d:debug", "-d:release"]:
      run(config & " " & mode, path)

task test_internal, "Run tests for internal procs":
  test "tests/internal"

task test_public_api, "Run all tests - prod implementation (StUint[64] = uint64":
  test "tests/all_tests"

task test, "Run all tests":
  test "tests/internal"
  test "tests/all_tests"

  # Smoke-test wasm32 compiles
  build "--cpu:wasm32 -c", "tests/all_tests"

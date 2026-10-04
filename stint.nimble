mode = ScriptMode.Verbose

packageName   = "stint"
version       = "0.9.0"
author        = "Status Research & Development GmbH"
description   = "Efficient stack-based multiprecision int in Nim"
license       = "Apache License 2.0 or MIT"
skipDirs      = @["tests", "benchmarks"]
### Dependencies

# TODO test only requirements don't work: https://github.com/nim-lang/nimble/issues/482
requires "nim >= 2.0.16",
         "stew >= 0.2.0",
         "intops >= 1.0.8",
         "unittest2 >= 0.2.3"

let nimc = getEnv("NIMC", "nim") # Which nim compiler to use
let lang = getEnv("NIMLANG", "c") # Which backend (c/cpp/js)
let flags = getEnv("NIMFLAGS", "") # Extra flags for the compiler
let verbose = getEnv("V", "") notin ["", "0"]
let platform = getEnv("PLATFORM", "")

from std/os import quoteShell

let cfg =
  " --styleCheck:usages --styleCheck:error" &
  (if verbose: "" else: " --verbosity:0") &
  " --skipParentCfg --skipUserCfg --outdir:build -f " &
  quoteShell("--nimcache:build/nimcache/$projectName")

proc build(args, path: string) =
  exec nimc & " " & lang & " " & cfg & " " & flags & " " & args & " " & path

proc run(args, path: string) =
  build args & " -r", path

proc runTests(args, path: string) =
  for config in ["", "-d:stintNoIntrinsics"]:
    for mode in ["-d:debug", "-d:release"]:
      # Compile-time tests are done separately to speed up full testing
      run(config & " " & mode & " -d:unittest2Static=false" & args, path)

proc test(path: string) =
  runTests " --mm:orc", path
  runTests " --mm:refc", path

task test_internal, "Run tests for internal procs":
  test "tests/internal"

task test_public_api, "Run all tests - prod implementation (StUint[64] = uint64":
  test "tests/all_tests"

task test, "Run all tests":
  test "tests/internal"
  test "tests/all_tests"

  # Run compile-time tests on both 32 and 64 bits
  if lang == "c":
    build "--cpu:amd64 -c -d:unittest2Static", "tests/all_tests"
    build "--cpu:wasm32 -c -d:unittest2Static", "tests/all_tests"

task test_asan, "Run all tests with ASAN":
  if platform != "x86":
    try:
      exec "echo '#if __clang_major__ < 20\n#error\n#endif' | clang -E - >/dev/null"
    except OSError:
      return

    # https://clang.llvm.org/docs/AddressSanitizer.html
    putEnv("ASAN_OPTIONS", "detect_leaks=0:detect_stack_use_after_return=1")
    # https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
    putEnv("UBSAN_OPTIONS", "print_stacktrace=1")
    let asanArgs =
      " --mm:orc -d:useMalloc --cc:clang --debugger:native" &
      " --passC:-fsanitize=address,undefined" &
      " --passL:-fsanitize=address,undefined" &
      " --passC:-fno-sanitize-recover=undefined" &
      " --passC:-fno-sanitize-merge" &
      " --passC:-fno-omit-frame-pointer"
    runTests asanArgs, "tests/internal"
    runTests asanArgs, "tests/all_tests"

task book, "Generate book":
  exec "mdbook build book -d docs"

task apidocs, "Generate API docs":
  exec "nimble doc --outdir:docs/apidocs --project --index:on --git.url:https://github.com/status-im/nim-stint stint.nim"

task docs, "Generate docs":
  exec "nimble book"
  exec "nimble apidocs"

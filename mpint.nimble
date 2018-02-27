packageName   = "mpint"
version       = "0.0.1"
author        = "Status Research & Development GmbH"
description   = "Efficient multiprecision int in Nim"
license       = "Apache License 2.0"
srcDir        = "src"

### Dependencies

requires "nim >= 0.17.2"

proc test(name: string, lang: string = "c") =
  if not dirExists "build":
    mkDir "build"
  if not dirExists "nimcache":
    mkDir "nimcache"
  --run
  --nimcache: "nimcache"
  switch("out", ("./build/" & name))
  setCommand lang, "tests/" & name & ".nim"

task test, "Run all tests":
  test "all_tests"

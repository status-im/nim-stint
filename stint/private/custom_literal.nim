# Stint
# Copyright 2018-2025 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

func getRadix(s: static string): uint8 {.compileTime.} =
  # maybe have prefix
  if s.len >= 2 and s[0] == '0':
    if s[1] == 'b':
      return 2

    if s[1] == 'o':
      return 8

    if s[1] == 'x':
      return 16

  10

func stripPrefix(s: string): string {.compileTime.} =
  if s.len < 2 or s[0] != '0':
    return s
  if s[1] in {'b', 'o', 'x'}:
    return s[2 .. ^1]
  s

func stripLeadingZeros(value: string): string {.compileTime.} =
  var cidx = 0
  # ignore the last character so we retain '0' on zero value
  while cidx < value.len - 1 and value[cidx] == '0':
    cidx.inc
  value[cidx .. ^1]

func isOverflow(T: type SomeBigInteger, s: static string, radix: static uint8): bool {.compileTime.} =
  # a stupid but effective overflow detection
  # it's a compiletime check anyway
  let tmp = parse(s, T, radix)
  let litStr = tmp.toString(radix)
  let normalizedSrc = s.stripPrefix.stripLeadingZeros
  litStr != normalizedSrc

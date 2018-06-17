# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, macros, as_words

proc optimInt*(x: NimNode): NimNode =
  let size = getSize(x)

  if size > 64:
    result = quote do:
      # We represent as unsigned int. Signedness will be managed at a higher level.
      array[`size` div 64, uint64]
  elif size == 64:
    result = quote do:
      int64
  elif size == 32:
    result = quote do:
      int32
  elif size == 16:
    result = quote do:
      int16
  elif size == 8:
    result = quote do:
      int8
  else:
    error "Unreachable path reached"

proc isInt*(x: NimNode): static[bool] =
  if   eqIdent(x, "uint64"): true
  elif eqIdent(x, "int64"):  true
  elif eqIdent(x, "int32"):  true
  elif eqIdent(x, "int16"):  true
  elif eqIdent(x, "int8"):   true
  else: false

macro most_significant_word_signed*(x: IntImpl): untyped =

  let optim_type = optimInt(x)
  if optim_type.isInt:
    result = quote do:
      cast[`optim_type`](`x`)
  else:
    when system.cpuEndian == littleEndian:
      let size = getSize(x)
      let msw_pos = size div 64 - 1
    else:
      let msw_pos = 0
    result = quote do:
      # most significant word must be returned signed for addition/substraction
      # overflow checking
      cast[int](cast[`optim_type`](`x`)[`msw_pos`])

macro asSignedWordsZip*[T](
  x, y: IntImpl[T],
  loopBody: untyped): untyped =
  ## Iterates over x and y, as an array of words.
  ## Input:
  ##   - x, y: The multiprecision ints
  ##   - loopBody: the operation you want to do.
  ##               For the most significant word,
  ##               the operation will be sign aware.
  ##               for the next words it will ignore sign.
  ## Iteration is always done from most significant to least significant
  let
    optim_type = optimInt(x)
    idx = ident("idx_asSignedWordsRawZip")
  var
    first_x, first_y: NimNode
    next_x, next_y: NimNode
    to_replace = nnkBracket.newTree
    replacing  = nnkBracket.newTree

  to_replace.add x
  to_replace.add y

  # We directly cast the first x and y if the result fits in a word
  # Otherwise we special case the most significant word
  if optim_type.isInt:
    first_x = quote do:
      cast[`optim_type`](`x`)
    first_y = quote do:
      cast[`optim_type`](`y`)
  else:
    first_x = getAST(most_significant_word_signed(x))
    first_y = getAST(most_significant_word_signed(y))

  replacing.add first_x
  replacing.add first_y

  let firstReplacedAST = replaceNodes(loopBody, replacing, to_replace)

  # Reset the replacement array
  replacing = nnkBracket.newTree

  # Setup the loop variables
  next_x = ident("x_asSignedWordsRawZip")
  next_y = ident("y_asSignedWordsRawZip")

  # We replace the inner loop with the next_x[idx]
  replacing.add quote do:
    `next_x`[`idx`]
  replacing.add quote do:
    `next_y`[`idx`]

  let nextReplacedAST = replaceNodes(loopBody, replacing, to_replace)

  # Result:
  result = newStmtList()
  result.add firstReplacedAST

  if not optim_type.isInt:
    # if we have multiple iterations to do
    if system.cpuEndian == bigEndian:
      result = quote do:
        {.pragma: restrict, codegenDecl: "$# __restrict $#".}
        let
          `next_x`{.restrict.} = cast[ptr `optim_type`](`x`.unsafeaddr)
          `next_y`{.restrict.} = cast[ptr `optim_type`](`y`.unsafeaddr)
        for `idx` in 1 ..< `next_x`[].len:
          # We start from the second word
          `nextReplacedAST`
    else:
      # Little-Endian, iteration in reverse
      result = quote do:
        {.pragma: restrict, codegenDecl: "$# __restrict $#".}
        let
          `next_x`{.restrict.} = cast[ptr `optim_type`](`x`.unsafeaddr)
          `next_y`{.restrict.} = cast[ptr `optim_type`](`y`.unsafeaddr)
        for `idx` in countdown(`next_x`[].len - 2, 0):
          # We stop stop at the second to last word
          `nextReplacedAST`

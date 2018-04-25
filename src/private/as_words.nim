# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, macros

proc optim(x: NimNode): NimNode =
  let size = getSize(x)

  if size > 64:
    result = quote do:
      array[`size` div 64, uint64]
  elif size == 64:
    result = quote do:
      uint64
  elif size == 32:
    result = quote do:
      uint32
  elif size == 16:
    result = quote do:
      uint16
  elif size == 8:
    result = quote do:
      uint8
  else:
    error "Unreachable path reached"

proc isUint(x: NimNode): static[bool] =
  if eqIdent(x, "uint64"):   true
  elif eqIdent(x, "uint32"): true
  elif eqIdent(x, "uint16"): true
  elif eqIdent(x, "uint8"):  true
  else: false

macro most_significant_word*(x: IntImpl): untyped =

  let optim_type = optim(x)
  if optim_type.isUint:
    result = quote do:
      cast[`optim_type`](`x`)
  else:
    when system.cpuEndian == littleEndian:
      let size = getSize(x)
      let msw_pos = size - 1
    else:
      let msw_pos = 0
    result = quote do:
      cast[`optim_type`](`x`)[`msw_pos`]

proc replaceNodes(ast: NimNode, replacing: NimNode, to_replace: NimNode): NimNode =
  # Args:
  #   - The full syntax tree
  #   - an array of replacement value
  #   - an array of identifiers to replace
  proc inspect(node: NimNode): NimNode =
    case node.kind:
    of {nnkIdent, nnkSym}:
      for i, c in to_replace:
        if node.eqIdent($c):
          return replacing[i]
      return node
    of nnkEmpty:
      return node
    of nnkLiterals:
      return node
    else:
      var rTree = node.kind.newTree()
      for child in node:
        rTree.add inspect(child)
      return rTree
  result = inspect(ast)

macro asWords*[T](n: UintImpl[T], ignoreEndianness: static[bool], loopBody: untyped): untyped =
  ## Iterates over n, as an array of words.
  ## Input:
  ##   - n: The Multiprecision int
  ##   - body: the operation you want to do on each word of n
  ## If iteration is needed, it is done from low to high, not taking endianness in account
  let
    optim_type = optim(n)
  var
    inner_n: NimNode
    to_replace = nnkBracket.newTree
    replacing  = nnkBracket.newTree

  if optim_type.isUint:
    # We directly cast n
    inner_n = quote do:
      cast[`optim_type`](`n`)
  else:
    # If we have an array of words, inner_n is a loop intermediate variable
    inner_n = ident("n_asWordsRaw")

  to_replace.add n
  replacing.add inner_n

  let replacedAST = replaceNodes(loopBody, replacing, to_replace)

  if optim_type.isUint:
    result = replacedAST
  else:
    if ignoreEndianness or system.cpuEndian == bigEndian:
      result = quote do:
        for `inner_n` in cast[`optim_type`](`n`):
          `replacedAST`
    else:
      assert false, "Not implemented"

macro asWordsZip*[T](x, y: UintImpl[T], ignoreEndianness: static[bool], loopBody: untyped): untyped =
  ## Iterates over x and y, as an array of words.
  ## Input:
  ##   - x, y: The multiprecision ints
  ## If iteration is needed, it is done from low to high, not taking endianness in account
  let
    optim_type = optim(x)
    idx = ident("idx_asWordsRawZip")
  var
    inner_x, inner_y: NimNode
    to_replace = nnkBracket.newTree
    replacing  = nnkBracket.newTree

  to_replace.add x
  to_replace.add y

  if optim_type.isUint:
    # We directly castx and y
    inner_x = quote do:
      cast[`optim_type`](`x`)
    inner_y = quote do:
      cast[`optim_type`](`y`)

    replacing.add inner_x
    replacing.add inner_y
  else:
    # If we have an array of words, inner_x and inner_y is are loop intermediate variable
    inner_x = ident("x_asWordsRawZip")
    inner_y = ident("y_asWordsRawZip")

    # We replace the inner loop with the inner_x[idx]
    replacing.add quote do:
      `inner_x`[`idx`]
    replacing.add quote do:
      `inner_y`[`idx`]

  let replacedAST = replaceNodes(loopBody, replacing, to_replace)

  if optim_type.isUint:
    result = replacedAST
  else:
    if ignoreEndianness or system.cpuEndian == bigEndian:
      result = quote do:
        {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
        let
          `inner_x`{.restrict.} = cast[ptr `optim_type`](`x`.unsafeaddr)
          `inner_y`{.restrict.} = cast[ptr `optim_type`](`y`.unsafeaddr)
        for `idx` in 0 ..< `inner_x`[].len:
          `replacedAST`
    else:
      # Little-Endian, iteration in reverse
      result = quote do:
        {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
        let
          `inner_x`{.restrict.} = cast[ptr `optim_type`](`x`.unsafeaddr)
          `inner_y`{.restrict.} = cast[ptr `optim_type`](`y`.unsafeaddr)
        for `idx` in countdown(`inner_x`[].len - 1, 0):
          `replacedAST`

macro m_asWordsZip*[T](m: var UintImpl[T], x: UintImpl[T], ignoreEndianness: static[bool], loopBody: untyped): untyped =
  ## Iterates over a mutable int m and x as an array of words.
  ## returning a !! Pointer !! of the proper type to m.
  ## Input:
  ##   - m: A mutable array
  ##   - x: The multiprecision ints
  ## Iteration is done from low to high, not taking endianness in account
  let
    optim_type = optim(x)
    idx = ident("idx_asWordsRawZip")
  var
    inner_m, inner_x: NimNode
    to_replace = nnkBracket.newTree
    replacing  = nnkBracket.newTree

  to_replace.add m
  to_replace.add x

  if optim_type.isUint:
    # We directly cast m and x
    inner_m = quote do:
      cast[var `optim_type`](`m`.addr)
    inner_x = quote do:
      cast[`optim_type`](`x`)

    replacing.add inner_m
    replacing.add inner_x
  else:
    # If we have an array of words, inner_x and inner_y is are loop intermediate variable
    inner_m = ident("m_asWordsRawZip")
    inner_x = ident("x_asWordsRawZip")

    # We replace the inner loop with the inner_x[idx]
    replacing.add quote do:
      `inner_m`[`idx`]
    replacing.add quote do:
      `inner_x`[`idx`]

  let replacedAST = replaceNodes(loopBody, replacing, to_replace)

  if optim_type.isUint:
    result = replacedAST
  else:
    if ignoreEndianness or system.cpuEndian == bigEndian:
      result = quote do:
        {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
        let
          `inner_m`{.restrict.} = cast[ptr `optim_type`](`m`.addr)
          `inner_x`{.restrict.} = cast[ptr `optim_type`](`x`.unsafeaddr)
        for `idx` in 0 ..< `inner_x`[].len:
          `replacedAST`
    else:
      # Little-Endian, iteration in reverse
      result = quote do:
        {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
        let
          `inner_m`{.restrict.} = cast[ptr `optim_type`](`m`.addr)
          `inner_x`{.restrict.} = cast[ptr `optim_type`](`x`.unsafeaddr)
        for `idx` in countdown(`inner_x`[].len - 1, 0):
          `replacedAST`


macro m_asWordsZip*[T](m: var UintImpl[T], x, y: UintImpl[T], ignoreEndianness: static[bool], loopBody: untyped): untyped =
  ## Iterates over a mutable int m and x as an array of words.
  ## returning a !! Pointer !! of the proper type to m.
  ## Input:
  ##   - m: A mutable array
  ##   - x: The multiprecision ints
  ## Iteration is done from low to high, not taking endianness in account
  let
    optim_type = optim(x)
    idx = ident("idx_asWordsRawZip")
  var
    inner_m, inner_x, inner_y: NimNode
    to_replace = nnkBracket.newTree
    replacing  = nnkBracket.newTree

  to_replace.add m
  to_replace.add x
  to_replace.add y

  if optim_type.isUint:
    # We directly cast m, x and y
    inner_m = quote do:
      cast[var `optim_type`](`m`.addr)
    inner_x = quote do:
      cast[`optim_type`](`x`)
    inner_y = quote do:
      cast[`optim_type`](`y`)

    replacing.add inner_m
    replacing.add inner_x
    replacing.add inner_y
  else:
    # If we have an array of words, inner_x and inner_y is are loop intermediate variable
    inner_m = ident("m_asWordsRawZip")
    inner_x = ident("x_asWordsRawZip")
    inner_y = ident("y_asWordsRawZip")

    # We replace the inner loop with the inner_x[idx]
    replacing.add quote do:
      `inner_m`[`idx`]
    replacing.add quote do:
      `inner_x`[`idx`]
    replacing.add quote do:
      `inner_y`[`idx`]

  let replacedAST = replaceNodes(loopBody, replacing, to_replace)

  # Arrays are in the form (`[]`, array, type)
  if optim_type.isUint:
    result = replacedAST
  else:
    if ignoreEndianness or system.cpuEndian == bigEndian:
      result = quote do:
        {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
        let
          `inner_m`{.restrict.} = cast[ptr `optim_type`](`m`.addr)
          `inner_x`{.restrict.} = cast[ptr `optim_type`](`x`.unsafeaddr)
          `inner_y`{.restrict.} = cast[ptr `optim_type`](`y`.unsafeaddr)
        for `idx` in 0 ..< `inner_x`[].len:
          `replacedAST`
    else:
      # Little-Endian, iteration in reverse
      result = quote do:
        {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
        let
          `inner_m`{.restrict.} = cast[ptr `optim_type`](`m`.addr)
          `inner_x`{.restrict.} = cast[ptr `optim_type`](`x`.unsafeaddr)
          `inner_y`{.restrict.} = cast[ptr `optim_type`](`y`.unsafeaddr)
        for `idx` in countdown(`inner_x`[].len - 1, 0):
          `replacedAST`

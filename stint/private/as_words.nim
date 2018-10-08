# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./datatypes, ./conversion, macros

# #########################################################################
# Multi-precision ints to compile-time array of words

proc asWordsImpl(x: NimNode, current_path: NimNode, result: var NimNode) =
  ## Transforms an UintImpl/IntImpl into an array of words
  ## at compile-time. Recursive implementation.
  ## Result is from most significant word to least significant

  let node = x.getTypeInst

  if node.kind == nnkBracketExpr:
    assert eqIdent(node[0], "UintImpl") or eqIdent(node[0], "IntImpl")

    let hi = nnkDotExpr.newTree(current_path, newIdentNode("hi"))
    let lo = nnkDotExpr.newTree(current_path, newIdentNode("lo"))
    asWordsImpl(node[1], hi, result)
    asWordsImpl(node[1], lo, result)
  else:
    result.add current_path

# #########################################################################
# Accessors

macro asWords(x: UintImpl or IntImpl, idx: static[int]): untyped =
  ## Access a single element from a multiprecision ints
  ## as if if was stored as an array
  ## x.asWords[0] is the most significant word
  var words = nnkBracket.newTree()
  asWordsImpl(x, x, words)
  result = words[idx]

macro most_significant_word*(x: UintImpl or IntImpl): untyped =
  result = getAST(asWords(x, 0))

macro leastSignificantWord*(x: UintImpl or IntImpl): untyped =
  var words = nnkBracket.newTree()
  asWordsImpl(x, x, words)
  result = words[words.len - 1]

macro secondLeastSignificantWord*(x: UintImpl or IntImpl): untyped =
  var words = nnkBracket.newTree()
  asWordsImpl(x, x, words)
  result = words[words.len - 2]

macro leastSignificantTwoWords*(x: UintImpl or IntImpl): untyped =
  var words = nnkBracket.newTree()
  asWordsImpl(x, x, words)
  when system.cpuEndian == bigEndian:
    result = nnkBracket.newTree(words[words.len - 2], words[words.len - 1])
  else:
    result = nnkBracket.newTree(words[words.len - 1], words[words.len - 2])

# #########################################################################
# Iteration macros

proc replaceNodes*(ast: NimNode, replacing: NimNode, to_replace: NimNode): NimNode =
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

macro asWordsIterate(wordsIdents: untyped, sid0, sid1, sid2: typed, signed: static[bool], loopBody: untyped): untyped =
  # TODO: We can't use varargs[typed] without losing type info - https://github.com/nim-lang/Nim/issues/7737
  # So we need a workaround we accept fixed 3 args sid0, sid1, sid2 and will just ignore what is not used
  result = newStmtList()
  let NbStints = wordsIdents.len

  # 1. Get the words of each stint
  # + Workaround varargs[typed] losing type info https://github.com/nim-lang/Nim/issues/7737
  var words = nnkBracket.newTree
  block:
    var wordList = nnkBracket.newTree
    asWordsImpl(sid0, sid0, wordList)
    words.add wordList
  if NbStints > 1:
    var wordList = nnkBracket.newTree
    asWordsImpl(sid1, sid1, wordList)
    words.add wordList
  if NbStints > 2:
    var wordList = nnkBracket.newTree
    asWordsImpl(sid2, sid2, wordList)
    words.add wordList

  # 2. Construct an unrolled loop
  # We replace each occurence of each words
  # in the original loop by how to access it.
  let NbWords  = words[0].len

  for currDepth in 0 ..< NbWords:
    var replacing = nnkBracket.newTree
    for currStint in 0 ..< NbStints:
      var w = words[currStint][currDepth]

      if currDepth == 0 and signed:
        let toInt = bindSym"toInt"
        w = quote do: `toInt`(`w`)

      replacing.add w

    let body = replaceNodes(loopBody, replacing, to_replace = wordsIdents)
    result.add quote do:
      block: `body`

template asWordsParse(): untyped {.dirty.}=
  # ##### Tree representation
  # for word_a, word_b in asWords(a, b):
  #   discard

  # ForStmt
  #   Ident "word_a"
  #   Ident "word_b"
  #   Call
  #     Ident "asWords"
  #     Ident "a"
  #     Ident "b"
  #   StmtList
  #     DiscardStmt
  #       Empty

  # 1. Get the words variable idents
  var wordsIdents = nnkBracket.newTree
  var idx = 0
  while x[idx].kind == nnkIdent:
    wordsIdents.add x[idx]
    inc idx

  # 2. Get the multiprecision ints idents
  var stintsIdents = nnkArgList.newTree # nnkArgList allows to keep the type when passing to varargs[typed]
                                        # but varargs[typed] has further issues ¯\_(ツ)_/¯
  idx = 1
  while idx < x[wordsIdents.len].len and x[wordsIdents.len][idx].kind == nnkIdent:
    stintsIdents.add x[wordsIdents.len][idx]
    inc idx

  assert wordsIdents.len == stintsIdents.len, "The number of loop variables and multiprecision integers t iterate on must be the same"

  # 3. Get the body and pass the bucket to a typed macro
  #    + unroll varargs[typed] manually as workaround for https://github.com/nim-lang/Nim/issues/7737
  var body = x[x.len - 1]
  let sid0 = stintsIdents[0]
  let sid1 = if stintsIdents.len > 1: stintsIdents[1] else: newEmptyNode()
  let sid2 = if stintsIdents.len > 2: stintsIdents[2] else: newEmptyNode()

macro asWords*(x: ForLoopStmt): untyped =
  ## This unrolls the body of the for loop and applies it for each word.
  ## Words are processed from most significant word to least significant.
  asWordsParse()
  result = quote do: asWordsIterate(`wordsIdents`, `sid0`, `sid1`, `sid2`, false, `body`)

macro asSignedWords*(x: ForLoopStmt): untyped =
  ## This unrolls the body of the for loop and applies it for each word.
  ## Words are processed from most significant word to least significant.
  ## The most significant word is returned signed for proper comparison.
  asWordsParse()
  result = quote do: asWordsIterate(`wordsIdents`, `sid0`, `sid1`, `sid2`, true, `body`)

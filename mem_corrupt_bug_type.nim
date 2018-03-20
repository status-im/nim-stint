type
  # TODO: The following is a hacky workaround
  # due to:
  #   - https://github.com/nim-lang/Nim/issues/7230
  #   - https://github.com/nim-lang/Nim/issues/7378
  #   - https://github.com/nim-lang/Nim/issues/7379

  BitsHolder[bits: static[int]] = object

type
  MpUintImpl[bh] = object
    when bh is BitsHolder[32]: lo*, hi*: uint16
    elif bh is BitsHolder[16]: lo*, hi*: uint8

  MpUint*[bits: static[int]] = MpUintImpl[BitsHolder[bits]]

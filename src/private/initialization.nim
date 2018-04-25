# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ./datatypes, typetraits

func initUintImpl*[InType, OutType](x: InType, _: typedesc[OutType]): OutType {.inline.} =

  const
    size_in = getSize(x)
    size_out = getSize(result)

  static:
    assert size_out >= size_in, "The result type size (" & $size_out &
      " for " & $OutType.name &
      ") should be equal or bigger than the input type size (" & $size_in &
      " for " & $InType.name & ")."

  when OutType is SomeUnsignedInt:
    result = x.OutType
  elif size_in == size_out:
    result = cast[type result](x)
  else:
    result.lo = initUintImpl(x, type result.lo)

func zero*[T: BaseUint](_: typedesc[T]): T {.inline.}=
  discard

func one*[T: BaseUint](_: typedesc[T]): T {.inline.}=
  when T is SomeUnsignedInt:
    result = T(1)
  else:
    let r_ptr = cast[ptr array[getSize(result) div 8, byte]](result.addr)
    when system.cpuEndian == bigEndian:
      r_ptr[0] = 1
    else:
      r_ptr[r_ptr[].len - 1] = 1

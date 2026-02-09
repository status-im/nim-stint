# Stint (Stack-based arbitrary precision integers)

[![License: Apache](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Stability: experimental](https://img.shields.io/badge/stability-experimental-orange.svg)
![Github action](https://github.com/status-im/nim-stint/workflows/CI/badge.svg)

`stint` provides efficient and convenient N-bit integers for Nim, for arbitrary
sizes of `N` decided at compile time with an interface similar to to
`int64`/`uint64`.

In addition to basic integer operations, `stint` also contains primtives for
modular arithmetic, endian conversion, basic I/O, bit twiddling etc.

`stint` integers, like their `intXX`/`uintXX` counterpart in Nim are stack-based
values, meaning that they are naturally allocation-free and have value-based
semantics.

- [Quickstart →](https://status-im.github.io/nim-stint/quickstart.html)
- [API Index →](https://status-im.github.io/nim-stint/apidocs/theindex.html)
- [Issues →](https://github.com/status-im/nim-stint/issues)
- [Contributor's Guide →](https://status-im.github.io/nim-stint/contrib.html)

## Priorities

- Portability
  - 32 and 64 bit
  - ARM/x86/x86_64 extensively tested
  - Additionally RISC-V and MIPS for open hardware and low power IoT devices.
- Speed, library is carefully tuned to produce the best assembly given the current compilers.
  However, the library itself does not require assembly for portability.
- No heap/dynamic allocation
- Ease of use:
  - Use traditional `+`, `-`, `+=`, etc operators like on native types
  - converting to and from raw byte BigInts (also called octet string in IETF specs)
  - converting to and from Hex
  - converting to and from decimal strings

Non-priorities include:

- constant-time operation (not suitable for certain kinds of cryptography out of the box)
- runtime precision

## See also

- [constantine](https://github.com/mratsim/constantine) - modular arithmetic and elliptic curve operations focusing on cryptography and constant-time implementation
- [N2472](https://www.open-std.org/jtc1/sc22/wg14/www/docs/n2472.pdf) - `_ExtInt(N)` - native arbitrary precision integers for C
- [stew](https://github.com/status-im/nim-stew/) - helpers and utilities for ordinary Nim integers (`endians2`, `bitops2` etc)

## License

Licensed and distributed under either of

- MIT license: [LICENSE-MIT](./LICENSE-MIT) or http://opensource.org/licenses/MIT

or

- Apache License, Version 2.0, ([LICENSE-APACHEv2](./LICENSE-APACHEv2) or http://www.apache.org/licenses/LICENSE-2.0)

at your option. This file may not be copied, modified, or distributed except according to those terms.

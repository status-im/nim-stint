# Stint (Stack-based multiprecision integers)

[![Build Status (Travis)](https://img.shields.io/travis/status-im/nim-stint/master.svg?label=Linux%20/%20macOS "Linux/macOS build status (Travis)")](https://travis-ci.org/status-im/nim-stint)
[![Windows build status (Appveyor)](https://img.shields.io/appveyor/ci/nimbus/nim-stint/master.svg?label=Windows "Windows build status (Appveyor)")](https://ci.appveyor.com/project/nimbus/nim-stint)
[![License: Apache](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Stability: experimental](https://img.shields.io/badge/stability-experimental-orange.svg)
![Github action](https://github.com/status-im/nim-stint/workflows/nim-stint%20CI/badge.svg)

A fast and portable stack-based multi-precision integer library in pure Nim

Main focus:
  - Portability
    - 32 and 64 bit arch
    - ARM for usage on mobile phones
    - Additionally RISC-V and MIPS for open hardware and low power IoT devices.
  - Speed, library is carefully tuned to produce the best assembly given the current compilers.
    However, the library itself does not resort to assembly for portability.
  - No heap/dynamic allocation
  - Ethereum applications
    - Uint256/Int256 for Ethereum Virtual Machine usage.
    - Uint2048 for Ethereum Bloom filters
  - Ease of use:
    - Use traditional `+`, `-`, `+=`, etc operators like on native types
    - Representation of numbers in memory is the exact same as native types and endianness aware.
      - In practice that means that interfacing with binary blobs representing numbers from cryptographic    libraries can be done with a `cast` if it represents a Uint256, Uint512, Uint1024, Uint2048.
    - converting to and from Hex
    - converting to and from decimal strings

## License

Licensed and distributed under either of

* MIT license: [LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT

or

* Apache License, Version 2.0, ([LICENSE-APACHEv2](LICENSE-APACHEv2) or http://www.apache.org/licenses/LICENSE-2.0)

at your option. This file may not be copied, modified, or distributed except according to those terms.

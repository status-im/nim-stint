# Mpint (Multi-precision integers)

[![Build Status (Travis)](https://img.shields.io/travis/status-im/mpint/master.svg?label=Linux%20/%20macOS "Linux/macOS build status (Travis)")](https://travis-ci.org/status-im/mpint)
[![License: Apache](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Stability: experimental](https://img.shields.io/badge/stability-experimental-orange.svg)

A fast and portable multi-precision integer library in pure Nim

Main focus:
  - no heap/dynamic allocation
  - uint256 for cryptographic and ethereum blockchain usage.
  - ARM portability for usage on mobile phones
  - Ease of use:
      - casting to and from array of bytes
      - converting to and from Hex
      - converting to and from decimal strings

## License

Licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

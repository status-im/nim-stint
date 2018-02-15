# Mpint (Multi-precision integers)

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

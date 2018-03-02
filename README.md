# Mpint (Multi-precision integers)

[![Build Status (Travis)](https://img.shields.io/travis/status-im/mpint/master.svg?label=Linux%20/%20macOS "Linux/macOS build status (Travis)")](https://travis-ci.org/status-im/mpint)
[![License: Apache](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
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

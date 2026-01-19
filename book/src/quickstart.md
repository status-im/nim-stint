# Quickstart

## Installation

```shell
$ nimble install -y stint
```

Add Stint to your .nimble file:

```nim
requires "stint"
```

## Usage

```nim
import stint

func addmul(a, b, c: UInt256): UInt256 =
  a * b + c

echo addmul(u256"100000000000000000000000000000", u256"1", u256"2")
```

# Examples

## Defining Integers

### stint and stuint

### parse

### to

## Arithmetic Operations

## Bitwise Operations

## Usage Examples

### addmul

```nim
import stint

func addmul(a, b, c: UInt256): UInt256 =
  a * b + c

echo addmul(u256"100000000000000000000000000000", u256"1", u256"2")
```

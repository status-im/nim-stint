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

stint allows you to construct multi-precision integers from native integers, strings, and raw bytes and work with them the same way you would with Nim's stock integers, i.e. use all the familiar arithmetic and bit operations (+, -, shl, shr, etc.).

Integers in stint are represented with `StInt[bits]` and `StUint[bits]` types for `bits`-sized signed and unsigned integers respectively.

There are many ways you can define an integer in stint. In this quickstart guide, we'll list only the most common ones. You'll find and exhaustive list in the [Examples](./examples.md#defining-integers) section.

### 128- and 256-bit Integers

Since 128 and 256-bit integers are the most commonly used bigints, stint provides convenience types and procs to define them.

`i128`, `u128`, `i256`, and `u256` postfixes provide the most straightforward way of defining 128 and 256-bit integers:

```nim
import stint

# define signed and unsigned 128-bit integers:
let
  i0 = 123'i128
  u0 = 456'u128
  i1 = 321'i256
  u1 = 654'u256

echo i0, ": ", typeof(i0)
echo u0, ": ", typeof(u0)
echo i1, ": ", typeof(i1)
echo u1, ": ", typeof(u1)

# Output:
# 123: Int128
# 456: UInt128
# 321: Int256
# 654: UInt256
```

Note: `Int128` and `UInt128` are convenience types equivalent to `StInt[128]` and `StUint[128]` respectively. Similarly, `Int256` and `UInt256` are just `StInt[256]` and `StUint[256]`.

To convert a native integer to `Int128` or `UInt128`, use `i128`, `u128`, `i256`, and `u256` as procs:

```nim
let
You   x = 123
  xi128 = i128(x)
  xu128 = u128(x)
  xi256 = i256(x)
  xu256 = u256(x)

echo xi128, ": ", typeof(xi128)
echo xu128, ": ", typeof(xu128)
echo xi256, ": ", typeof(xi256)
echo xu256, ": ", typeof(xu256)

# Output:
# 123: Int128
# 123: UInt128
# 123: Int256
# 123: UInt256
```

### Arbitrary-sized Integers

stint lets you define integers of any size. The only requirement is that the size is known at compile time.

Use `stint` and `stuint` procs to convert a native integer to `StInt[bits]` and `StUint[bits]` respectively:

```nim
import stint

# define 231-bit integers:
let
  i2 = 1111.stint(231)
  u2 = 2222.stuint(231)

echo i2, ": ", typeof(i2)
echo u2, ": ", typeof(u2)

# Output:
# 1111: StInt[231]
# 2222: StUint[231]
```

### Arithmetic Operations

If you have two integers of the same type, you can do pretty much everything with them that you can with Nim's standard integers.

Here are some examples of the arithmetic operators provided by stint:

````nim
import stint

let
  si0 = 123'i128 + 456'i128
  su0 = 456'u128 + 789'u128
  di0 = 17541'i128 div 13'i128
  du0 = 17541'u128 div 13'u128

echo si0, ": ", typeof(si0)
echo su0, ": ", typeof(su0)
echo di0, ": ", typeof(di0)
echo du0, ": ", typeof(du0)

# Output:
# 579: Int128
# 1245: UInt128
# 1349: Int128
# 1349: StUint[128]
```

Note that you can't run operations on stint integers of different size:
```nim
# This won't compile:
let se = 123'i128 + 456'i256
````

However, you can combine stint integers with native ones in some operations:

```nim
let
  si1 = 123'i128 + 100'u64
  su1 = 456'u128 + 100
  du1 = 17541'u128 div 13

echo si1, ": ", typeof(si1)
echo su1, ": ", typeof(su1)
echo 456'u128 + 100 == 456'u128 + 100'u64
echo du1, ": ", typeof(du1)

# Output:
# 223: Int128
# 223: StUint[128]
# true
# 1349: StUint[128]
```

You'll find more usage examples in the [Examples](./examples.md#arithmetic-operations) section.

For a full list of available operations, refer to the [API index](/apidocs/theindex.html).

### Bitwise Operations

Here are some examples of the bitwise operators provided by stint:

```nim
import stint

let bi0 = 123'i128

echo bi0 shl 1
echo bi0.getBit(3)
echo bi0 and 456'i128

# Output:
# 246
# true
# 72
```

You'll find more usage examples in the [Examples](./examples.md#bitwise-operations) section.

For a full list of available operations, refer to the [API index](/apidocs/theindex.html).

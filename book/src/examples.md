# Examples

## Defining Integers

### `i128`, `u128`, `i256`, `u256`

`i128`, `u128`, `i256`, and `u256` procs convert a native integer or a string into a stint integer:

```nim
import stint

let
  i = 123
  s = "456"
  x = i128(i)
  y = i128(s)

echo x
echo y

# Output:
# 123
# 456
```

Use these functions in postfix notation to define stint integers from integer literals:

```nim
echo 123'i128
echo typeof(123'i128)

# Output:
# 123
# Int128
```

[API reference](/apidocs/stint.html)

### `stint` and `stuint`

`stint` and `stuint` procs are used to convert native integers to multi-precision integers of arbitrary size:

```nim
import stint

echo 123.stuint(256)
echo typeof(123.stuint(256))
echo 456.stint(300)
echo typeof(123.stint(300))

# Output:
# 123
# StUint[256]echo 123.stuint(256)
echo typeof(123.stuint(256))
echo 456.stint(300)
echo typeof(123.stint(300))
# 456
# StInt[300]
```

API reference:

- [stint](/apidocs/stint/io.html#stint,StInt,static[int])
- [stuint](/apidocs/stint/io.html#stuint,StInt,static[int])

### `parse`

`parse` proc is used to convert a string to multi-precision integer:

```nim
import stint

echo "123".parse(Int128)
echo typeof("123".parse(Int128))
echo "456".parse(StUint[256])
echo typeof("123".parse(StUint[256]))

# Output:
# 123
# Int128
# 456
# UInt256
```

[API reference](/apidocs/stint/io.html#parse,string,typedesc[StInt[bits]],static[uint8])

### `fromHex`, `fromDecimal`, `hexToUint`

`fromHex` and `fromDecimal` procs are syntactic sugar for the [`parse`](#parse) proc for specific cases when you're parsing a string representing an integer in hexadecimal or decimal format.

`hexToUint` is an even more specific sugar for parsing a hex-string to a StUint:

```nim
import stint

echo UInt128.fromHex("0x123123")
echo Int128.fromDecimal("123123")
echo hexToUint[128]("0x123123")

# Output:
# 1192227
# 123123
# 1192227
```

API reference:
- [parse](/apidocs/stint/io.html#parse,string,typedesc[StInt[bits]],static[uint8])
- [fromHex](/apidocs/stint/io.html#parse,string,typedesc[StInt[bits]],static[uint8])
- [hexToUint](/apidocs/stint/io.html#parse,string,typedesc[StInt[bits]],static[uint8])
- [fromDecimal](/apidocs/stint/io.html#parse,string,typedesc[StInt[bits]],static[uint8])

### `to`

`to` is syntactic sugar for [`stint` and `stuint`](#stint-and-stuint) procs:

```nim
import stint

echo 123.to(UInt256)
echo typeof(123.to(UInt256))
echo 456.to(StInt[300])
echo typeof(456.to(StInt[300]))

# Output:
# 123
# UInt256
# 456
# StInt[300]
```

[API reference](/apidocs/stint/io.html#to,SomeInteger,typedesc[StInt])

### `readIntBE`, `readIntLE`, `readUintBE`, `readUintLE`

These functions allow you create multi-precition integers from arrays of bytes. BE and LE stand for "big-endian" and "little-endian", i.e. determine the direction of the byte array parsing (left to right or right to left):

```nim
import stint

echo readIntBE[128]([byte 1, 2, 3])
echo readIntLE[128]([byte 1, 2, 3])

echo readUintBE[128]([byte 1, 2, 3])
echo readUintLE[128]([byte 1, 2, 3])

# Output:
66051
197121
66051
197121
```

[API reference](/apidocs/stint/io.html#readIntBE,openArray[byte])

## Serializing Integers

### `toString`, `$`, `toHex`

`toString` returns a string representation of a given integer in the given radix. `$` and `toHex` are just `toString` with radix 10 and 16 respectively:

```nim
import stint

echo 123'u128.toString(10)
echo 123'u128.toString(16)
echo $123'u128
echo 123'u128.toHex()

# Output:
# 123
# 7b
# 123
# 7b
```

API reference:
- [toString](/apidocs/stint/io.html#toString,StInt[bits],static[uint8])
- [$](/apidocs/stint/io.html#$)
- [toHex](/apidocs/stint/io.html#toHex)

## Operations

### Arithmeric Operations on the Same Type

```nim
import stint

echo 456'u128 + 123'u128
echo 456'u128 - 123'u128
echo 456'u128 * 123'u128
echo 456'u128 div 123'u128
echo 456'u128 mod 123'u128
echo divmod(456'u128, 123'u128 )

# Output:
# 579
# 333
# 56088
# 3
# 87
# (quot: 3, rem: 87)
```

### In-place Updates

```nim
var x = 123'i128

x += 100'i128
echo x
x -= 50'i128
echo x

# Output:
# 223
# 173
```

### Arithmetic Operations with Mixed Types

```nim
echo 100'u128.pow(3)
echo 456'u128 + 100
echo 456'i128 + 100'u64

# Output:
# 1000000
# 556
# 556
```

### Bitwise Operations

```nim
echo 123'u128 shl 1
echo 123'u128 shr 1
echo 123'u128 or 456'u128
echo 123'u128 and 456'u128
echo 123'u128 xor 456'u128

echo 123'i128 shl 1
echo 123'i128 shr 1
echo 123'i128 or 456'i128
echo 123'i128 and 456'i128
echo 123'i128 xor 456'i128

# Output:
# 246
# 61
# 507
# 72
# 435
# 246
# 61
# 507
# 72
# 435
```

API reference:

- [intops](/apidocs/stint/intops.html)
- [uintops](/apidocs/stint/uintops.html)

### Modular Arithmetic

```nim
import stint

echo addmod(456'u128, 123'u128, 7'u128)
echo submod(456'u128, 123'u128, 7'u128)
echo mulmod(456'u128, 123'u128, 7'u128)
echo powmod(456'u128, 123'u128, 7'u128)

echo addmod(456'i128, 123'i128, 7'i128)
echo submod(456'i128, 123'i128, 7'i128)
echo mulmod(456'i128, 123'i128, 7'i128)
echo powmod(456'i128, 123'i128, 7'i128)

# Output:
# 5
# 4
# 4
# 1
# 5
# 4
# 4
# 1
```

API reference:

- [int_modarith](/apidocs/stint/int_modarith.html)
- [modular_arithmetic](/apidocs/stint/modular_arithmetic.html)

## Usage Examples

### addmul

```nim
import stint

func addmul(a, b, c: UInt256): UInt256 =
  a * b + c

echo addmul(u256"100000000000000000000000000000", u256"1", u256"2")

# Output:
# 100000000000000000000000000002
```

### Crypto: Check User Balance

Checking if a user has enough balance for a transaction including gas fees:

```nim
import stint

let
  senderBalance = u256"100000000000000000000"
  transferAmount = u256"5000000000000000000"
  gasPrice = u256"20000000000"
  gasLimit = u256"21000"

let totalCost = transferAmount + (gasPrice * gasLimit)

if senderBalance >= totalCost:
  let newBalance = senderBalance - totalCost
  echo "Transfer successful. Remaining balance: ", newBalance
else:
  echo "Insufficient funds."

# Output:
# Transfer successful. Remaining balance: 94999580000000000000
```

### Modular Arithmetic (Diffie-Hellman Key Exchange)

```nim
import stint

let p = UInt256.fromHex("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")
let g = u256"2"
let privateKey = UInt256.fromHex("0x4a1b0c8e1d2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f")

let publicKey = powmod(g, privateKey, p)

echo "Public Key to share: ", publicKey.toHex()

# Output:
# Public Key to share: 49a096670adb4db966020006267c7db8179ef7d776cb739fe3640366343ace73
```

### Zero Memory Overhead Raw Byte Parsing

Parsing a network packet header or binary file where a 128-bit ID is stored as big-endian bytes:

```nim
import stint

let rawBytes = [
  0x00'u8, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D,
  0x0E, 0x0F,
]

let packetId = readUintBE[128](rawBytes)

let mask = UInt128.fromHex("0xFFFF0000000000000000000000000000")

if (packetId and mask) != 0.u128:
  echo "Header flag is set!"

echo "Packet ID: ", packetId

# Output:
# Header flag is set!
# Packet ID: 5233100606242806050955395731361295
```

### Large Number Computation

Use 512-bit integers to calculate 50! (regular Nim uint64 would have overflown):

```nim
import stint

type UInt512 = Stint[512]

func factorial(n: int): UInt512 =
  result = 1.to(UInt512)
  for i in 1..n:
    result = result * i.to(UInt512)

let fact50 = factorial(50)

echo "50! = ", fact50

# Output:
# 50! = 30414093201713378043612608166064768844377641568960512000000000000
```

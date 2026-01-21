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

See also:

- [stint module API reference](/apidocs/stint.html)

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
# StUint[256]
# 456
# StInt[300]
```

See also:

- [stint proc API reference](/apidocs/stint/io.html#stint,StInt,static[int])
- [stuint proc API reference](/apidocs/stint/io.html#stuint,StInt,static[int])

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

See also:

- [parse proc API reference](/apidocs/stint/io.html#parse,string,typedesc[StInt[bits]],static[uint8])

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

See also:

- [io proc API reference](/apidocs/stint/io.html#to,SomeInteger,typedesc[StInt])

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

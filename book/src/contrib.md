# Contributor's Guide

## Multi-Precision Integers 101

Native Nim integers have a fixed maximal size: 32 bits for int32 and uint32, 64 bits for int64 and uint64. This means that you can't store a value that won't fit this size.

However, many real-life tasks require the ability to work with integers of arbitrary size regardless of the technical limitations. Integers that aren't bound to a particluar precision level are called _multi-precision_.

Multi-precision integers are represented in computer programs as sequences of _limbs_, each one representing a singe _word_ of fixed size. Depending on the CPU architecture, a word can be 32 or 64 bits of size.

Limbs are like digits in ordinary base-10 numbers but each "digit" can have not 10 possible values but 2^32 or 2^64 possible values.

Doing arithmetic with multi-precision integers means doing arithmetic with each limb separately and carrying the result from limb to limb, similarly how you did addition at school. 

stint uses arithmetic operations on individual words from [intops](https://github.com/vacp2p/nim-intops) and implements the operations on the whole multi-precision integers. 

## Library Structure

```shell
[Repository Root]
│   stint.nim                       <- API entrypoint;
│                                      users normally import just that
│
├───benchmarks
│       bench.nim                   <- Benchmark runner
│
├───helpers
│       prng_unsafe.nim             <- Pseudo-random number generator,
│                                      used in tests and benchmarks
├───stint
│   │   endians2.nim                <- Endianness utilities: byte swapping,
│   │                                  byte array <-> integer conversions 
│   │ 
│   │   intops.nim                  <- Arithmetic operations for signed integers
│   │ 
│   │   int_modarith.nim            <- Modular arithmetic for signed integers
│   │ 
│   │   io.nim                      <- String, byte, and native int parsing,
│   │                                  hex conversion, and string formatting
│   │ 
│   │   lenient_stint.nim           <- [Marked for deprecataion]
│   │                                  Sugar for mixed-precision integer operations
│   │ 
│   │   literals_stint.nim          <- Defines literal macros (u256, u128, etc.)
│   │                                  for easy constant creation
│   │ 
│   │   modular_arithmetic.nim      <- Modular arithmetic for unsigned integers
│   │ 
│   │   uintops.nim                 <- Arithmetic operations for unsigned integers
│   │
│   └───private
│           custom_literal.nim      <- Helper procs for string parsing used in io.nim
│           datatypes.nim           <- stint's types: StInt, Int128, Word, etc.
│           uint_addsub.nim         <- Unsigned integer operation implementations.
│           ...
│
└───tests
    │   all_tests.nim               <- Tests for the publically exposed procs
    │   internal.nim                <- Tests for the private procs
    │   internal_uint_div.nim       <- Dedicated tests for the uint_div procs
    │   test_bugfix.nim             <- Test suites executed with all_tests.nim 
    │   ...
```

## Tests

Run tests of the private procs:

```shell
$ nimble test_internal
```

Test the publically facing procs:

```shell
$ nimble test_public_api
```

Run all tests:

```shell
$ nimble test
```

## Benchmarks

To run the benchmarks, compile and run `benchmarks/bench.nim` with maximum optimizations:

```shell
$ nim r -d:danger --passC:"-march=native -O3" benchmarks/bench.nim
```

## Docs

The docs consist of two parts:

- the book (this is what you're reading right now)
- the API docs

The book is created using [mdBook](https://rust-lang.github.io/mdBook/).

The API docs are generated from the source code docstrings.

To build the docs locally, run:

- `nimble book` to build the book
- `nimble apidocs` to build the API docs
- `nimble docs` to build both

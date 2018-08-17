# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../stint, unittest, strutils
{.experimental: "forLoopMacros".}

suite "Testing input and output procedures":
  test "Creation from decimal strings":
    block:
      let a = "123456789".parse(Stint[64])
      let b = 123456789.stint(64)

      check: a == b
      check: 123456789'i64 == cast[int64](a)

    block:
      let a = "123456789".parse(Stuint[64])
      let b = 123456789.stuint(64)

      check: a == b
      check: 123456789'u64 == cast[uint64](a)

    block:
      let a = "-123456789".parse(Stint[64])
      let b = (-123456789).stint(64)

      check: a == b
      check: -123456789'i64 == cast[int64](a)

  test "Creation from hex strings":
    block:
      let a = "0xFF".parse(Stint[64], base = 16)
      let b = 255.stint(64)

      check: a == b
      check: 255'i64 == cast[int64](a)

    block:
      let a = "0xFF".parse(Stuint[64], base = 16)
      let b = 255.stuint(64)

      check: a == b
      check: 255'u64 == cast[uint64](a)

      let a2 = hexToUint[64]("0xFF")
      check: a == a2

    block:
      let a = "0xFFFF".parse(Stint[16], 16)
      let b = (-1'i16).stint(16)

      check: a == b
      check: -1'i16 == cast[int16](a)

  test "Conversion to decimal strings":
    block:
      let a = 1234567891234567890.stint(128)
      check: a.toString == "1234567891234567890"
      check: $a == "1234567891234567890"

    block:
      let a = 1234567891234567890.stuint(128)
      check: a.toString == "1234567891234567890"
      check: $a == "1234567891234567890"

    block:
      let a = (-1234567891234567890).stint(128)
      check: a.toString == "-1234567891234567890"
      check: $a == "-1234567891234567890"

  test "Conversion to hex strings":
    block:
      let a = 0x1234567890ABCDEF.stint(128)
      check: a.toHex.toUpperAscii == "1234567890ABCDEF"

    block:
      let a = 0x1234567890ABCDEF.stuint(128)
      check: a.toHex.toUpperAscii == "1234567890ABCDEF"

    # TODO: negative hex

  test "Hex dump":
    block:
      let a = 0x1234'i32.stint(32)
      check: a.dumpHex(bigEndian).toUpperAscii == "00001234"

    block:
      let a = 0x1234'i32.stint(32)
      check: a.dumpHex(littleEndian).toUpperAscii == "34120000"

  test "Back and forth bigint conversion consistency":
    block:
      let s = "1234567890123456789012345678901234567890123456789"
      let a = parse(s, StInt[512])
      check: a.toString == s
      check: $a == s

    block:
      let s = "1234567890123456789012345678901234567890123456789"
      let a = parse(s, StUInt[512])
      check: a.toString == s
      check: $a == s

suite "Testing conversion functions: Hex, Bytes, Endianness using secp256k1 curve":

  let
    SECPK1_N_HEX = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141".toLowerAscii
    SECPK1_N = "115792089237316195423570985008687907852837564279074904382605163141518161494337".u256
    SECPK1_N_BYTES = [byte(255), 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 186, 174, 220, 230, 175, 72, 160, 59, 191, 210, 94, 140, 208, 54, 65, 65]

  test "explicit conversions from basic types":
    type
      UInt256 = Stuint[256]
      Int128 = Stint[128]

    let x = 10.uint16

    check:
      x.to(UInt256).bits == 256
      x.to(Int128).bits == 128

  test "hex -> uint256":
    check: SECPK1_N_HEX.parse(Stuint[256], base = 16) == SECPK1_N

  test "uint256 -> hex":
    check: SECPK1_N.dumpHex == SECPK1_N_HEX

  test "hex -> big-endian array -> uint256":
    check: readUintBE[256](SECPK1_N_BYTES) == SECPK1_N

  test "uint256 -> minimal big-endian array -> uint256":
    # test drive the conversion logic by testing the first 25 factorials:
    var f = 1.stuint(256)
    for i in 2 .. 25:
      f = f * i.stuint(256)
      let
        bytes = f.toByteArrayBE
        nonZeroBytes = significantBytesBE(bytes)
        fRestored = Uint256.fromBytesBE(bytes.toOpenArray(bytes.len - nonZeroBytes,
                                                          bytes.len - 1))
      check f == fRestored

  test "uint256 -> big-endian array -> hex":
    check: SECPK1_N.toByteArrayBE == SECPK1_N_BYTES

  # This is a sample of signatures generated with a known-good implementation of the ECDSA
  # algorithm, which we use to test our ECC backends. If necessary, it can be generated from scratch
  # with the following code:
  #
  # """python
  # from devp2p import crypto
  # from eth_utils import encode_hex
  # msg = b'message'
  # msghash = crypto.sha3(b'message')
  # for secret in ['alice', 'bob', 'eve']:
  #     print("'{}': dict(".format(secret))
  #     privkey = crypto.mk_privkey(secret)
  #     pubkey = crypto.privtopub(privkey)
  #     print("    privkey='{}',".format(encode_hex(privkey)))
  #     print("    pubkey='{}',".format(encode_hex(crypto.privtopub(privkey))))
  #     ecc = crypto.ECCx(raw_privkey=privkey)
  #     sig = ecc.sign(msghash)
  #     print("    sig='{}',".format(encode_hex(sig)))
  #     print("    raw_sig='{}')".format(crypto._decode_sig(sig)))
  #     assert crypto.ecdsa_recover(msghash, sig) == pubkey
  # """

  type
    testKeySig = object
      privkey*: string
      pubkey*: string
      raw_sig*: tuple[v: int, r, s: string]
      serialized_sig*: string

  let
    alice = testKeySig(
      privkey: "9c0257114eb9399a2985f8e75dad7600c5d89fe3824ffa99ec1c3eb8bf3b0501",
      pubkey: "5eed5fa3a67696c334762bb4823e585e2ee579aba3558d9955296d6c04541b426078dbd48d74af1fd0c72aa1a05147cf17be6b60bdbed6ba19b08ec28445b0ca",
      raw_sig: (
        v: 1,
        r: "B20E2EA5D3CBAA83C1E0372F110CF12535648613B479B64C1A8C1A20C5021F38", # Decimal "80536744857756143861726945576089915884233437828013729338039544043241440681784",
        s: "0434D07EC5795E3F789794351658E80B7FAF47A46328F41E019D7B853745CDFD"  # Decimal "1902566422691403459035240420865094128779958320521066670269403689808757640701"
      ),
      serialized_sig: "b20e2ea5d3cbaa83c1e0372f110cf12535648613b479b64c1a8c1a20c5021f380434d07ec5795e3f789794351658e80b7faf47a46328f41e019d7b853745cdfd01"
    )

    bob = testKeySig(
      privkey: "38e47a7b719dce63662aeaf43440326f551b8a7ee198cee35cb5d517f2d296a2",
      pubkey: "347746ccb908e583927285fa4bd202f08e2f82f09c920233d89c47c79e48f937d049130e3d1c14cf7b21afefc057f71da73dec8e8ff74ff47dc6a574ccd5d570",
      raw_sig: (
        v: 1,
        r: "5C48EA4F0F2257FA23BD25E6FCB0B75BBE2FF9BBDA0167118DAB2BB6E31BA76E", # Decimal "41741612198399299636429810387160790514780876799439767175315078161978521003886",
        s: "691DBDAF2A231FC9958CD8EDD99507121F8184042E075CF10F98BA88ABFF1F36"  # Decimal "47545396818609319588074484786899049290652725314938191835667190243225814114102"
        ),
        serialized_sig: "5c48ea4f0f2257fa23bd25e6fcb0b75bbe2ff9bbda0167118dab2bb6e31ba76e691dbdaf2a231fc9958cd8edd99507121f8184042e075cf10f98ba88abff1f3601"
      )

    eve = testKeySig(
      privkey: "876be0999ed9b7fc26f1b270903ef7b0c35291f89407903270fea611c85f515c",
      pubkey: "c06641f0d04f64dba13eac9e52999f2d10a1ff0ca68975716b6583dee0318d91e7c2aed363ed22edeba2215b03f6237184833fd7d4ad65f75c2c1d5ea0abecc0",
      raw_sig: (
        v: 0,
        r: "BABEEFC5082D3CA2E0BC80532AB38F9CFB196FB9977401B2F6A98061F15ED603", # Decimal "84467545608142925331782333363288012579669270632210954476013542647119929595395",
        s: "603D0AF084BF906B2CDF6CDDE8B2E1C3E51A41AF5E9ADEC7F3643B3F1AA2AADF"  # Decimal "43529886636775750164425297556346136250671451061152161143648812009114516499167"
        ),
        serialized_sig: "babeefc5082d3ca2e0bc80532ab38f9cfb196fb9977401b2f6a98061f15ed603603d0af084bf906b2cdf6cdde8b2e1c3e51a41af5e9adec7f3643b3f1aa2aadf00"
    )

  test "Alice signature":
    check: alice.raw_sig.r.parse(Stuint[256], 16) == "80536744857756143861726945576089915884233437828013729338039544043241440681784".u256
    check: alice.raw_sig.s.parse(Stuint[256], 16) == "1902566422691403459035240420865094128779958320521066670269403689808757640701".u256

  test "Bob signature":
    check: bob.raw_sig.r.parse(Stuint[256], 16) == "41741612198399299636429810387160790514780876799439767175315078161978521003886".u256
    check: bob.raw_sig.s.parse(Stuint[256], 16) == "47545396818609319588074484786899049290652725314938191835667190243225814114102".u256

  test "Eve signature":
    check: eve.raw_sig.r.parse(Stuint[256], 16) == "84467545608142925331782333363288012579669270632210954476013542647119929595395".u256
    check: eve.raw_sig.s.parse(Stuint[256], 16) == "43529886636775750164425297556346136250671451061152161143648812009114516499167".u256

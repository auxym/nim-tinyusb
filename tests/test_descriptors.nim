import std/unittest
import ../src/tinyusb
import encode

suite "Descriptors":
  test "ConfigAttributes":
    check:
      cast[uint8](initConfigAttributes()) == 1'u8 shl 7
      cast[uint8](initConfigAttributes(true, true)) ==
        ((1'u8 shl 7) or (1'u8 shl 5) or (1'u8 shl 6))

  test "BcdVersion":
    check:
      initBcdVersion(2, 0, 0).uint16 == 0x0200.uint16
      initBcdVersion(2, 1, 3).uint16 == 0x0213.uint16
      initBcdVersion(2, 15, 9).uint16 == 0x02F9.uint16

  test "EndpointAddress":
    check:
      initEpAddress(0b1010, EpDirection.In).uint8 == 0b1_000_1010
      initEpAddress(0b0101, EpDirection.Out).uint8 == 0b0_000_0101

  test "EndpointAttributes":
    check:
      initEndpointAttributes(TransferType.Bulk).uint8 == 0b00_00_00_10
      initEndpointAttributes(
        TransferType.Bulk, IsoSyncType.Adaptive, IsoUsageType.Implicit
      ).uint8 == 0b00_00_00_10
      initEndpointAttributes(
        TransferType.Isochronous, IsoSyncType.Adaptive, IsoUsageType.Implicit
      ).uint8 == 0b00_10_10_01

  test "String Desc. 0":
    # String descriptor 0 is a list of supported language IDs
    var
      buf1: array[255, uint8]
      buf2: array[8, uint8]
      buf3: array[6, uint8]
    let languages = [LangId.EnglishUS, LangId.FrenchCanadian, LangId.German]

    initStringDesc0(languages, buf1)
    initStringDesc0(languages, buf2)
    initStringDesc0(languages, buf3)

    let buf1Unch = cast[ptr UncheckedArray[uint16]](buf1[0].addr)
    let buf2Unch = cast[ptr UncheckedArray[uint16]](buf2[0].addr)
    let buf3Unch = cast[ptr UncheckedArray[uint16]](buf3[0].addr)

    check:
      buf1[0] == 8
      buf1[1] == 0x03
      buf1Unch[1] == languages[0].ord.uint16
      buf1Unch[2] == languages[1].ord.uint16
      buf1Unch[3] == languages[2].ord.uint16

      buf2[0] == 8
      buf2[1] == 0x03
      buf2Unch[1] == languages[0].ord.uint16
      buf2Unch[2] == languages[1].ord.uint16
      buf2Unch[3] == languages[2].ord.uint16

      # This one gets truncated because the buffer is too small
      buf3[0] == 6
      buf3[1] == 0x03
      buf3Unch[1] == languages[0].ord.uint16
      buf3Unch[2] == languages[1].ord.uint16

  test "String Descriptor":
    const
      s = "hello éÇüγ⌀"
      sUtf16 = s.toUTF16LE
    assert sUtf16.len == 22
    assert s.toUTF16LE.fromUTF16LE == s

    var
      buf1: array[255, uint8]
      buf2: array[(sUtf16.len + 2), uint8]
      buf3: array[18, uint8]

    initStringDesc(s, buf1)
    initStringDesc(s, buf2)
    initStringDesc(s, buf3)

    check:
      buf1[0].int == sUtf16.len + 2
      buf1[1] == 0x03
      buf1.getUtf8String == s

      buf2[0].int == sUtf16.len + 2
      buf2[1] == 0x03
      buf2.getUtf8String == s

      buf3[0].int == buf3.len
      buf3[1] == 0x03
      buf3.getUtf8String == "hello éÇ"

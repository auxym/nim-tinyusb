import std/unittest
import ../src/tinyusb

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
      initEndpointAddress(0b1010, EpDirection.In).uint8 == 0b1_000_1010
      initEndpointAddress(0b0101, EpDirection.Out).uint8 == 0b0_000_0101

  test "EndpointAttributes":
    check:
      initEndpointAttributes(TransferType.Bulk).uint8 == 0b00_00_00_10
      initEndpointAttributes(
        TransferType.Bulk, IsoSyncType.Adaptive, IsoUsageType.Implicit
      ).uint8 == 0b00_00_00_10
      initEndpointAttributes(
        TransferType.Isochronous, IsoSyncType.Adaptive, IsoUsageType.Implicit
      ).uint8 == 0b00_10_10_01

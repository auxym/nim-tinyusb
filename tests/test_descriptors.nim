import std/unittest
import ../src/tinyusb

suite "Descriptors":
  test "ConfigAttributes":
    check:
      cast[uint8](configFlags()) == 1'u8 shl 7
      cast[uint8](configFlags(true, true)) ==
        ((1'u8 shl 7) or (1'u8 shl 5) or (1'u8 shl 6))

  test "BcdVersion":
    check:
      createBcdVersion(2, 0, 0).uint16 == 0x0200.uint16
      createBcdVersion(2, 1, 3).uint16 == 0x0213.uint16
      createBcdVersion(2, 15, 9).uint16 == 0x02F9.uint16

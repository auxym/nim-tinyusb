import std/unittest
import ../src/tinyusb
#import ../src/tinyusb/internal

suite "HID Report Descriptors":
  test "Input items":
      # Modifier keys input item from HID spec E.6 example keyboard report
    const
      modkeys = hidReportDesc:
        input(hidData, hidVariable, absolute=true)

      # reserved byte input item from HID spec E.6 example keyboard report
      reservedByte = hidReportDesc:
        input(hidConstant)

      # key array input item from HID spec E.6 example keyboard report
      keyArr = hidReportDesc:
        input(hidData, hidArray)

    check:
      modkeys == "\x81\x02"
      reservedByte == "\x81\x01"
      keyArr == "\x81\x00"

  test "collection item":
    const desc = hidReportDesc:
      collection(HidCollectionKind.Application):
        input(hidData, hidVariable, absolute=true)
        input(hidConstant)
        input(hidData, hidArray)

    check:
      desc == "\xA1\x01\x81\x02\x81\x01\x81\x00\xC0"

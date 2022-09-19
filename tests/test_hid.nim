import std/unittest
import ../src/tinyusb
#import std/strformat

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

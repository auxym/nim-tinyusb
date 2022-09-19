import std/unittest
import ../src/tinyusb
#import std/strformat

template stsq(item: HidShortItem): seq[uint8] =
  var s: string
  s.serialize(item)
  var r: seq[uint8]
  for c in s:
    r.add c.uint8
  r

suite "HID Report Descriptors":
  test "Input items":
    const
      # Modifier keys input item from HID spec E.6 example keyboard report
      modkeys = input(hidData, hidVariable, absolute=true)

      # reserved byte input item from HID spec E.6 example keyboard report
      reservedByte = input(hidConstant)

      # key array input item from HID spec E.6 example keyboard report
      keyArr = input(hidData, hidArray)


    check:
      modkeys.stsq == @[0x81'u8, 0x02]
      reservedByte.stsq == @[0x81'u8, 0x01]
      keyArr.stsq == @[0x81'u8, 0x00]

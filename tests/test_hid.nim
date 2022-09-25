import std/unittest
import ../src/tinyusb
import ../src/tinyusb/internal

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

  test "nested collections":
    const desc = hidReportDesc:
      collection(HidCollectionKind.Application):
        input(hidData, hidVariable, absolute=true)
        collection(HidCollectionKind.Physical):
          input(hidConstant)
        input(hidData, hidArray)

    check:
      desc == "\xA1\x01\x81\x02\xA1\x00\x81\x01\xC0\x81\x00\xC0"

  test "Output item":
    const outitem = hidReportDesc:
      output(hidData, hidVariable, absolute=true)
    check:
      outitem == "\x91\x02"

  test "Global usage page item":
    const
      generic = hidReportDesc:
        usagePage(HidUsagePage.GenericDesktopControls)
      buttons = hidReportDesc:
        usagePage(HidUsagePage.Buttons)
      keycodes = hidReportDesc:
        usagePage(HidUsagePage.Keyboard)
      leds = hidReportDesc:
        usagePage(HidUsagePage.LEDs)

    check:
      generic == "\x05\x01"
      buttons == "\x05\x09"
      keycodes == "\x05\x07"
      leds == "\x05\x08"

  test "Logical min/max items":
    const
      logmin0 = hidReportDesc:
        logicalMinimum(0'i8)
      logminneg127 = hidReportDesc:
        logicalMinimum(-127'i8)
      logmax1 = hidReportDesc:
        logicalMaximum(1'i8)
      logmax101 = hidReportDesc:
        logicalMaximum(101'i8)
      logmax127 = hidReportDesc:
        logicalMaximum(127'i8)

    check:
      logmin0 == "\x15\x00"
      logminneg127 == "\x15\x81"
      logminneg127 == "\x15\x81"
      logmax1 == "\x25\x01"
      logmax101 == "\x25\x65"
      logmax127 == "\x25\x7F"

  test "Unit item":
    const
      joule = hidReportDesc:
        unit(HidUnitSystem.SiLinear, length=2, mass=1, time=(-2))
    check:
      joule == "\x66\x21\xE1"

  test "Report size":
    const
      repsize = hidReportDesc:
        reportSize(8)
    check:
      repSize == "\x75\x08"

  test "Report count":
    const
      repcount = hidReportDesc:
        reportCount(6)
    check:
      repCount == "\x95\x06"

  test "Usage and usage min/max items":
    const
      kbUsage = hidReportDesc:
        usage(hidUsageGenericDesktopControlsKeyboard.id)
      min = hidReportDesc:
        usageMinimum(224)
      max = hidReportDesc:
        usageMaximum(231)
    check:
      kbUsage == "\x09\x06"
      min == "\x19\xE0"
      max == "\x29\xE7"

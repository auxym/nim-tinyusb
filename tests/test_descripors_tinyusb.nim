import std/unittest
import std/os
import std/strformat
import ../src/tinyusb

# Setup compiling of file "usb_descriptors.c" which contains descripors
# generated by TinyUSB's macros, used as a reference in following tests.
const
  TinyUsbPath {.strdefine.} = ""
  TinyUsbSrcPath = TinyUsbPath / "src"

{.passC: fmt"-I{TinyUsbSrcPath}".}
{.compile("usb_descriptors.c").}


suite "Validate descriptors against TinyUSB macros":

  test "CDC interface descriptor":
    const desclen = sizeof(CompleteCdcSerialPortInterface)
    let
      nimCdcDesc = initCompleteCdcSerialPortInterface(
        0.InterfaceNumber, 1, 8, 2, 64, 4.StringIndex
      )
      tusbCdcDesc {.importc: "desc_cdc_itf".}: array[desclen, uint8]

    var nimCdcDescArr: array[desclen, uint8]
    let s = serialize(nimCdcDesc)
    for (i, c) in s.pairs:
      nimCdcDescArr[i] = c.uint8

    check:
      tusbCdcDesc == nimCdcDescArr

  #test "HID interface descriptor":
    #const desclen = sizeof(CompleteHidInterfaceDescriptor)
    #let
    #  tusbHidDesc {.importc: "desc_hid_itf".}: array[desclen, uint8]
    #  tusbReportDescLen {.importc: "desc_hid_report_size".} : uint16

    #var nimHidDesc = initCompleteHidInterface(
    #  2.InterfaceNumber, tusbReportDescLen, 3, 16, 5, str=5.StringIndex
    #)
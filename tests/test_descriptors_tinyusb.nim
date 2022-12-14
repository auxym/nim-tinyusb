import std/unittest
import std/os
import std/strformat
import std/strutils
import ../src/tinyusb
import ../src/tinyusb/internal

# Setup compiling of file "usb_descriptors.c" which contains descripors
# generated by TinyUSB's macros, used as a reference in following tests.
const
  TinyUsbPath {.strdefine.} = ""
  TinyUsbSrc = TinyUsbPath / "src"

{.passc: fmt"-I{TinyUsbSrc}".}
{.compile: "usb_descriptors.c".}

template toByteArray(sz: static[int], str: string): auto =
  var arr: array[sz, uint8]
  for (i, ch) in str.pairs:
    arr[i] = ch.uint8
  arr

func toString[T: openArray[char or uint8]](s: T): string =
  for b in s: result.add b.char

# workaround for https://github.com/nim-lang/Nim/issues/19500
func find(s, sub: string): int =
  for i in 0 ..< (s.len - sub.len):
    if s[i ..< (i + sub.len)] == sub:
      return i
  return -1

func fixKbDesc(desc: openArray[uint8]): string =
  # Tinyusb KB report mostly matches the example KB report in HID spec v1.11,
  # except for the keypress usage min item. TinyUSB keeps one extra trailing
  # zero byte. Here we remove (abbreviate) this zero byte and set the size
  # field in the item prefix to 1 instead of 2.
  result = desc.toString
  block:
    let usgMax255Idx = result.find("\x2A\xFF\x00")
    assert usgMax255Idx >= 0
    let usgMaxNewPrefix = block:
      var p = HidItemPrefix(0x2A)
      p.size = 1
      p
    result[usgMax255Idx] = usgMaxNewPrefix.char
    result.delete((usgMax255Idx + 2)..(usgMax255Idx + 2)) # remove 0 byte

suite "Validate descriptors against TinyUSB macros":

  test "CDC interface descriptor":
    const desclen = sizeof(CompleteCdcSerialPortInterface)
    let
      nimCdcDesc = initCompleteCdcSerialPortInterface(
        0.InterfaceNumber, 1, 8, 2, 64, 4.StringIndex
      )
      tusbCdcDesc {.importc: "desc_cdc_itf".}: array[desclen, uint8]

    let nimCdcDescArr = toByteArray(desclen, nimCdcDesc.serialize())

    check:
      nimCdcDesc.serialize.len == desclen
      tusbCdcDesc == nimCdcDescArr

  test "HID interface descriptor":
    const desclen = sizeof(CompleteHidInterface)

    let
      tusbDesc {.importc: "desc_hid_itf".}: array[desclen, uint8]
      tusbReportDescLen {.importc: "desc_hid_report_size".}: csize_t

    var nimDesc = initCompleteHidInterface(
      2.InterfaceNumber, tusbReportDescLen.uint16, 3, 16, 5, str=5.StringIndex
    )
    nimDesc.hid.hidVersion = initBcdVersion(1, 1, 1)

    let nimDescBytes = toByteArray(desclen, nimDesc.serialize)
    #echo "nim  ", nimDescBytes
    #echo "tusb ", tusbDesc
    check:
      nimDesc.serialize.len == desclen
      nimDescBytes == tusbDesc

  test "HID + CDC Configuration descriptor reply":
    const desclen = sizeof(CompleteHidInterface) +
                    sizeof(CompleteCdcSerialPortInterface) +
                    sizeof(ConfigurationDescriptor)

    let
      tusbDesc {.importc: "desc_fs_configuration".}: array[desclen, uint8]
      tusbHidReportDescLen {.importc: "desc_hid_report_size".}: csize_t

      cfgDesc = initConfigurationDescriptor(
        val=1, totalLength=desclen, numItf=3, powerma=100,
      )

      cdcDesc = initCompleteCdcSerialPortInterface(
        0.InterfaceNumber, 1, 8, 2, 64, 4.StringIndex
      )

    var hidDesc = initCompleteHidInterface(
      2.InterfaceNumber, tusbHidReportDescLen.uint16, 3, 16, 5, str=5.StringIndex
    )
    hidDesc.hid.hidVersion = initBcdVersion(1, 1, 1)

    let fullCfgDesc = serializeAll(cfgDesc, cdcDesc, hidDesc)

    check:
      fullCfgDesc.len == desclen
      toByteArray(desclen, fullCfgDesc) == tusbDesc

  test "TinyUSB HID Keyboard Report Descriptor":
    const descLen = 65
    let
      #tusbKbReportDescLen {.importc: "desc_hid_kb_report_size".}: csize_t
      tusbKbReportDesc {.importc: "desc_hid_kb_report".}: array[desclen, uint8]
    check:
      keyboardReportDescriptor() == fixKbDesc(tusbKbReportDesc)

  test "TinyUSB HID Keyboard Report Descriptor with Report ID":
    const descLen = 67
    let
      tusbKbReportDesc {.importc: "desc_hid_kbid_report".}: array[desclen, uint8]
    check:
      keyboardReportDescriptor(id=69) == fixKbDesc(tusbKbReportDesc)

  test "TinyUSB HID Mouse Report Descriptor":
    const descLen = 77
    let
      #tusbMouseReportDescLen {.importc: "desc_hid_mouse_report_size".}: csize_t
      tusbMouseReportDesc {.importc: "desc_hid_mouse_report".}: array[desclen, uint8]
    check:
      mouseReportDescriptor() == tusbMouseReportDesc.toString

  test "TinyUSB HID Mouse Report Descriptor with report ID":
    const descLen = 79
    let
      #tusbMouseReportDescLen {.importc: "desc_hid_mouse_report_size".}: csize_t
      tusbMouseReportDesc {.importc: "desc_hid_mouseid_report".}: array[desclen, uint8]
    check:
      mouseReportDescriptor(69) == tusbMouseReportDesc.toString

  test "TinyUSB HID Gamepad Report Descriptor":
    const descLen = 66
    let
      #tusbGpReportDescLen {.importc: "desc_hid_gp_report_size".}: csize_t
      tusbGpReportDesc {.importc: "desc_hid_gp_report".}: array[desclen, uint8]
    #echo tusbGpReportDescLen
    check:
      gamepadReportDescriptor() == tusbGpReportDesc.toString

  test "TinyUSB HID Gamepad Report Descriptor with report ID":
    const descLen = 68
    let
      #tusbGpReportDescLen {.importc: "desc_hid_gp_report_size".}: csize_t
      tusbGpIdReportDesc {.importc: "desc_hid_gpid_report".}: array[desclen, uint8]
    #echo tusbGpReportDescLen
    check:
      gamepadReportDescriptor(69) == tusbGpIdReportDesc.toString

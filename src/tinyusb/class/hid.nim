import std/bitops
import std/macros
import std/genasts
import std/strutils

import ../descriptors
import ../internal
import ./hid_usages

export hid_usages

# HID Device API

type KeyboardKeypress* {.size: 1.} = enum
  ## HID usage codes for the Keyboard Usage Page.
  keyNone = 0x00
  keyA = 0x04
  keyB = 0x05
  keyC = 0x06
  keyD = 0x07
  keyE = 0x08
  keyF = 0x09
  keyG = 0x0A
  keyH = 0x0B
  keyI = 0x0C
  keyJ = 0x0D
  keyK = 0x0E
  keyL = 0x0F
  keyM = 0x10
  keyN = 0x11
  keyO = 0x12
  keyP = 0x13
  keyQ = 0x14
  keyR = 0x15
  keyS = 0x16
  keyT = 0x17
  keyU = 0x18
  keyV = 0x19
  keyW = 0x1A
  keyX = 0x1B
  keyY = 0x1C
  keyZ = 0x1D
  key1 = 0x1E
  key2 = 0x1F
  key3 = 0x20
  key4 = 0x21
  key5 = 0x22
  key6 = 0x23
  key7 = 0x24
  key8 = 0x25
  key9 = 0x26
  key0 = 0x27
  keyEnter = 0x28
  keyEscape = 0x29
  keyBackspace = 0x2A
  keyTab = 0x2B
  keySpace = 0x2C
  keyMinus = 0x2D
  keyEqual = 0x2E
  keyBracketLeft = 0x2F
  keyBracketRight = 0x30
  keyBackslash = 0x31
  keyEurope1 = 0x32
  keySemicolon = 0x33
  keyApostrophe = 0x34
  keyGrave = 0x35
  keyComma = 0x36
  keyPeriod = 0x37
  keySlash = 0x38
  keyCapsLock = 0x39
  keyF1 = 0x3A
  keyF2 = 0x3B
  keyF3 = 0x3C
  keyF4 = 0x3D
  keyF5 = 0x3E
  keyF6 = 0x3F
  keyF7 = 0x40
  keyF8 = 0x41
  keyF9 = 0x42
  keyF10 = 0x43
  keyF11 = 0x44
  keyF12 = 0x45
  keyPrintScreen = 0x46
  keyScrollLock = 0x47
  keyPause = 0x48
  keyInsert = 0x49
  keyHome = 0x4A
  keyPageUp = 0x4B
  keyDelete = 0x4C
  keyEnd = 0x4D
  keyPageDown = 0x4E
  keyArrowRight = 0x4F
  keyArrowLeft = 0x50
  keyArrowDown = 0x51
  keyArrowUp = 0x52
  keyNumLock = 0x53
  keyKeypadDivide = 0x54
  keyKeypadMultiply = 0x55
  keyKeypadSubtract = 0x56
  keyKeypadAdd = 0x57
  keyKeypadEnter = 0x58
  keyKeypad1 = 0x59
  keyKeypad2 = 0x5A
  keyKeypad3 = 0x5B
  keyKeypad4 = 0x5C
  keyKeypad5 = 0x5D
  keyKeypad6 = 0x5E
  keyKeypad7 = 0x5F
  keyKeypad8 = 0x60
  keyKeypad9 = 0x61
  keyKeypad0 = 0x62
  keyKeypadDecimal = 0x63
  keyEurope2 = 0x64
  keyApplication = 0x65
  keyPower = 0x66
  keyKeypadEqual = 0x67
  keyF13 = 0x68
  keyF14 = 0x69
  keyF15 = 0x6A
  keyF16 = 0x6B
  keyF17 = 0x6C
  keyF18 = 0x6D
  keyF19 = 0x6E
  keyF20 = 0x6F
  keyF21 = 0x70
  keyF22 = 0x71
  keyF23 = 0x72
  keyF24 = 0x73
  keyExecute = 0x74
  keyHelp = 0x75
  keyMenu = 0x76
  keySelect = 0x77
  keyStop = 0x78
  keyAgain = 0x79
  keyUndo = 0x7A
  keyCut = 0x7B
  keyCopy = 0x7C
  keyPaste = 0x7D
  keyFind = 0x7E
  keyMute = 0x7F
  keyVolumeUp = 0x80
  keyVolumeDown = 0x81
  keyLockingCapsLock = 0x82
  keyLockingNumLock = 0x83
  keyLockingScrollLock = 0x84
  keyKeypadComma = 0x85
  keyKeypadEqualSign = 0x86
  keyKanji1 = 0x87
  keyKanji2 = 0x88
  keyKanji3 = 0x89
  keyKanji4 = 0x8A
  keyKanji5 = 0x8B
  keyKanji6 = 0x8C
  keyKanji7 = 0x8D
  keyKanji8 = 0x8E
  keyKanji9 = 0x8F
  keyLang1 = 0x90
  keyLang2 = 0x91
  keyLang3 = 0x92
  keyLang4 = 0x93
  keyLang5 = 0x94
  keyLang6 = 0x95
  keyLang7 = 0x96
  keyLang8 = 0x97
  keyLang9 = 0x98
  keyAlternateErase = 0x99
  keySysreqAttention = 0x9A
  keyCancel = 0x9B
  keyClear = 0x9C
  keyPrior = 0x9D
  keyReturn = 0x9E
  keySeparator = 0x9F
  keyOut = 0xA0
  keyOper = 0xA1
  keyClearAgain = 0xA2
  keyCrselProps = 0xA3
  keyExsel = 0xA4

type KeyModifier* {.pure, size: 1.} = enum
  ## HID Keyboard modifier codes, to be used as set.
  lCtrl, lShift, lAlt, lGui, rCtrl, rShift, rAlt, rGui

type KeyboardLed* {.pure, importC: "hid_keyboard_led_bm_t".} = enum
    numLock, capsLock, scrollLock, compose, kana

type GamepadButton* {.pure.} = enum
  ## Represent up to 32 buttons for HID gamepad input reports
  b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16,
  b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, b29, b30, b31

type GamepadHatPosition* {.pure, size: 1.} = enum
  ## Represent position of HID gamepad Hat or D-Pad.
  centered  = 0
  up        = 1
  upRight   = 2
  right     = 3
  downRight = 4
  down      = 5
  downLeft  = 6
  left      = 7
  upLeft    = 8

type MouseButton* {.pure, size: 1.} = enum
  ## Represents 5 standards buttons for HID mouse input reports
  left, right, middle, back, forward

type
  HidDescriptorType* {.pure.} = enum
    Hid = 0x21, Report = 0x22, Physical = 0x23

  HidCountryCode* {.pure.} = enum
    NotSupported,
    Arabic,
    Belgian,
    CanadianBilingual,
    CanadianFrench,
    CzechRepublic,
    Dannish,
    Finnish,
    French,
    German,
    Greek,
    Hebrew,
    Hungary,
    International,
    Italian,
    JapanKatakana
    Korean,
    LatinAmerican,
    NetherlandsDutch,
    Norwegian,
    PersianFarsi,
    Poland,
    Portuguese,
    Russia,
    Slovakia,
    Spanish,
    Sweedish,
    SwissFrench,
    SwissGerman,
    Switzerland,
    Taiwan,
    TurkishQ,
    UK,
    US,
    Yugoslavia,
    Turkish_f

{.push header: "tusb.h".}
type
  HidReportType* {.pure, importC: "hid_report_type_t".} = enum
    ## HID Request Report Type
    Invalid, Input, Output, Feature

  MouseReport* {.packed, importC: "hid_mouse_report_t".} = object
    buttons*: set[MouseButton]
    x*, y*, wheel*, pan*: int8

  KeyboardReport* {.importc: "hid_keyboard_report_t", packed.} = object
    modifier*: set[KeyModifier]
    reserved: uint8
    keycode*: array[6, KeyboardKeypress]
{.pop.}

static:
  assert sizeof(set[KeyModifier]) == 1

type HidInterface* = distinct uint8
## Used to represent the HID interface number, as configured by `CFG_TUD_HID`.
## Eg. if `CFG_TUD_HID` is `1`, then only `0.HidInterface` would be valid.
## If `CFG_TUD_HID` is `2`, then we could use `0.HidInterface` and
## `1.HidInterface`.
##
## Note: A single HID interface can send multiple report types, eg, keyboard
## and mouse. See the `id` parameter in the HID API procs for the report id.

converter toInterfaceNumber*(h: HidInterface): InterfaceNumber =
  h.uint8.InterfaceNumber

borrowSerialize: HidInterface

{.push header: "tusb.h".}

proc ready*(itf: HidInterface): bool {.importC: "tud_hid_n_ready".}
  ## Check if the interface is ready to use

proc sendReport*(itf: HidInterface, id: byte, report: pointer, len: byte):
    bool {.importc: "tud_hid_n_report".}
  ## Send input report to host.
  ##
  ## **Parameters:**
  ##
  ## ==========  ===================
  ## **itf**     HID interface index
  ## **id**      Report index for the interface.
  ## **report**  Pointer to raw byte array containing report data (must
  ##             conform to the report descriptor)
  ## **len**     Report data array length

proc sendKeyboardReport(itf: HidInterface, id: byte, modifier: uint8,
    keycode: ptr uint8): bool {.importc: "tud_hid_n_keyboard_report".}

proc sendMouseReport*(itf: HidInterface, id: byte,
    buttons: set[MouseButton], x, y, vertical, horizontal: int8): bool
    {.importc: "tud_hid_n_mouse_report".}
  ## Convenient helper to send mouse report if application
  ## use template layout report as defined by hid_mouse_report_t
  ## **Parameters:**
  ##
  ## ==========                  ===================
  ## **itf**                     HID interface index.
  ## **id**                      Report index for the interface.
  ## **buttons**                 Which buttons are currently pressed.
  ## **x, y**                    Relative x and y displacement since previous
  ##                             report.
  ## **horizontal, vertical**    Relative horizontal and vertical scroll since
  ##                             previous report.

proc sendGamepadReport*(itf: HidInterface, id: uint8,
    x, y, z, rz, rx, ry: int8, hat: GamepadHatPosition,
    buttons: set[GamepadButton]): bool
    {.importc: "tud_hid_n_gamepad_report".}
  ## Gamepad: convenient helper to send gamepad report if application
  ## use template layout report TUD_HID_REPORT_DESC_GAMEPAD
  ##
  ## ==========   ===================
  ## **itf**      HID interface index.
  ## **id**       Report index for the interface.
  ## **buttons**  Which buttons are currently pressed.
  ## **x, y**     Left analog stick position
  ## **z, rz**    Right analog stick position
  ## **rx, ry**   Left and right analog trigger position
  ## **hat**      Position of gamepad hat or D-Pad
{.pop}

proc sendMouseReport*(itf: HidInterface, id: byte, report: MouseReport): bool =
  ## Convenient helper to send mouse report if application
  ## use template layout report as defined by hid_mouse_report_t
  ## **Parameters:**
  ##
  ## ==========                  ===================
  ## **itf**                     HID interface index.
  ## **id**                      Report index for the interface.
  ## **report**                  `MouseReport` object to send.
  sendReport(itf, id, report.unsafeAddr, sizeof(MouseReport).uint8)

proc sendKeyboardReport*(itf: HidInterface, id: byte, modifiers: set[KeyModifier],
    key0, key1, key2, key3, key4, key5: KeyboardKeypress = keyNone): bool =
  ## Convenient helper to send keyboard report if application
  ## uses template layout report as defined by hid_keyboard_report_t
  ##
  ## ==========     ===================
  ## **itf**        HID interface index.
  ## **id**         Report index for the interface.
  ## **modifiers**  Currently pressed modifier keys
  ## **key0-5**     Up to 6 keys currently pressed

  let keyArr = [key0, key1, key2, key3, key4, key5]
  result = sendKeyboardReport(itf, id, cast[uint8](modifiers), cast[ptr uint8](keyArr.unsafeAddr))

proc sendKeyboardReport*(itf: HidInterface, id: byte, modifiers: set[KeyModifier],
    keys: array[6, KeyboardKeypress]): bool =
  ## Convenient helper to send keyboard report if application
  ## uses template layout report as defined by hid_keyboard_report_t
  ##
  ## ==========     ===================
  ## **itf**        HID interface index.
  ## **id**         Report index for the interface.
  ## **modifiers**  Currently pressed modifier keys
  ## **keys**       Up to 6 keys currently pressed (use `keyNone` if fewer keys are desired)

  var k = keys
  result = sendKeyboardReport(itf, id, cast[uint8](modifiers), cast[ptr uint8](k[0].addr))

proc sendKeyboardReport*(itf: HidInterface, id: byte, report: KeyboardReport): bool =
  ## Convenient helper to send keyboard report if application
  ## uses template layout report as defined by hid_keyboard_report_t
  ##
  ## ==========     ===================
  ## **itf**        HID interface index.
  ## **id**         Report index for the interface.
  ## **report**     `KeyReport` object to send.
  sendReport(itf, id, report.unsafeAddr, sizeof(KeyboardReport).uint8)


# Templates for callback definitions

var calledHidGetReportCallback {.compileTime.} = false
template hidGetReportCallback*(instance, reportId, reportType, buffer, reqLen, body) =
  ## Set the callback to be invoked when an HID GET_REPORT control request is received.
  ##
  ## This is valid for HID device interfaces only. Application must fill buffer
  ## with a valid input report and return its length. Return zero will cause the
  ## stack to STALL request.
  ##
  ## This template must be called exactly once in the application code if an
  ## HID interface is defined (CFG_TUD_HID > 0).
  static:
    when calledHidGetReportCallback:
      {.error: "called hidGetReportCallback twice".}
    calledHidGetReportCallback = true
  proc tudGetReportCb(instance: uint8, reportId: uint8, reportType: HidReportType,
      buffer: ptr uint8, reqLen: uint16): uint16 {.exportC: "tud_hid_get_report_cb", cdecl.} =
    body

var calledHidSetReportCallback {.compileTime.} = false
template hidSetReportCallback*(instance, reportId, reportType, buffer, reqLen, body) =
  ## Set the callback to be invoked when a SET_REPORT control request is received
  ## or when receiving data on OUT endpoint ( Report ID = 0, Type = 0 )
  ##
  ## This template must be called exactly once in the application code if an
  ## HID interface is defined (CFG_TUD_HID > 0).
  static:
    when calledHidSetReportCallback:
      {.error: "called hidSetReportCallback twice".}
    calledHidSetReportCallback = true
  proc tudSetReportCb(instance: uint8, reportId: uint8, reportType: HidReportType,
      buffer: UncheckedArray[byte], reqLen: uint16)
      # Need to use .codegendecl for the `uint8 const*` typedef
      {.exportC, codegendecl: "void tud_hid_set_report_cb(uint8_t instance, uint8_t report_id, hid_report_type_t report_type, uint8_t const* buffer, uint16_t bufsize)".} =
    body

var calledHidReportCompleteCallback {.compileTime.} = false
template hidReportCompleteCallback*(itf, report, len, body) =
  ## Set the callback to be invoked when a HID input report is successfully send to host.
  ##
  ## Application can use this to send the next report
  ## Note: For composite reports, report[0] is report ID
  ## This template is optional but must be called at most once.
  static:
    when calledHidReportCompleteCallback:
      {.error: "called hidReportCompleteCallback twice".}
    calledHidReportCompleteCallback = true
  proc tud_hid_report_complete_cb(itf: uint8, report: UncheckedArray[uint8], len: uint8)
      {.exportc, codegendecl: "void tud_hid_report_complete_cb(uint8_t instance, uint8_t const* report, uint8_t len)".} =
    body

var calledHidDescriptorReportCallback {.compileTime.} = false
template hidDescriptorReportCallback*(body) =
  static:
    when calledHidDescriptorReportCallback:
      {.error: "called hidDescriptorReportCallback twice".}
    calledHidDescriptorReportCallback = true
  proc tudDescriptorReportCb: ptr uint8 {.exportC: "tud_hid_descriptor_report_cb",
      codegendecl: "uint8_t const * $2$3".} =
    body

# HID class-specific Descriptors

# Class and subclass codes used in HID interface descriptors
const
    HidSubclassNone* = 0.UsbSubclassCode
    HidSubclassBoot* = 1.UsbSubclassCode

    HidProtocolMouse* = 1.UsbProtocolCode
    HidProtocolKeyboard* = 2.UsbProtocolCode

type
  HidBootProtocol* {.pure, size: 1} = enum
    None, Mouse, Keyboard

  HidDescriptor* {.packed.} = object
    length*: uint8
    descriptorType*: HidDescriptorType
    hidVersion*: BcdVersion
    country*: HidCountryCode
    numDescriptors*: uint8
    reportDescriptorType*: HidDescriptorType
    reportDescriptorLength*: uint16

  ## Equivalent to descriptor returned by TinyUSB macro `TUD_HID_DESCRIPTOR`
  CompleteHidInterfaceDescriptor* {.packed.} = object
    itf*: InterfaceDescriptor
    hid*: HidDescriptor
    ep*: EndpointDescriptor

static:
  assert sizeof(HidDescriptor) == 9
  assert sizeof(CompleteHidInterfaceDescriptor) == 25

# This module is based on HID spec 1.11
const HidVer = initBcdVersion(1, 11, 0)

func initHidDescriptor*(numDesc: uint8, reportDescType: HidDescriptorType,
                       reportDescLen: uint16, hidVersion=HidVer,
                       country=HidCountryCode.NotSupported): HidDescriptor =
  result = HidDescriptor(
    length: sizeof(HidDescriptor).uint8,
    descriptorType: HidDescriptorType.Hid,
    hidVersion: hidVersion,
    country: country,
    numDescriptors: numDesc,
    reportDescriptorType: reportDescType,
    reportDescriptorLength: reportDescLen
  )

func initCompleteHidInterface*(itf: InterfaceNumber, reportDescLen: uint16,
                               epIn: EpNumber, epInSize: EpSize,
                               epInterval: uint8,
                               bootProtocol: HidBootProtocol = HidBootProtocol.None,
                               str: StringIndex = StringIndexNone
                               ): CompleteHidInterfaceDescriptor =
  let sub = block:
    if bootProtocol == HidBootProtocol.None:
      HidSubclassNone
    else:
      HidSubclassBoot
  let bProto = bootProtocol.ord.UsbProtocolCode

  result = CompleteHidInterfaceDescriptor(

    itf: initInterfaceDescriptor(
      number=itf, alt=0, numEp=1, class=UsbClass.Hid, subclass=sub,
      protocol=bProto, str=str
    ),

    hid: initHidDescriptor(
      numDesc=1,
      reportDescType=HidDescriptorType.Report,
      reportDescLen=reportDescLen
    ),

    ep: initEndpointDescriptor(
      num=epIn, dir=EpDirection.In, xfer=TransferType.Interrupt,
      maxPacketSize=epInSize, interval=epInterval
    )

  )

# Report Descriptors

type
  HidItemPrefix* = distinct uint8

  HidShortItemData* = array[4, uint8]

  HidShortItem* = object
    prefix*: HidItemPrefix
    data*: HidShortItemData

  HidReportDescriptor* = seq[HidShortItem]

  HidItemType* {.pure.} = enum
    Main, Global, Local

  HidGlobalItemTag* {.pure.} = enum
    UsagePage = 0b0000
    LogicalMinimum = 0b0001
    LogicalMaximum = 0b0010
    PhysicalMinimum = 0b0011
    PhysicalMaximum = 0b0100
    UnitExponent = 0b0101
    Unit = 0b0110
    ReportSize = 0b0111
    ReportId = 0b1000
    ReportCount = 0b1001
    Push = 0b1010
    Pop = 0b1011

  HidMainItemTag* {.pure.} = enum
    Input = 0b1000
    Output = 0b1001
    Collection = 0b1010
    Feature = 0b1011
    EndCollection = 0b1100

  HidLocalItemTag* {.pure.} = enum
    Usage = 0b0000
    UsageMinimum = 0b0001
    UsageMaximum = 0b0010
    DesignatorIndex = 0b0011
    DesignatorMinimum = 0b0100
    DesignatorMaximum = 0b0101
    StringIndex = 0b0111
    StringMinimum = 0b1000
    StringMaximum = 0b1001
    Delimiter = 0b1010

  HidCollectionKind* {.pure.} = enum
    Physical = 0x00
    Application = 0x01
    Logical = 0x02
    Report = 0x03
    NamedArray = 0x04
    UsageSwitch = 0x05
    UsageModifier = 0x06

  ShortItemSizeCode = distinct range[0'u8..3'u8]

  HidDataConstant* = enum hidData, hidConstant

  HidArrayVariable* = enum hidArray, hidVariable

  HidBitFieldBuffered* = enum hidBitfield, hidBufferedBytes

  # HidUnitSystem and HidExp are used for the Unit item in report descriptors
  HidUnitSystem* {.pure.} = enum
    None, SiLinear, SiRotation, EnglishLinear, EnglishRotation

  HidExp* = range[-8'i8..7'i8]

template toSizeCode(x: 0..4): ShortItemSizeCode =
  ShortItemSizeCode [0'u8, 1, 2, 255, 3][x]

func itemType(item: HidShortItem): HidItemType =
  HidItemType(item.prefix.uint8.bitsliced(2..3))

func tag(item: HidShortItem): uint8 =
  item.prefix.uint8.bitsliced(4..7)

func size*(p: HidItemPrefix): 0..4 =
  result = p.uint8.bitsliced(0..1)
  if result == 3: result = 4

proc `size=`*(p: var HidItemPrefix, size: 0..4) =
  var tmp = p.uint8
  tmp.clearMask(0..1)
  tmp = tmp or size.toSizeCode.uint8
  p = tmp.HidItemPrefix

func abbreviate(item: HidShortItem): HidShortItem =
  ## Reduce the size code in the item prefix when possible.
  ## HID spec specifies that trailing zero bytes can be omitted is some cases.

  # HID spec v1.11 allows abbreviating down to 0 bytes, but the examples
  # always keep at least 1 byte, so do the same thing.
  const minSize = 1
  if item.prefix.size <= minSize: return item

  # According to HID Usage Tables v 1.3 section 3.1, usage-related tags have
  # different interpretations based on their size, therefore:
  #   - Usage of size 2 bytes denotes an id can be abbreviated to 1
  #   - Usage of size 4 should never be abbreviated as it denotes a combined
  #     usage id and usage page.
  const localItemUsageTags = {
    HidLocalItemTag.Usage.ord,
    HidLocalItemTag.UsageMaximum.ord,
    HidLocalItemTag.UsageMinimum.ord
  }
  if item.itemType == HidItemType.Local and
      item.tag in localItemUsageTags and
      item.prefix.size == 4:
    return item

  # Never abbreviate items when the data is to be interpreted as signed. For example,
  # int16(0x00FF) is +255, but would be interpreted as a negative number (int8) if
  # it was abbreviated to 0xFF.
  #
  # Note: we could make a smart algorithm here that abbreviates to the smallest
  # signed type that can represent the value. But the user can also manually specify
  # the constant of the right type when creating the item.
  const signedDataTags = {
    HidGlobalItemTag.LogicalMinimum.ord, HidGlobalItemTag.LogicalMaximum.ord,
    HidGlobalItemTag.PhysicalMaximum.ord, HidGlobalItemTag.PhysicalMinimum.ord,
    HidGlobalItemTag.UnitExponent.ord
  }
  # Note: all local and main items are always unsigned.
  if item.itemType == HidItemType.Global and item.tag in signedDataTags:
    return item

  # abbreviate: count nonzero bytes and update result size field accordingly
  var sz = item.prefix.size
  while sz > minSize and item.data[sz - 1] == 0:
    dec sz
  # length of data array can only be 0, 1, 2, 4
  if sz == 3: sz = 4
  result = item
  result.prefix.size = sz

proc serialize*(b: var string, item: HidShortItem) =
  ## Create byte string for transmission over the wire of an HID report
  ## descritor item.
  let abbv = abbreviate item
  b.add abbv.prefix.char
  for i in 0 ..< abbv.prefix.size: b.add abbv.data[i].char

proc serialize*(items: seq[HidShortItem]): string =
  ## Create byte string for transmission over the wire of an HID report
  ## descritor consisting of all items in `items`.
  for i in items:
    result.serialize(i)

func initPrefix(size: 0..4, typ: HidItemType, tag:0..0b1111): HidItemPrefix =
  var p: uint8
  p = p or ((typ.ord.uint8 and 0b11) shl 2)
  p = p or ((tag.uint8 and 0b1111) shl 4)
  result = p.HidItemPrefix
  result.size = size

template setbitTo[T: SomeUnsignedInt](x: var T, bit: Natural, val: 0..1) =
  clearbit x, bit
  x = x or (T(val) shl bit)

type HidSignedInt = (int8 | int16 | int32)
type HidInt = (int8 | int16 | int32 | uint8 | uint16 | uint32)

template copyLEBytes(x: (int8 | uint8), dest: var HidShortItemData) =
  dest[0] = (0xFF and x).uint8

template copyLEBytes(x: (int16 | uint16), dest: var HidShortItemData) =
  dest[0] = x.bitsliced(0..7).uint8
  dest[1] = x.bitsliced(8..15).uint8

template copyLEBytes(x: (int32 | uint32), dest: var HidShortItemData) =
  dest[0] = x.bitsliced(0..7).uint8
  dest[1] = x.bitsliced(8..15).uint8
  dest[2] = x.bitsliced(16..23).uint8
  dest[3] = x.bitsliced(24..32).uint8

func globalItem[T: HidInt](tag: HidGlobalItemTag, data: T): HidShortItem =
  result.prefix = initPrefix(sizeof(T), HidItemType.Global, tag.ord)
  copyLEBytes(data, result.data)

func globalItem(tag: HidGlobalItemTag): HidShortItem =
  result.prefix = initPrefix(0, HidItemType.Global, tag.ord)

func localItem[T: HidInt](tag: HidLocalItemTag, data: T): HidShortItem =
  result.prefix = initPrefix(sizeof(T), HidItemType.Local, tag.ord)
  copyLEBytes(data, result.data)

func mainItem(tag: HidMainItemTag, data: uint16): HidShortItem =
  result.prefix = initPrefix(2, HidItemType.Main, tag.ord)
  copyLEBytes(data, result.data)

func mainItem(tag: HidMainItemTag): HidShortItem =
  ## Main item without any data
  HidShortItem(prefix: initPrefix(0, HidItemType.Main, tag.ord))

func inputOutputFeatureData(
    dataOrConst: HidDataConstant, arrayVar: HidArrayVariable,
    absolute, wrap, linear, hasPreferredState, volatile, hasNullState: bool,
    bitfield: HidBitFieldBuffered
    ): uint16 =
  result.setBitTo(0, dataOrConst.ord)
  result.setBitTo(1, arrayVar.ord)
  if not absolute: result.setBit(2)
  if wrap: result.setBit(3)
  if not linear: result.setbit(4)
  if not hasPreferredState: result.setbit(5)
  if hasNullState: result.setbit(6)
  if volatile: result.setbit(7)
  result.setBitTo(8, bitfield.ord)

func hidReportDescItemCollection*(kind: HidCollectionKind): HidShortItem =
  mainItem(HidMainItemTag.Collection, kind.ord.uint16)

func hidReportDescItemEndCollection*: HidShortItem =
  result = mainItem(HidMainItemTag.EndCollection)

func hidReportDescItemInput*(
    dataOrConst: HidDataConstant = hidData,
    arrayVar: HidArrayVariable = hidArray,
    absolute=true,
    wrap=false,
    linear=true,
    hasPreferredState=true,
    hasNullState=false,
    bitfield: HidBitFieldBuffered = hidBitfield
    ): HidShortItem =

  ## Generate Input item in HID report descriptor
  ## Note: the default value of each argument maps to a 0 in the data bitmap

  let data = inputOutputFeatureData(
    dataOrConst, arrayVar, absolute, wrap, linear, hasPreferredState, hasNullState,
    false, bitfield
  )
  result = mainItem(HidMainItemTag.Input, data)

func hidReportDescItemOutput*(
    dataOrConst: HidDataConstant = hidData,
    arrayVar: HidArrayVariable = hidArray,
    absolute=true,
    wrap=false,
    linear=true,
    hasPreferredState=true,
    hasNullState=false,
    volatile=false,
    bitfield: HidBitFieldBuffered = hidBitfield
    ): HidShortItem =
  ## Generate Output item in HID report descriptor
  ## Note: the default value of each argument maps to a 0 in the data bitmap

  let data = inputOutputFeatureData(
    dataOrConst, arrayVar, absolute, wrap, linear, hasPreferredState, hasNullState,
    volatile, bitfield
  )
  result = mainItem(HidMainItemTag.Output, data)

func hidReportDescItemFeature*(
    dataOrConst: HidDataConstant = hidData,
    arrayVar: HidArrayVariable = hidArray,
    absolute=true,
    wrap=false,
    linear=true,
    hasPreferredState=true,
    hasNullState=false,
    volatile=false,
    bitfield: HidBitFieldBuffered = hidBitfield
    ): HidShortItem =
  ## Generate a Feature item in HID report descriptor
  ## Note: the default value of each argument maps to a 0 in the data bitmap
  let data = inputOutputFeatureData(
    dataOrConst, arrayVar, absolute, wrap, linear, hasPreferredState, hasNullState,
    volatile, bitfield
  )
  result = mainItem(HidMainItemTag.Feature, data)

func hidReportDescItemUsagePage*(page: HidUsagePage): HidShortItem =
  globalItem(HidGlobalItemTag.UsagePage, page.ord.uint16)

func hidReportDescItemLogicalMinimum*[T: HidSignedInt](x: T): HidShortItem =
  globalItem(HidGlobalItemTag.LogicalMinimum, x)

func hidReportDescItemLogicalMaximum*[T: HidSignedInt](x: T): HidShortItem =
  globalItem(HidGlobalItemTag.LogicalMaximum, x)

func hidReportDescItemPhysicalMinimum*[T: HidSignedInt](x: T): HidShortItem =
  globalItem(HidGlobalItemTag.PhysicalMinimum, x)

func hidReportDescItemPhysicalMaximum*[T: HidSignedInt](x: T): HidShortItem =
  globalItem(HidGlobalItemTag.PhysicalMaximum, x)

func hidReportDescItemUnitExponent*[T: HidSignedInt](x: T): HidShortItem =
  globalItem(HidGlobalItemTag.UnitExponent, x)

func hidReportDescItemUnit*(sys: HidUnitSystem, length, mass, time, temp,
                           current, lum: HidExp = 0): HidShortItem =
  var u = sys.ord.uint32
  u = u or ((0x0F and length)  shl 4).uint32
  u = u or ((0x0F and mass)    shl 8).uint32
  u = u or ((0x0F and time)    shl 12).uint32
  u = u or ((0x0F and temp)    shl 16).uint32
  u = u or ((0x0F and current) shl 20).uint32
  u = u or ((0x0F and lum)     shl 24).uint32
  result = globalItem(HidGlobalItemTag.Unit, u)

func hidReportDescItemReportSize*(bits: uint32): HidShortItem =
  ## Set size of each report field in bits
  globalItem(HidGlobalItemTag.ReportSize, bits)

func hidReportDescItemReportId*(id: 1'u8..uint8.high): HidShortItem =
  ## Report ID for descriptors with multiple reports
  globalItem(HidGlobalItemTag.ReportId, id)

func hidReportDescItemReportCount*(count: uint32): HidShortItem =
  ## Set number of fields in report
  globalItem(HidGlobalItemTag.ReportCount, count)

func hidReportDescItemPush*: HidShortItem =
  ## Instruct the report descriptor parser to push the current global item
  ## state to a stack.
  globalItem(HidGlobalItemTag.Push)

func hidReportDescItemPop*: HidShortItem =
  ## Instruct the report descriptor parser to replace the current global item
  ## state with the structure currently on top of the stack.
  globalItem(HidGlobalItemTag.Pop)

proc toUint32(u: HidUsage): uint32 =
  u.id.uint32 or (u.page.ord.uint32 shl 8)

func hidReportDescItemUsage*(u: HidUsage): HidShortItem =
  ## Set the fully qualified (page + id)  usage
  localItem(HidLocalItemTag.Usage, u.toUint32)

func hidReportDescItemUsage*(id: uint16): HidShortItem =
  ## Set the usage id to be concatenated with the previously set Usage Page
  localItem(HidLocalItemTag.Usage, id)

func hidReportDescItemUsageMinimum*(u: HidUsage): HidShortItem =
  ## Defines the starting usage id associated with an array or bitmap.
  localItem(HidLocalItemTag.UsageMinimum, u.toUint32)

func hidReportDescItemUsageMinimum*(id: uint16): HidShortItem =
  ## Defines the starting usage id associated with an array or bitmap.
  localItem(HidLocalItemTag.UsageMinimum, id)

func hidReportDescItemUsageMaximum*(u: HidUsage): HidShortItem =
  ## Defines the starting usage id associated with an array or bitmap.
  localItem(HidLocalItemTag.UsageMaximum, u.toUint32)

func hidReportDescItemUsageMaximum*(id: uint16): HidShortItem =
  ## Defines the starting usage id associated with an array or bitmap.
  localItem(HidLocalItemTag.UsageMaximum, id)

func hidReportDescItemDesignatorIndex*(id: uint16): HidShortItem =
  ## Determines the body part used for a control. Index points to a designator
  ## in the Physical descriptor.
  localItem(HidLocalItemTag.DesignatorIndex, id)

func hidReportDescItemDesignatorMinimum*(id: uint16): HidShortItem =
  ## Defines the index of the starting designator associated with an array or
  ## bitmap.
  localItem(HidLocalItemTag.DesignatorMinimum, id)

func hidReportDescItemDesignatorMaximum*(id: uint16): HidShortItem =
  ## Defines the index of the ending designator associated with an array or
  ## bitmap.
  localItem(HidLocalItemTag.DesignatorMaximum, id)

func hidReportDescItemStringIndex*(id: StringIndex): HidShortItem =
  localItem(HidLocalItemTag.StringIndex, id.uint8)

func hidReportDescItemStringMinimum*(id: StringIndex): HidShortItem =
  localItem(HidLocalItemTag.StringMinimum, id.uint8)

func hidReportDescItemStringMaximum*(id: StringIndex): HidShortItem =
  localItem(HidLocalItemTag.StringMaximum, id.uint8)

func hidReportDescItemDelimiter*(x: 0'u8..1'u8): HidShortItem =
  localItem(HidLocalItemTag.Delimiter, x)

macro idents2Nodes(ids: varargs[untyped]): untyped =
  var brack = nnkBracket.newTree
  for node in ids:
    let name = $node
    brack.add:
      genAst(name):
        ident(name)
  result = brack

func genAliases: seq[NimNode] {.compiletime.} =
  let allItemProcs = idents2Nodes(
    hidReportDescItemInput,
    hidReportDescItemOutput,
    hidReportDescItemUsagePage,
    hidReportDescItemLogicalMaximum,
    hidReportDescItemLogicalMinimum,
    hidReportDescItemPhysicalMaximum,
    hidReportDescItemPhysicalMinimum,
    hidReportDescItemUnit,
    hidReportDescItemUnitExponent,
    hidReportDescItemReportSize,
    hidReportDescItemReportId,
    hidReportDescItemReportCount,
    hidReportDescItemReportPush,
    hidReportDescItemReportPop,
    hidReportDescItemUsage,
    hidReportDescItemUsageMinimum,
    hidReportDescItemUsageMaximum,
    hidReportDescItemDesignatorIndex,
    hidReportDescItemDesignatorMinimum,
    hidReportDescItemDesignatorMaximum,
    hidReportDescItemStringIndex,
    hidReportDescItemStringMinimum,
    hidReportDescItemStringMaximum,
    hidReportDescItemStringDelimiter,
  )
  for procIdent in allItemProcs:
    let shortIdent = block:
      var s = ($procIdent).replace("hidReportDescItem", "")
      s[0] = s[0].toLowerAscii
      ident s
    result.add:
      genAst(s=shortIdent, l=procIdent):
        template s(args: varargs[untyped]): auto = l(args)

func addAlltoSeq(seqIdent: NimNode, items: seq[NimNode]): NimNode =
  result = newStmtList()
  result.add:
    genAst(itemSeq=seqIdent):
      var itemSeq: seq[HidShortItem]
  for itemExpr in items:
    result.add newCall("add", seqIdent, itemExpr)

macro collection*(kind: static[HidCollectionKind], inner: untyped): untyped =
  ## Meant for use inside the `hidReportDesc` macro. Inserts the items in
  ## `inner`, wrapped in `Collection(kind)` and EndCollection items.
  var itemStmts: seq[NimNode]
  itemStmts.add newCall("hidReportDescItemCollection", kind.newLit)
  for child in inner:
    itemStmts.add child
  itemStmts.add newCall("hidReportDescItemEndCollection")

  let itemSeqSym = genSym(nskVar)
  var blockbody = addAlltoSeq(itemSeqSym, itemStmts)
  blockbody.add itemSeqSym
  result = newBlockStmt(blockbody)

macro hidReportDesc*(inner: untyped): string =
  ## Create an HID report descriptor.
  ## 
  ## Each statement in `inner` must be either an `HidShortItem` object, or a
  ## seq of `HidShortItem`. All items are concatenated in a flat manner and
  ## serialized to a byte string.

  var blockbody = newStmtList()
  for p in genAliases():
    blockbody.add p

  let itemSeqSym = genSym(nskVar)
  block:
    var innerChildren: seq[NimNode]
    for c in inner:
      innerChildren.add c
    addAlltoSeq(itemSeqSym, innerChildren).copyChildrenTo(blockbody)

  blockbody.add newCall(bindsym"serialize", itemSeqSym)
  result = newBlockStmt(blockbody)

func keyboardReportDescriptor*(id = -1): string =
  ## Create HID report descriptor for a keyboard.
  ## 
  ## Meant to be used in conjunction with `KeyboardReport` and
  ## `sendKeyboardReport`. If `id` is greater than zero, a "Report ID" item
  ## will be included, with the given ID, otherwise it is omitted.

  hidReportDesc:
    usagePage(HidUsagePage.GenericDesktopControls)
    usage(hidUsageGenericDesktopControlsKeyboard.id)
    collection(HidCollectionKind.Application):
      # Optional Report ID
      if id > 0: @[reportId(id.uint8)] else: @[]

      # 8-bit bitfield for modifier keys
      usagePage(HidUsagePage.Keyboard)
      usageMinimum(224)
      usageMaximum(231)
      logicalMinimum(0i8)
      logicalMaximum(1i8)
      reportCount(8)
      reportSize(1)
      input(hidData, hidVariable, absolute=true)

      # 8 bits padding (?)
      reportCount(1)
      reportSize(8)
      input(hidConstant)

      # 5-bit output report to set LEDs
      usagePage(HidUsagePage.LEDs)
      usageMinimum(1)
      usageMaximum(5)
      reportCount(5)
      reportSize(1)
      output(hidData, hidVariable, absolute=true)

      # 3 bits padding for byte alignment
      reportCount(1)
      reportSize(3)
      output(hidConstant)

      # 6X 1-byte keycode
      usagePage(HidUsagePage.Keyboard)
      usageMinimum(0)
      usageMaximum(255)
      logicalMinimum(0i8)
      logicalMaximum(255i16)
      reportCount(6)
      reportSize(8)
      input(hidData, hidArray, absolute=true)

func mouseReportDescriptor*(id = -1): string =
  ## Create HID report descriptor for a mouse.
  ##
  ## Meant to be used in conjunction with `MouseReport` and
  ## `sendMouseReport`. If `id` is greater than zero, a "Report ID" item
  ## will be included, with the given ID, otherwise it is omitted.

  hidReportDesc:
    usagePage(HidUsagePage.GenericDesktopControls)
    usage(hidUsageGenericDesktopControlsMouse.id)
    collection(HidCollectionKind.Application):
      # Optional Report ID
      if id > 0: @[reportId(id.uint8)] else: @[]

      usage(hidUsageGenericDesktopControlsPointer.id)
      collection(HidCollectionKind.Physical):

        # 5 buttons: left, right, middle, back, forward
        usagePage(HidUsagePage.Buttons)
        usageMinimum(1)
        usageMaximum(5)
        logicalMinimum(0i8)
        logicalMaximum(1i8)
        reportCount(5)
        reportSize(1)
        input(hidData, hidVariable, absolute=true)

        # 3 bits padding for byte alignment
        reportCount(1)
        reportSize(3)
        input(hidConstant)

        # X, Y movement -127 to 127
        usagePage(HidUsagePage.GenericDesktopControls)
        usage(hidUsageGenericDesktopControlsDirectionX.id)
        usage(hidUsageGenericDesktopControlsDirectionY.id)
        logicalMinimum(-127i8)
        logicalMaximum(127i8)
        reportCount(2)
        reportSize(8)
        input(hidData, hidVariable, absolute=false)

        # Vertical scroll wheel -127 to 127
        usage(hidUsageGenericDesktopControlsWheel.id)
        logicalMinimum(-127i8)
        logicalMaximum(127i8)
        reportCount(1)
        reportSize(8)
        input(hidData, hidVariable, absolute=false)

        # Vertical scroll wheel -127 to 127
        usagePage(HidUsagePage.Consumer)
        usage(hidUsageConsumerACPan.id)
        logicalMinimum(-127i8)
        logicalMaximum(127i8)
        reportCount(1)
        reportSize(8)
        input(hidData, hidVariable, absolute=false)

func gamepadReportDescriptor*(id = -1): string =
  ## Create HID report descriptor for a gamepad.
  ##
  ## Meant to be used in conjunction with `sendGamepadReport`. If `id` is
  ## greater than zero, a "Report ID" item will be included, with the given ID,
  ## otherwise it is omitted.

  hidReportDesc:
    usagePage(HidUsagePage.GenericDesktopControls)
    usage(hidUsageGenericDesktopControlsGamepad.id)
    collection(HidCollectionKind.Application):
      # Optional Report ID
      if id > 0: @[reportId(id.uint8)] else: @[]

      # 1-byte X, Y, Z, RX, RY, RZ, [127, -127]
      usagePage(HidUsagePage.GenericDesktopControls)
      usage(hidUsageGenericDesktopControlsDirectionX.id)
      usage(hidUsageGenericDesktopControlsDirectionY.id)
      usage(hidUsageGenericDesktopControlsDirectionZ.id)
      usage(hidUsageGenericDesktopControlsRotateZ.id)
      usage(hidUsageGenericDesktopControlsRotateX.id)
      usage(hidUsageGenericDesktopControlsRotateY.id)
      logicalMinimum(-127i8)
      logicalMaximum(127i8)
      reportCount(6)
      reportSize(8)
      input(hidData, hidVariable, absolute=true)

      # 8-bit D-Pad / Hat button map
      usagePage(HidUsagePage.GenericDesktopControls)
      usage(hidUsageGenericDesktopControlsHatSwitch.id)
      logicalMinimum(1i8)
      logicalMaximum(8i8)
      physicalMinimum(0i8)
      physicalMaximum(315i16)
      reportCount(1)
      reportSize(8)
      input(hidData, hidVariable, absolute=true)

      # 32-bit button map
      usagePage(HidUsagePage.Buttons)
      usageMinimum(1)
      usageMaximum(32)
      logicalMinimum(0i8)
      logicalMaximum(1i8)
      reportCount(32)
      reportSize(1)
      input(hidData, hidVariable, absolute=true)

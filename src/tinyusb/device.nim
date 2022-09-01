import ./common
import ./langids
import encode # https://github.com/treeform/encode

{.push header: "tusb.h".}

proc usbDeviceTask* {.importC: "tud_task".}
## Task function to be called frequently in main loop.

proc usbDeviceConnected*: bool {.importc: "tud_connected".}
## Check if device is connected (may not mounted/configured yet)
## True if just got out of Bus Reset and received the very first data from host

proc usbDeviceMounted*: bool {.importC: "tud_mounted".}
## Check if device is connected and configured

proc usbDeviceSuspended*: bool {.importC: "tud_suspended".}
## Check if device is suspended

proc usbDeviceRemoteWakeup*: bool {.importC: "tud_remote_wakeup".}
## Remote wake up host, only if suspended and enabled by host

proc usbDeviceDisconnect*: bool {.importC: "tud_disconnect".}
## Enable pull-up resistor on D+ D-
## Return false on unsupported MCUs

proc usbDeviceConnect*: bool {.importC: "tud_connect".}
## Disable pull-up resistor on D+ D-
## Return false on unsupported MCUs

{.pop.}

# Device Descriptor configuration

type
  UsbClass* {.size: sizeof(cchar), pure.} = enum
    Unspecified = 0 # Use when the class is defined by the interface descriptor(s)
    Audio = 1
    Cdc = 2
    Hid = 3
    Reserved_4 = 4
    Physical = 5
    Image = 6
    Printer = 7
    Msc = 8
    Hub = 9
    CdcData = 10
    SmartCard = 11
    Reserved_12 = 12
    ContentSecurity = 13
    Video = 14
    PersonalHealthcare = 15
    AudioVideo = 16
    Diagnostic = 0xdc
    WirelessController = 0xe0
    Misc = 0xef
    ApplicationSpecific = 0xfe
    VendorSpecific = 0xff

  UsbDescriptorType* {.size: sizeof(cchar), pure.} = enum
    Device = 0x01
    Configuration = 0x02
    DtString = 0x03
    DtInterface = 0x04
    Endpoint = 0x05
    Qualifier = 0x06
    OtherSpeedConfig = 0x07
    InterfacePower = 0x08
    Otg = 0x09
    Debug = 0x0A
    InterfaceAssociation = 0x0B
    Bos = 0x0f
    DeviceCapabillity = 0x10
    Functional = 0x21
    CsConfig = 0x22
    CsString = 0x23
    CsInterface = 0x24
    CsEndPoint = 0x25
    SuperSpeedEndpointComp = 0x30
    SuperSpeedIsoEndpointComp = 0x31

  # Binary-Coded Decimal major/minor version used in USB descriptors
  BcdVersion* = distinct uint16

  Ep0MaxPacketSize* {.size: sizeof(cchar), pure} = enum
    Size8 = 8
    Size16 = 16
    Size32 = 32
    Size64 = 64

  ConfigurationAttribute* {.size: sizeof(cchar), pure} = enum
    Reserved0 # Reserved 0-4 should always be 0 per USB 2.0 spec
    Reserved1
    Reserved2
    Reserved3
    Reserved4
    RemoteWakeup
    SelfPowered
    Reserved7 # Should always be set per USB 2.0 spec

  EpDirection* {.pure.} = enum
    Out = 0
    In = 1

  TransferType* {.pure.} = enum
    Control = 0b00
    Isochronous = 0b01
    Bulk = 0b10
    Interrupt = 0b11

  IsoSyncType* {.pure.} = enum
    None = 0b00
    Async = 0b01
    Adaptive = 0b10
    Sync = 0b11

  IsoUsageType* {.pure.} = enum
    Data = 0b00
    Feedback = 0b01
    Implicit = 0b10

  AdditionalTransactions* {.pure.} = enum
    None = 0b00
    add1 = 0b01
    add2 = 0b10

  EpAddress* = distinct uint8
  EpAttributes* = distinct uint8
  EpDescMaxPacketSize* = distinct uint16

static:
  assert sizeof(set[ConfigurationAttribute]) == 1

func initBcdVersion*(major: 0..255, minor: 0..15, sub: 0..15): BcdVersion =
  BcdVersion((major.uint16 shl 8) or (minor.uint16 shl 4) or sub.uint16)

func initEndpointAddress*(epnum: 0..15, dir: EpDirection): EpAddress =
  EpAddress epnum.ord.uint8 or (dir.ord.uint8 shl 7)

func initEndpointAttributes*(xfer: TransferType,
                             sync: IsoSyncType = IsoSyncType.None,
                             usage: IsoUsageType = IsoUsageType.Data):
                             EpAttributes =
  var val = xfer.ord.uint8
  if xfer == TransferType.Isochronous:
      val = val or (sync.ord.uint8 shl 2) or (usage.ord.uint8 shl 4)
  result = EpAttributes val

func initEndpointDescMaxPacketSize*(
    size: 0..2047,
    addTransactions: AdditionalTransactions = AdditionalTransactions.None):
    EpDescMaxPacketSize =
  EpDescMaxPacketSize (size or (addTransactions.uint8.ord shl 11))

func initConfigAttributes*(remoteWakeup: bool = false,
                           selfPowered: bool = false):
                           set[ConfigurationAttribute] =
  # According to USB 2.0 spec, bit D7 must always be one
  result = {ConfigurationAttribute.Reserved7}
  if remoteWakeup: result.incl ConfigurationAttribute.RemoteWakeup
  if selfPowered: result.incl ConfigurationAttribute.SelfPowered


# Generic protocol codes, applicable for any class/subclass
const
  UsbProtocolNone* = 0.UsbProtocolCode
  UsbProtocolVendorSpecific* = 0xFF.UsbProtocolCode

{.push header: "tusb.h".}
type
  DeviceDescriptor* {.packed, importc: "tusb_desc_device_t", completeStruct.} = object
    length*: uint8
    descriptorType*: UsbDescriptorType
    usbVersion*: BcdVersion
    class*: UsbClass
    subclass*: UsbSubclassCode
    protocol*: UsbProtocolCode
    maxPacketSize*: Ep0MaxPacketSize
    vendorId*: uint16
    productId*: uint16
    deviceVersion*: BcdVersion
    manufacturerStr*: StringIndex
    productStr*: StringIndex
    serialNumberStr: StringIndex
    numConfigurations*: uint8

  ConfigurationDescriptor* {.packed, importc: "tusb_desc_configuration_t", completeStruct.} = object
    length*: uint8
    descriptorType*: UsbDescriptorType
    totalLength*: uint16
    numInterfaces*: uint8
    value*: ConfigurationValue
    str*: StringIndex
    attributes*: set[ConfigurationAttribute]
    maxPower*: uint8 # Each increment is 2 mA

  InterfaceDescriptor* {.packed, importc: "tusb_desc_interface_t", completeStruct.} = object
    length*: uint8
    descriptorType*: UsbDescriptorType
    number*: InterfaceNumber # zero-based index of this IF for the configuration
    alternateSetting*: uint8
    numEndpoints*: uint8
    class*: UsbClass
    subclass*: UsbSubclassCode
    protocol*: UsbProtocolCode
    str*: StringIndex

  EndpointDescriptor* {.packed, importc: "tusb_desc_endpoint_t", completeStruct.} = object
    length*: uint8
    descriptorType*: UsbDescriptorType
    address*: EpAddress
    attributes*: EpAttributes
    maxPacketSize*: EpDescMaxPacketSize
    interval: uint8
{.pop.}

static:
  assert DeviceDescriptor.sizeof == 18, "Incorrect type size"
  assert ConfigurationDescriptor.sizeof == 9, "Incorrect type size"
  assert InterfaceDescriptor.sizeof == 9, "Incorrect type size"
  assert EndpointDescriptor.sizeof == 7, "Incorrect type size"


# String descriptors

proc initStringDesc0*[N](langs: openArray[LangId],
                         dest: var array[N, uint8]) =
  ## Create string descriptor zero, which is the
  ##
  ## The result is put into the byte array `dest`, which should be at least of
  ## size `langs.len * 2 + 2`, otherwise the list of languages will be
  ## truncated.
  let
    langsSize = sizeof(LangId) * langs.len

    # The bitwise and here results in the next lower multiple of 2, to ensure
    # that we don't cut a langid in half if we truncate.
    descLen = uint8(
      min([uint8.high.int, langsSize + 2, dest.len]) and (not 1)
    )

  dest[0] = descLen.uint8
  dest[1] = UsbDescriptorType.DtString.ord
  copyMem(dest[2].addr, langs[0].unsafeAddr, (descLen - 2))

func initStringDesc*[N](str: string, dest: var array[N, uint8]) =
  ## Create a string descriptor from a utf8 string.
  ##
  ## The result is put into the byte array `dest`, which should be large enough
  ## to fit string `str` encoded as UTF-16LE, otherwise the string will be
  ## truncated to fit.
  let
    utf16str = str.toUTF16LE

    # The bitwise and here results in the next lower multiple of 2, to ensure
    # that we don't cut a codepoint in half (only works for 2-byte characters)
    descLen = uint8(
      min([uint8.high.int, (utf16str.len + 2), dest.len]) and (not 1)
    )

  dest[0] = descLen.uint8
  dest[1] = UsbDescriptorType.DtString.ord
  copyMem(dest[2].addr, utf16str[0].unsafeAddr, (descLen - 2))

func getUtf8String*(strDesc: openArray[uint8]): string =
  ## Utility function to extract a UTF-8 string from a USB String Descriptor
  let utf16len = strDesc[0] - 2
  var tmp = newString(utf16len)
  copyMem(tmp[0].addr, strDesc[2].unsafeAddr, utf16len)
  result = fromUTF16LE tmp


# Templates for callback definitions

var calledMountCallback {.compileTime.} = false
template mountCallback*(body: untyped): untyped =
  ## Set the callback to be invoked when device is mounted (configured)
  ##
  ## This template is optional but must be called at most once.
  static:
    when calledMountCallback:
      {.error: "called mountCallback twice".}
    calledMountCallback = true
  proc tudMountCb{.exportC: "tud_mount_cb", codegendecl: "$1 $2$3".} =
    body

var calledUnmountCallback {.compileTime.} = false
template unmountCallback*(body: untyped): untyped =
  ## Set the callback to be invoked when device is unmounted
  ##
  ## This template is optional but must be called at most once.
  static:
    when calledUnmountCallback:
      {.error: "called unmountCallback twice".}
    calledUnmountCallback = true
  proc tudUnmountCb{.exportC: "tud_umount_cb", codegendecl: "$1 $2$3".} =
    body

var calledSuspendCallback {.compileTime.} = false
template suspendCallback*(boolName, body: untyped): untyped =
  ## Set the callback to beinvoked when usb bus is suspended
  ##
  ## According to USB spec, within 7ms, device must draw a current less than 2.5
  ## mA from bus.
  ##
  ## This template is optional but must be called at most once.
  static:
    when calledSuspendCallback:
      {.error: "called suspendCallback twice".}
    calledSuspendCallback = true
  proc tudSuspendCb(boolName: bool){.exportC: "tud_suspend_cb", codegendecl: "$1 $2$3".} =
    body

var calledResumeCallback {.compileTime.} = false
template resumeCallback*(body: untyped): untyped =
  ## Set the callback to be invoked when device is resumed from suspend
  ##
  ## This template is optional but must be called at most once.
  static:
    when calledResumeCallback:
      {.error: "called resumeCallback twice".}
    calledResumeCallback = true
  proc tudResumeCb*{.exportC: "tud_resume_cb", codegendecl: "$1 $2$3".} =
    body

var calledSetDeviceDescriptor {.compileTime.} = false
template setDeviceDescriptor*(dd: static[DeviceDescriptor]) =
  ## Set the device descriptor to be returned on a GET_DEVICE_DESCRIPTOR request
  ##
  ## This template generates a proc that returns a pointer to the descriptor.
  ## This template must be called exactly once in the application code.
  static:
    when calledSetDeviceDescriptor:
      {.error: "Device descriptor set more than once".}
    calledSetDeviceDescriptor = true
  let desc = dd
  proc tudDescriptorDeviceCb: ptr uint8 {.exportC: "tud_descriptor_device_cb",
      codegendecl: "uint8_t const * $2$3".} =
    result = cast[ptr uint8](desc.unsafeAddr)

var calledConfigurationDescritptorCallback {.compileTime.} = false
template configurationDescriptorCallback*(index, body) =
  static:
    when calledConfigurationDescritptorCallback:
      {.error: "called configurationDescriptorCallback twice".}
    calledConfigurationDescritptorCallback = true
  proc tudDescriptorConfigCb(index: byte): ptr uint8 {.exportC: "tud_descriptor_configuration_cb",
      codegendecl: "uint8_t const * $2$3".} =
    body

var calledDeviceDescriptorStringCallback {.compileTime.} = false
template deviceDescriptorStringCallback*(index, langId, body) =
  static:
    when calledDeviceDescriptorStringCallback:
      {.error: "called deviceDescriptorStringCallback twice".}
    calledDeviceDescriptorStringCallback = true
  proc tudDescriptorStringCb(index: byte, langId: uint16): ptr uint16 {.
      exportC: "tud_descriptor_string_cb", codegendecl: "uint16_t const * $2$3".} =
    body

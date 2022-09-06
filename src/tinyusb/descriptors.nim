import ./langids
import encode # https://github.com/treeform/encode

type
  UsbSubclassCode* = distinct uint8

  UsbProtocolCode* = distinct uint8

  StringIndex* = distinct uint8
  
  InterfaceNumber* = distinct uint8

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
    String = 0x03
    Interface = 0x04
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

  EpMaxPacketSize* = distinct uint16

static:
  assert sizeof(set[ConfigurationAttribute]) == 1

func initBcdVersion*(major: 0..255, minor: 0..15, sub: 0..15): BcdVersion =
  BcdVersion((major.uint16 shl 8) or (minor.uint16 shl 4) or sub.uint16)

func initEpAddress*(epnum: 0..15, dir: EpDirection): EpAddress =
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
    EpMaxPacketSize =
  EpMaxPacketSize (size or (addTransactions.uint8.ord shl 11))

func initConfigAttributes*(remoteWakeup: bool = false,
                           selfPowered: bool = false):
                           set[ConfigurationAttribute] =
  # According to USB 2.0 spec, bit D7 must always be one
  result = {ConfigurationAttribute.Reserved7}
  if remoteWakeup: result.incl ConfigurationAttribute.RemoteWakeup
  if selfPowered: result.incl ConfigurationAttribute.SelfPowered

const StringIndexNone* = 0.StringIndex

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
    ep0MaxPacketSize*: Ep0MaxPacketSize
    vendorId*: uint16
    productId*: uint16
    deviceVersion*: BcdVersion
    manufacturerStr*: StringIndex
    productStr*: StringIndex
    serialNumberStr*: StringIndex
    numConfigurations*: uint8

  ConfigurationDescriptor* {.packed, importc: "tusb_desc_configuration_t", completeStruct.} = object
    length*: uint8
    descriptorType*: UsbDescriptorType
    totalLength*: uint16
    numInterfaces*: uint8
    value*: uint8
    str*: StringIndex
    attributes*: set[ConfigurationAttribute]
    maxPower*: uint8 # Each increment is 2 mA

  InterfaceDescriptor* {.packed, importc: "tusb_desc_interface_t", completeStruct.} = object
    length*: uint8
    descriptorType*: UsbDescriptorType
    number*: InterfaceNumber # zero-based index of this IF for the configuration
    alternate*: uint8
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
    maxPacketSize*: EpMaxPacketSize
    interval: uint8
{.pop.}

type
  InterfaceAssociationDescriptor* {.packed.} = object
    length*: uint8
    descriptorType*: UsbDescriptorType
    firstInterface*: InterfaceNumber
    interfaceCount*: uint8
    class*: UsbClass
    subclass*: UsbSubclassCode
    protocol*: UsbProtocolCode
    str*: StringIndex

static:
  assert DeviceDescriptor.sizeof == 18, "Incorrect type size"
  assert ConfigurationDescriptor.sizeof == 9, "Incorrect type size"
  assert InterfaceDescriptor.sizeof == 9, "Incorrect type size"
  assert EndpointDescriptor.sizeof == 7, "Incorrect type size"
  assert InterfaceAssociationDescriptor.sizeof == 8, "Incorrect type size"

func initDeviceDescriptor*(
    usbVersion: BcdVersion, class: UsbClass, subclass: UsbSubclassCode,
    protocol: UsbProtocolCode, ep0Size: Ep0MaxPacketSize, vendorId: uint16,
    productId: uint16, deviceVersion: BcdVersion, manufacturerStr: StringIndex,
    productStr: StringIndex, serialNumberStr: StringIndex, numConfigurations: 1..255
    ): DeviceDescriptor =
  DeviceDescriptor(
    length: sizeof(DeviceDescriptor).uint8,
    descriptorType: UsbDescriptorType.Device,
    usbVersion: usbVersion,
    class: class,
    subclass: subclass,
    protocol: protocol,
    ep0MaxPacketSize: ep0Size,
    vendorId: vendorId,
    productId: productId,
    deviceVersion: deviceVersion,
    manufacturerStr: manufacturerStr,
    productStr: productStr,
    serialNumberStr: serialNumberStr,
    numConfigurations: numConfigurations.uint8
  )

func initConfigurationDescriptor*(
    val: uint8, totalLength: uint16, numItf: 1..255, powerma: 0..500,
    str: StringIndex = StringIndexNone, remoteWakeup=false, selfPowered=false
    ): ConfigurationDescriptor =
  ConfigurationDescriptor(
    length: sizeof(ConfigurationDescriptor).uint8,
    descriptorType: UsbDescriptorType.Configuration,
    totalLength: totalLength,
    numInterfaces: numItf.uint8,
    value: val,
    str: str,
    attributes: initConfigAttributes(remoteWakeup, selfPowered),
    maxPower: (powerma div 2).uint8
  )

func initInterfaceDescriptor*(number: InterfaceNumber, alt: uint8, numEp: 1..255,
                              class: UsbClass, subclass: UsbSubclassCode,
                              protocol: UsbProtocolCode,
                              str: StringIndex = StringIndexNone
                             ): InterfaceDescriptor =
  InterfaceDescriptor(
    length: sizeof(InterfaceDescriptor).uint8,
    descriptorType: UsbDescriptorType.Interface,
    number: number,
    alternate: alt,
    numEndpoints: numEp.uint8,
    class: class,
    subclass: subclass,
    protocol: protocol,
    str: str
  )

func initInterfaceAssociationDescriptor*(first: InterfaceNumber, count: uint8,
                                         class: UsbClass,
                                         subclass: UsbSubclassCode,
                                         protocol: UsbProtocolCode,
                                         str: StringIndex = StringIndexNone
                                         ): InterfaceAssociationDescriptor =
  InterfaceAssociationDescriptor(
    length: sizeof(InterfaceAssociationDescriptor).uint8,
    descriptorType: UsbDescriptorType.InterfaceAssociation,
    firstInterface: first,
    interfaceCount: count,
    class: class,
    subclass: subclass,
    protocol: protocol,
    str: str
  )

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
  dest[1] = UsbDescriptorType.String.ord
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
  dest[1] = UsbDescriptorType.String.ord
  copyMem(dest[2].addr, utf16str[0].unsafeAddr, (descLen - 2))

func getUtf8String*(strDesc: openArray[uint8]): string =
  ## Utility function to extract a UTF-8 string from a USB String Descriptor
  let utf16len = strDesc[0] - 2
  var tmp = newString(utf16len)
  copyMem(tmp[0].addr, strDesc[2].unsafeAddr, utf16len)
  result = fromUTF16LE tmp


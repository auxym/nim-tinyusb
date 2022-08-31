import tinyusb/common

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

static:
  assert sizeof(set[ConfigurationAttribute]) == 1

func createBcdVersion*(major: 0..255, minor: 0..15, sub: 0..15): BcdVersion {.compileTime.} =
  BcdVersion((major.uint16 shl 8) or (minor.uint16 shl 4) or sub.uint16)

func configFlags*(remoteWakeup: bool = false, selfPowered: bool = false):
    set[ConfigurationAttribute] =
  # According to USB 2.0 spec, bit D7 must always be one
  result = {ConfigurationAttribute.Reserved7}
  if remoteWakeup: result.incl ConfigurationAttribute.RemoteWakeup
  if selfPowered: result.incl ConfigurationAttribute.SelfPowered

# Subclass and protocol codes for the Misc class
const
  # Subclass 0x01
  UsbMiscSubclassSync* = 1.UsbSubclassCode
  UsbMiscProtocolActiveSync* = 1.UsbProtocolCode
  UsbMiscProtocolPalmSync* = 2.UsbProtocolCode

  # Subclass 0x02
  UsbMiscSubclassIad* = 2.UsbSubclassCode # Interface Association Descriptor
  UsbMiscProtocolIad* = 1.UsbProtocolCode # Interface Association Descriptor
  UsbMiscProtocolWamp* = 2.UsbProtocolCode # Wire Adapter Multifunction Peripheral

  # Subclass 0x03
  UsbMiscSubclassCbaf* = 3.UsbSubclassCode # Cable Based Association Framework
  UsbMiscProtocolCbaf* = 1.UsbProtocolCode # Cable Based Association Framework

  # Subclass 0x04
  UsbMiscSubclassRndis* = 4.UsbSubclassCode # RNDIS
  UsbMiscProtocolRndisEth* = 1.UsbProtocolCode # RNDIS over Ethernet
  UsbMiscProtocolRndisWifi* = 2.UsbProtocolCode # RNDIS over WiFi
  UsbMiscProtocolRndisWimax* = 3.UsbProtocolCode # RNDIS over WiMax
  UsbMiscProtocolRndisWwan* = 4.UsbProtocolCode # RNDIS over WWAN
  UsbMiscProtocolRndisIpv4* = 5.UsbProtocolCode # RNDIS over IPv4
  UsbMiscProtocolRndisIpv6* = 6.UsbProtocolCode # RNDIS over IPv6
  UsbMiscProtocolRndisGprs* = 7.UsbProtocolCode # RNDIS over GPRS

  # Subclass 0x05
  # Machine Vision Device conforming to the USB3 Vision specification
  UsbMiscSubclassUsb3Vision* = 5.UsbSubclassCode
  UsbMiscProtocolVisionControl* = 0.UsbProtocolCode # USB3 Vision Control Interface
  UsbMiscProtocolVisionEvent* = 1.UsbProtocolCode # USB3 Vision Event Interface
  UsbMiscProtocolVisionStreaming* = 2.UsbProtocolCode # USB3 Vision Streaming Interface

  # Subclass 0x06
  UsbMiscSubclassStep* = 6.UsbSubclassCode
  UsbMiscProtocolStepStream* = 0.UsbProtocolCode # STEP.Stream Transport Efficient Protocol
  UsbMiscProtocolStepRaw* = 1.UsbProtocolCode # STEP RAW. Stream Transport Efficient Protocol 

  # Subclass 0x07
  UsbMiscSubclassDvb* = 7.UsbSubclassCode
  UsbMiscProtocolDvbCiInIad* = 0.UsbProtocolCode
  UsbMiscProtocolDvbCiInInterface* = 1.UsbProtocolCode
  UsbMiscProtocolDvbCiInMedia* = 2.UsbProtocolCode

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
{.pop.}

static:
  assert DeviceDescriptor.sizeof == 18, "Incorrect type size"
  assert ConfigurationDescriptor.sizeof == 9, "Incorrect type size"
  assert InterfaceDescriptor.sizeof == 9, "Incorrect type size"

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

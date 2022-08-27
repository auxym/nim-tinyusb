import tinyusb/device
import tinyusb/class/hid

export device
export hid


{.push header: "tusb.h".}
type UsbSpeed* {.pure, importc: "tusb_speed_t".} = enum Full, Low, High

proc usbInit*(): bool {.importc: "tusb_init".}
## Initialize USB stack. This proc must be called exactly once during program
## initialization.

proc usbInitialized*: bool {.importc: "tusb_inited".}
## Check if USB stack is initialized.
{.pop.}

# Board API

{.push header: "bsp/board.h".}
proc boardInit*(){.importC: "board_init", header: "bsp/board.h".}
## Initialize on-board peripherals : led, button, uart and USB

proc board_button_read(): uint32 {.importc: "board_button_read", header: "bsp/board.h".}
{.pop.}

proc getBoardButton*: bool {.inline.} = board_button_read() > 0
## Read state on onboard BOOTSEL button on RPi Pico. Returns `true` if button
## is pressed.


# Device Descriptor configuration

type
  UsbDeviceClass* {.size: sizeof(cchar), pure.} = enum
    unspecified = 0
    audio = 1
    cdc = 2
    hid = 3
    reserved_4 = 4
    physical = 5
    image = 6
    printer = 7
    msc = 8
    hub = 9
    cdc_data = 10
    smart_card = 11
    reserved_12 = 12
    content_security = 13
    video = 14
    personal_healthcare = 15
    audio_video = 16
    diagnostic = 0xdc
    wireless_controller = 0xe0
    misc = 0xef
    application_specific = 0xfe
    vendor_specific = 0xff

  UsbMiscSubclass* {.size: sizeof(cchar), pure.} = enum
    none = 0
    common = 2

  UsbMiscProtocol* {.size: sizeof(cchar), pure.} = enum
    none = 0
    iad = 1

  UsbDescriptorType* {.size: sizeof(cchar), pure.} = enum
    device = 0x01
    configuration = 0x02
    dtString = 0x03
    dtInterface = 0x04
    endpoint = 0x05
    qualifier = 0x06
    otherSpeedConfig = 0x07
    interfacePower = 0x08
    otg = 0x09
    debug = 0x0A
    interfaceAssociation = 0x0B
    bos = 0x0f
    deviceCapabillity = 0x10
    functional = 0x21
    csConfig = 0x22
    csString = 0x23
    csInterface = 0x24
    csEndPoint = 0x25
    superSpeedEndpointComp = 0x30
    superSpeedIsoEndpointComp = 0x31

{.push header: "tusb.h".}
type
  UsbDeviceDescriptor* {.packed, importc: "tusb_desc_device_t", completeStruct.} = object
    len*: byte
    descType*: UsbDescriptorType
    binCodeUsb*: uint16
    class*: UsbDeviceClass
    subclass*: UsbMiscSubclass
    protocol*: UsbMiscProtocol
    maxPacketSize*: byte
    vendorId*: uint16
    productId*: uint16
    binaryCodeDev*: uint16
    manufacturer*, product*, serialNumber*, numConfigurations*: byte

  BinaryDeviceStore* {.packed, importc: "tusb_desc_configuration_t", completeStruct.} = object
    len*: uint8
    descType*: uint8
    totalLength*: uint16
    numInterfaces*: uint8
    configurationValue*: uint8
    configuration*: uint8
    attributes*: uint8
    maxPower*: uint8
{.pop.}

static:
  assert UsbDeviceDescriptor.sizeof == 18, "Incorrect type size"
  assert BinaryDeviceStore.sizeof == 9, "Incorrect type size"

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
template setDeviceDescriptor*(dd: static[UsbDeviceDescriptor]) =
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

var calledDeviceDescriptorConfigurationCallback {.compileTime.} = false
template deviceDescriptorConfigurationCallback*(index, body) =
  static:
    when calledDeviceDescriptorConfigurationCallback:
      {.error: "called deviceDescriptorConfigurationCallback twice".}
    calledDeviceDescriptorConfigurationCallback = true
  proc tudDescriptorConfigCb(index: byte): ptr int8 {.exportC: "tud_descriptor_configuration_cb",
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

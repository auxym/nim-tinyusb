import ../device
import ../descriptors

# CDC Device API

{.push header: "tusb.h".}
#  Check if terminal is connected to this port
proc cdcConnected(itf: uint8): bool {.importc: "tud_cdc_n_connected".}

#  Get current line state. Bit 0:  DTR (Data Terminal Ready), Bit 1: RTS (Request to Send)
#proc cdcGetLineState*(itf: uint8): uint8 {.importc: "tud_cdc_n_get_line_state".}

#  Get current line encoding: bit rate, stop bits parity etc ..
#proc cdcGetLineCoding*(itf: uint8; coding: ptr CdcLineCoding) {.importc: "tud_cdc_n_get_line_coding".}

#  Set special character that will trigger tud_cdc_rx_wanted_cb() callback on receiving
#proc cdcSetWantedChar*(itf: uint8; wanted: char) {.importc: "tud_cdc_n_set_wanted_char".}

#  Get the number of bytes available for reading
proc cdcAvailable(itf: uint8): uint32 {.importc: "tud_cdc_n_available".}

#  Read received bytes
proc cdcRead(itf: uint8; buffer: pointer; bufsize: uint32): uint32 {.importc: "tud_cdc_n_read".}

#  Read a byte, return -1 if there is none
#
#proc cdcReadChar*(itf: uint8): int32 {.inline, importc: "tud_cdc_n_read_char".}

#  Clear the received FIFO
#proc cdcReadFlush*(itf: uint8) {.importc: "tud_cdc_n_read_flush".}

#  Get a byte from FIFO at the specified position without removing it
#proc cdcPeek*(itf: uint8; ui8: ptr uint8): bool {.importc: "tud_cdc_n_peek".}

#  Write bytes to TX FIFO, data may remain in the FIFO for a while
proc cdcWrite*(itf: uint8; buffer: pointer; bufsize: uint32): uint32 {.importc: "tud_cdc_n_write".}

#  Write a byte
proc cdcWriteChar(itf: uint8; ch: char): uint32 {.inline, importc: "tud_cdc_n_write_char".}

#  Write a null-terminated string
#proc cdcWriteStr*(itf: uint8; str: cstring): uint32 {.inline, importc: "tud_cdc_n_write_str".}

#  Force sending data if possible, return number of forced bytes
proc cdcWriteFlush*(itf: uint8): uint32 {.importc: "tud_cdc_n_write_flush".}

#  Return the number of bytes (characters) available for writing to TX FIFO buffer in a single n_write operation.
#proc cdcWriteAvailable*(itf: uint8): uint32 {.importc: "tud_cdc_n_write_available".}

#  Clear the transmit FIFO
#proc cdcWriteClear*(itf: uint8): bool {.importc: "tud_cdc_n_write_clear".}
{.pop}

# Nim stream-like API for USB CDC (serial)

type UsbSerialInterface* = distinct range[0'u8 .. 127'u8]
## Used to represent the CDC interface number, as configured by `CFG_TUD_CDC`.
## Eg. if `CFG_TUD_CDC` is `1`, then only `0.UsbSerialInterface` would be valid.
## If `CFG_TUD_CDC` is `2`, then we could use `0.UsbSerialInterface` and
## `1.UsbSerialInterface`.

proc available*(itf: UsbSerialInterface): uint32 {.inline.} =
  ## Get the number of bytes available for reading
  cdcAvailable(itf.uint8)

proc atEnd*(itf: UsbSerialInterface): bool {.inline.} =
  ## Returns `true` if there is currently no data available for reading.
  cdcAvailable(itf.uint8) == 0

proc connected*(itf: UsbSerialInterface): bool {.inline.} =
  ## Check if terminal is connected to this port
  ##
  ## Note: this actually checks for DTR bit, which is up to the host
  ## application to set.
  cdcConnected(itf.uint8)

proc readBytes*(itf: UsbSerialInterface, n: Positive = 1): seq[uint8] {.inline.} =
  ## Read up to `n` bytes from interface.
  ##
  ## Note: the length of the returned seq may be lower if fewer bytes were
  ## actually read.
  result = newSeq[uint8](n)
  let actualNumBytes = cdcRead(itf.uint8, result[0].unsafeAddr, n.uint32)
  result.setLen(actualNumBytes)

proc readString*(itf: UsbSerialInterface, n: Positive = 1): string {.inline.} =
  ## Read a string of up to `n` characters from interface.
  ##
  ## Note: the length of the returned string may be lower if fewer bytes were
  ## actually read.
  result = newString(n)
  let actualNumBytes = cdcRead(itf.uint8, result[0].unsafeAddr, n.uint32)
  result.setLen(actualNumBytes)

template writeData(itf: uint8, data: string or openArray[uint8]) =
  var
    i = 0
    remain = data.len
  while remain > 0 and cdcConnected(itf):
    let buffer = data[i].unsafeAddr
    let wrcount = cdcWrite(itf, buffer, remain.uint32).int
    i.inc wrcount
    remain.dec wrcount
    usbDeviceTask()
    discard cdcWriteFlush(itf)

proc write*(itf: UsbSerialInterface, s: string) {.inline.} =
  ## Write a string to interface.
  ##
  ## Note: automatically handles chunked writing if the transmit
  ## buffer fills up.
  writeData(itf.uint8, s)

proc write*(itf: UsbSerialInterface, s: openArray[uint8]) {.inline.} =
  ## Write a sequence of bytes to the interface.
  ##
  ## Note: automatically handles chunked writing if the transmit
  ## buffer fills up.
  writeData(itf.uint8, s)

proc write*(itf: UsbSerialInterface, c: char) {.inline.} =
  # Write a single character to the interface.
  discard cdcWriteChar(itf.uint8, c)

proc writeLine*(itf: UsbSerialInterface, s: string) {.inline.} =
  ## Write a string to interface, followed by `LF` character.
  ##
  ## Note: automatically handles chunked writing if the transmit
  ## buffer fills up.
  itf.write(s)
  itf.write('\n')

proc flush*(itf: UsbSerialInterface) {.inline.} =
  ## Force sending any data remaining in transmit FIFO
  discard cdcWriteFlush(itf.uint8)

# CDC-specific descriptors

type
  CdcFunctionalDescriptorSubtype* {.pure, size: sizeof(cchar).} = enum
    Header = 0x00
    CallManagement = 0x01
    AbstractControlManagement = 0x02
    DirectLineManagement = 0x03
    TelephoneRinger = 0x04
    TelephoneReporting = 0x05
    Union = 0x06
    CountrySelection = 0x07
    TelephoneOpMode = 0x08
    UsbTerminal = 0x09
    NetworkTerminal = 0x0A
    ProtocolUnit = 0x0B
    ExtensionUnit = 0x0C
    MultiChannelManagement = 0x0D
    CapiControlManagement = 0x0E
    Ethernet = 0x0F
    Atm = 0x10
    WirelessHandset = 0x11
    MobileDirectLine = 0x12
    MdlmDetail = 0x13
    DeviceManagement = 0x14
    Obex = 0x15
    CommandSet = 0x16
    CommandSetDetail = 0x17
    TelephoneControl = 0x18
    ObexServiceIdentifier = 0x19
    Ncm = 0x1A
    VendorSpecific = 0xFE

  ## Header Functional Descriptor
  CdcHeaderDescriptor* {.packed.} = object
    length: uint8
    descriptorType: UsbDescriptorType
    descriptorSubtype: CdcFunctionalDescriptorSubtype
    cdcVersion: BcdVersion

  ## Union Interface Functional Descriptor
  ## 
  ## N is the number of subordinate interfaces
  CdcUnionDescriptor*[N: static int] {.packed.} = object
    length: uint8
    descriptorType: UsbDescriptorType
    descriptorSubtype: CdcFunctionalDescriptorSubtype
    controlInterface: InterfaceNumber
    subordinates: array[N, InterfaceNumber]

  ## Call management capabilities bitset
  CallManagementCap* {.pure, size: sizeof(cchar).} = enum
    CallMgmtSupported
    CallMgmtOverDci

  ## Call Management Functional Descriptor
  ## 
  ## Ref: Universal Serial Bus Communications Class Subclass Specification for
  ## PSTN Devices rev. 1.2
  CdcCallMgmtDescriptor* {.packed.} = object
    length: uint8
    descriptorType: UsbDescriptorType
    descriptorSubtype: CdcFunctionalDescriptorSubtype
    capabilities: set[CallManagementCap]
    dataInterface: InterfaceNumber

  AbstractControlMgmtCap* {.pure, size: sizeof(cchar).} = enum
    CommFeature
    LineCodingState
    SendBreak
    NetworkConnection

  ## Abstract Control Management Functional Descriptor
  ## 
  ## Ref: Universal Serial Bus Communications Class Subclass Specification for
  ## PSTN Devices rev. 1.2
  CdcAbstractControlMgmtDescriptor* {.packed.} = object
    length: uint8
    descriptorType: UsbDescriptorType
    descriptorSubtype: CdcFunctionalDescriptorSubtype
    capabilities: set[AbstractControlMgmtCap]

  ## Complete interface descriptor structure for a CDC class "virtual USB
  ## serial port" device. This includes the interface association (IAD),
  ## the control and data interface descriptors, class-specific (CDC
  ## Functional) descriptors and endpoint descriptors.
  ## 
  ## This should match the byte array produced by TinyUSB macro
  ## `TUD_CDC_DESCRIPTOR`.
  CompleteCdcSerialPortInterface* {.packed.} = object
    iad: InterfaceAssociationDescriptor
    controlItf: InterfaceDescriptor
    cdcHeader: CdcHeaderDescriptor
    cdcCallMgmt: CdcCallMgmtDescriptor
    cdcAcm: CdcAbstractControlMgmtDescriptor
    union: CdcUnionDescriptor[1]
    epNotif: EndpointDescriptor
    dataItf: InterfaceDescriptor
    dataEpOut: EndpointDescriptor
    dataEpIn: EndpointDescriptor


static:
  assert sizeof(CdcHeaderDescriptor) == 5
  assert sizeof(CdcUnionDescriptor[4]) == 4 + 4
  assert sizeof(CdcCallMgmtDescriptor) == 5
  assert sizeof(CdcAbstractControlMgmtDescriptor) == 4
  assert sizeof(CompleteCdcSerialPortInterface) == 66

const
  ## Version of CDC spec on which this code is based.
  CdcSpecVersion* = initBcdVersion(1, 2, 0)

  CdcCsHeader* =  CdcHeaderDescriptor(
    length: sizeof(CdcHeaderDescriptor).uint8,
    descriptorType: UsbDescriptorType.CsInterface,
    descriptorSubtype: CdcFunctionalDescriptorSubtype.Header,
    cdcVersion: CdcSpecVersion
  )
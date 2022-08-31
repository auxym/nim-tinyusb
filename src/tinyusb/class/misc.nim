import ../common
#  Miscellaneous device class (class code 0xEF)

# Subclass and protocol codes for the Misc class
const
  # Subclass 0x01
  MiscSubclassSync* = 1.UsbSubclassCode
  MiscProtocolActiveSync* = 1.UsbProtocolCode
  MiscProtocolPalmSync* = 2.UsbProtocolCode

  # Subclass 0x02
  MiscSubclassCommon* = 2.UsbSubclassCode # Interface Association Descriptor
  MiscProtocolIad* = 1.UsbProtocolCode # Interface Association Descriptor
  MiscProtocolWamp* = 2.UsbProtocolCode # Wire Adapter Multifunction Peripheral

  # Subclass 0x03
  MiscSubclassCbaf* = 3.UsbSubclassCode # Cable Based Association Framework
  MiscProtocolCbaf* = 1.UsbProtocolCode # Cable Based Association Framework

  # Subclass 0x04
  MiscSubclassRndis* = 4.UsbSubclassCode # RNDIS
  MiscProtocolRndisEth* = 1.UsbProtocolCode # RNDIS over Ethernet
  MiscProtocolRndisWifi* = 2.UsbProtocolCode # RNDIS over WiFi
  MiscProtocolRndisWimax* = 3.UsbProtocolCode # RNDIS over WiMax
  MiscProtocolRndisWwan* = 4.UsbProtocolCode # RNDIS over WWAN
  MiscProtocolRndisIpv4* = 5.UsbProtocolCode # RNDIS over IPv4
  MiscProtocolRndisIpv6* = 6.UsbProtocolCode # RNDIS over IPv6
  MiscProtocolRndisGprs* = 7.UsbProtocolCode # RNDIS over GPRS

  # Subclass 0x05
  # Machine Vision Device conforming to the USB3 Vision specification
  MiscSubclassUsb3Vision* = 5.UsbSubclassCode
  MiscProtocolVisionControl* = 0.UsbProtocolCode # USB3 Vision Control Interface
  MiscProtocolVisionEvent* = 1.UsbProtocolCode # USB3 Vision Event Interface
  MiscProtocolVisionStreaming* = 2.UsbProtocolCode # USB3 Vision Streaming Interface

  # Subclass 0x06
  MiscSubclassStep* = 6.UsbSubclassCode
  MiscProtocolStepStream* = 0.UsbProtocolCode # STEP.Stream Transport Efficient Protocol
  MiscProtocolStepRaw* = 1.UsbProtocolCode # STEP RAW. Stream Transport Efficient Protocol 

  # Subclass 0x07
  MiscSubclassDvb* = 7.UsbSubclassCode
  MiscProtocolDvbCiInIad* = 0.UsbProtocolCode
  MiscProtocolDvbCiInInterface* = 1.UsbProtocolCode
  MiscProtocolDvbCiInMedia* = 2.UsbProtocolCode

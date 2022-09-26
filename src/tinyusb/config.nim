import ./descriptors
import std/strformat
import std/compilesettings

# This module generates the "tusb_config.h" file at compile-time,
# which is expected by the TinyUSB source files.

type
  TinyUsbOs* {.pure.} = enum
    None = "OPT_OS_NONE" # No RTOS
    FreeRtos = "OPT_OS_FREERTOS" # FreeRTOS
    MyNewt = "OPT_OS_MYNEWT" # Mynewt OS
    Custom = "OPT_OS_CUSTOM" # Custom OS is implemented by application
    Pico = "OPT_OS_PICO" # Raspberry Pi Pico SDK
    RtThread = "OPT_OS_RTTHR" # RT-Thread
    Rtx4 = "OPT_OS_RTX4" # Keil RTX 4

  TinyUsbMcu* {.pure.} = enum
    # LPC
    LPC11UXX = "OPT_MCU_LPC11UXX"        #  NXP LPC11Uxx
    LPC13XX = "OPT_MCU_LPC13XX"          #  NXP LPC13xx
    LPC15XX = "OPT_MCU_LPC15XX"          #  NXP LPC15xx
    LPC18XX = "OPT_MCU_LPC18XX"          #  NXP LPC18xx
    LPC40XX = "OPT_MCU_LPC40XX"          #  NXP LPC40xx
    LPC43XX = "OPT_MCU_LPC43XX"          #  NXP LPC43xx
    LPC51UXX = "OPT_MCU_LPC51UXX"        #  NXP LPC51U6x
    LPC54XXX = "OPT_MCU_LPC54XXX"        #  NXP LPC54xxx
    LPC55XX = "OPT_MCU_LPC55XX"          #  NXP LPC55xx

    # NRF
    NRF5X = "OPT_MCU_NRF5X"              #  Nordic nRF5x series

    # SAM
    SAMD21 = "OPT_MCU_SAMD21"            #  MicroChip SAMD21
    SAMD51 = "OPT_MCU_SAMD51"            #  MicroChip SAMD51
    SAMG = "OPT_MCU_SAMG"                #  MicroChip SAMDG series
    SAME5X = "OPT_MCU_SAME5X"            #  MicroChip SAM E5x
    SAMD11 = "OPT_MCU_SAMD11"            #  MicroChip SAMD11
    SAML22 = "OPT_MCU_SAML22"            #  MicroChip SAML22
    SAML21 = "OPT_MCU_SAML21"            #  MicroChip SAML21

    # STM32
    STM32F0 = "OPT_MCU_STM32F0"          #  ST F0
    STM32F1 = "OPT_MCU_STM32F1"          #  ST F1
    STM32F2 = "OPT_MCU_STM32F2"          #  ST F2
    STM32F3 = "OPT_MCU_STM32F3"          #  ST F3
    STM32F4 = "OPT_MCU_STM32F4"          #  ST F4
    STM32F7 = "OPT_MCU_STM32F7"          #  ST F7
    STM32H7 = "OPT_MCU_STM32H7"          #  ST H7
    STM32L1 = "OPT_MCU_STM32L1"          #  ST L1
    STM32L0 = "OPT_MCU_STM32L0"          #  ST L0
    STM32L4 = "OPT_MCU_STM32L4"          #  ST L4
    STM32G0 = "OPT_MCU_STM32G0"          #  ST G0
    STM32G4 = "OPT_MCU_STM32G4"          #  ST G4
    STM32WB = "OPT_MCU_STM32WB"          #  ST WB

    # Sony
    CXD56 = "OPT_MCU_CXD56"              #  SONY CXD56

    # TI
    MSP430x5xx = "OPT_MCU_MSP430x5xx"    #  TI MSP430x5xx
    MSP432E4 = "OPT_MCU_MSP432E4"        #  TI MSP432E4xx

    # ValentyUSB eptri
    VALENTYUSB_EPTRI = "OPT_MCU_VALENTYUSB_EPTRI" #  Fomu eptri config

    # NXP iMX RT
    MIMXRT = "OPT_MCU_MIMXRT"            #  NXP iMX RT Series
    MIMXRT10XX = "OPT_MCU_MIMXRT10XX"    #  RT10xx
    MIMXRT11XX = "OPT_MCU_MIMXRT11XX"    #  RT11xx

    # Dialog
    DA1469X = "OPT_MCU_DA1469X"          #  Dialog Semiconductor DA1469x

    # Raspberry Pi
    RP2040 = "OPT_MCU_RP2040"            #  Raspberry Pi RP2040

    # NXP Kinetis
    MKL25ZXX = "OPT_MCU_MKL25ZXX"        #  NXP MKL25Zxx
    K32L2BXX = "OPT_MCU_K32L2BXX"        #  NXP K32L2Bxx

    # Silabs
    EFM32GG = "OPT_MCU_EFM32GG"          #  Silabs EFM32GG
    RX72N = "OPT_MCU_RX72N"              #  Renesas RX72N

    # Mind Motion
    MM32F327X = "OPT_MCU_MM32F327X"      #  Mind Motion MM32F327

    # GigaDevice
    GD32VF103 = "OPT_MCU_GD32VF103"      #  GigaDevice GD32VF103

    # Broadcom
    BCM2711 = "OPT_MCU_BCM2711"          #  Broadcom BCM2711
    BCM2835 = "OPT_MCU_BCM2835"          #  Broadcom BCM2835
    BCM2837 = "OPT_MCU_BCM2837"          #  Broadcom BCM2837

    # Infineon
    XMC4000 = "OPT_MCU_XMC4000"          #  Infineon XMC4000

    # PIC
    PIC32MZ = "OPT_MCU_PIC32MZ"          #  MicroChip PIC32MZ family

    # BridgeTek
    FT90X = "OPT_MCU_FT90X"              #  BridgeTek FT90x
    FT93X = "OPT_MCU_FT93X"              #  BridgeTek FT93x

    # Allwinner
    F1C100S = "OPT_MCU_F1C100S"          #  Allwinner F1C100s family


# tusb_config.h from TinyUSB official examples
const CfgTemplate = """
#ifndef _TUSB_CONFIG_H_
#define _TUSB_CONFIG_H_

#ifdef __cplusplus
 extern "C" {
#endif

//--------------------------------------------------------------------
// COMMON CONFIGURATION
//--------------------------------------------------------------------

#define CFG_TUSB_MCU                  [$mcu]

// RHPort number used for device can be defined by board.mk, default to port 0
#ifndef BOARD_DEVICE_RHPORT_NUM
  #define BOARD_DEVICE_RHPORT_NUM     [rhPort]
#endif

// RHPort max operational speed can defined by board.mk
// Default to Highspeed for MCU with internal HighSpeed PHY (can be port specific), otherwise FullSpeed
#ifndef BOARD_DEVICE_RHPORT_SPEED
  #if (CFG_TUSB_MCU == OPT_MCU_LPC18XX || CFG_TUSB_MCU == OPT_MCU_LPC43XX || CFG_TUSB_MCU == OPT_MCU_MIMXRT10XX || \
       CFG_TUSB_MCU == OPT_MCU_NUC505  || CFG_TUSB_MCU == OPT_MCU_CXD56 || CFG_TUSB_MCU == OPT_MCU_SAMX7X)
    #define BOARD_DEVICE_RHPORT_SPEED   OPT_MODE_HIGH_SPEED
  #else
    #define BOARD_DEVICE_RHPORT_SPEED   OPT_MODE_FULL_SPEED
  #endif
#endif

// Device mode with rhport and speed defined by board.mk
#if   BOARD_DEVICE_RHPORT_NUM == 0
  #define CFG_TUSB_RHPORT0_MODE     (OPT_MODE_DEVICE | BOARD_DEVICE_RHPORT_SPEED)
#elif BOARD_DEVICE_RHPORT_NUM == 1
  #define CFG_TUSB_RHPORT1_MODE     (OPT_MODE_DEVICE | BOARD_DEVICE_RHPORT_SPEED)
#else
  #error "Incorrect RHPort configuration"
#endif

#ifndef CFG_TUSB_OS
#define CFG_TUSB_OS               [$os]
#endif

#define CFG_TUSB_DEBUG           [(debug.int)]

/* USB DMA on some MCUs can only access a specific SRAM region with restriction on alignment.
 * Tinyusb use follows macros to declare transferring memory so that they can be put
 * into those specific section.
 * e.g
 * - CFG_TUSB_MEM SECTION : __attribute__ (( section(".usb_ram") ))
 * - CFG_TUSB_MEM_ALIGN   : __attribute__ ((aligned(4)))
 */
#ifndef CFG_TUSB_MEM_SECTION
#define CFG_TUSB_MEM_SECTION        [memSectionAttr]
#endif

#ifndef CFG_TUSB_MEM_ALIGN
#define CFG_TUSB_MEM_ALIGN          __attribute__ ((aligned([memAlign])))
#endif

//--------------------------------------------------------------------
// DEVICE CONFIGURATION
//--------------------------------------------------------------------

#ifndef CFG_TUD_ENDPOINT0_SIZE
#define CFG_TUD_ENDPOINT0_SIZE    [ep0size.ord]
#endif

//------------- CLASS -------------//
#define CFG_TUD_HID               [hid]
#define CFG_TUD_CDC               [cdc]
#define CFG_TUD_MSC               [msc]
#define CFG_TUD_MIDI              [midi]
#define CFG_TUD_VENDOR            [vendor]

// CDC FIFO size of TX and RX
#define CFG_TUD_CDC_RX_BUFSIZE   [cdcRxBufSize]
#define CFG_TUD_CDC_TX_BUFSIZE   [cdcTxBufSize]

// CDC Endpoint transfer buffer size, more is faster
#define CFG_TUD_CDC_EP_BUFSIZE   [cdcEpBufSize]

// HID buffer size Should be sufficient to hold ID (if any) + Data
#define CFG_TUD_HID_EP_BUFSIZE   [hidBufSize]

#ifdef __cplusplus
 }
#endif

#endif /* _TUSB_CONFIG_H_ */
"""

proc configureUsbDevice*(
  mcu: TinyUsbMcu,
  os: TinyUsbOs = TinyUsbOs.None,
  debug: bool = false,

  # Number of interfaces for each device class
  hid, cdc, msc, midi, vendor: Natural = 0,

  rhPort: Natural = 0,
  memAlign: Natural = 4,
  memSection: string = "",
  ep0size: Ep0MaxPacketSize=Ep0MaxPacketSize.Size64,
  cdcRxBufSize, cdcTxBufSize, cdcEpBufSize: Natural = 64,
  hidBufSize: Natural = 16,) {.compileTime.} =

  let memSectionAttr =
    if memSection == "": ""
    else: fmt"""__attribute__ (( section("{memSection}") ))"""

  let
    contents = fmt(CfgTemplate, '[', ']')
    nimcache = querySetting(SingleValueSetting.nimcacheDir)
    fname = nimcache & "/" & "tusb_config.h"
  writeFile(fname, contents)

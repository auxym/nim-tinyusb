import tinyusb/common
import tinyusb/device
import tinyusb/langids
import tinyusb/class/hid
import tinyusb/class/cdc
import tinyusb/class/misc

export common
export device
export langids
export hid
export cdc
export misc

{.push header: "tusb.h".}
type UsbSpeed* {.pure, importc: "tusb_speed_t".} = enum Full, Low, High

proc usbInit*(): bool {.importc: "tusb_init".}
## Initialize USB stack. This proc must be called exactly once during program
## initialization.

proc isUsbInitialized*: bool {.importc: "tusb_inited".}
## Check if USB stack is initialized.
{.pop.}

# Board API

{.push header: "bsp/board.h".}
proc usbBoardInit*(){.importC: "board_init", header: "bsp/board.h".}
## Initialize on-board peripherals : led, button, uart and USB

proc board_button_read(): uint32 {.importc: "board_button_read", header: "bsp/board.h".}
{.pop.}

proc getBoardButton*: bool {.inline.} = board_button_read() > 0
## Read state on onboard BOOTSEL button on RPi Pico. Returns `true` if button
## is pressed.

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

# Nim-TinyUSB

[TinyUSB](https://docs.tinyusb.org/en/latest/) bindings for the Nim language.
TinyUSB is a USB host and device stack for microcontrollers.

Status: Mostly complete but development has stopped in 2023, I don't know
how compatible these bindings are with more recent versions of TinyUSB. The
code is also mostly undocumented, unfortunately.

There is however a working example for the Raspberry Pi Pico (rp2040) here:
https://github.com/auxym/picostdlib/tree/external-tinyusb/examples/usb_hid_cdc

## Tests

The `TinyUsbPath` define must be passed to the compiler to run tests.

1. Obtain a copy of the [TinyUSB repository](https://docs.tinyusb.org/en/latest/).

2. Run `nimble test -d:TinyUsbPath:<path to tinyusb repo>`.

Example:

```bash
$ nimble test -d:TinyUsbPath:/home/user/source/tinyusb
```


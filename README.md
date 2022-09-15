# Nim-TinyUSB

[TinyUSB](https://docs.tinyusb.org/en/latest/) bindings for the Nim language.
TinyUSB is a USB host and device stack for microcontrollers.

Status: WIP

## Tests

The `TinyUsbPath` define must be passed to the compiler to run tests.

1. Obtain a copy of the [TinyUSB repository](https://docs.tinyusb.org/en/latest/).

2. Run `nimble test -d:TinyUsbPath:<path to tinyusb repo>`.

Example:

```bash
$ nimble test -d:TinyUsbPath:/home/user/source/tinyusb
```

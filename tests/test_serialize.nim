import std/unittest
import ../src/tinyusb

suite "Serialize":
  test "serialize object":
    type SObj {.packed.} = object
      a: uint8
      b: uint8
      c: uint16
      d: array[3, uint8]

    let x = SObj(a: 1, b: 2, c: 600, d: [4'u8, 5, 6])
    check:
      x.serialize == "\x01\x02\x58\x02\x04\x05\x06"

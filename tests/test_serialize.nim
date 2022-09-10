import std/unittest
import ../src/tinyusb

suite "Serialize":
  test "serialize sets":
    type
      E1 = enum e1a, e1b
      E2 = enum e2a=0, e2b=12
      E3 = enum e3a=0, e3b=20

    assert sizeof(set[E1]) == 1
    assert sizeof(set[E2]) == 2
    assert sizeof(set[E3]) == 4

    var x1, x2, x3 = ""
    x1.serialize({e1b})
    x2.serialize({e2b})
    x3.serialize({e3b})
    check:
      x1 == "\x02"
      x2 == "\x00" & (1'u8 shl (12-8)).char
      x3 == "\x00\x00" & (1'u8 shl (20-16)).char & '\x00'

  test "serialize object":
    type SObj {.packed.} = object
      a: uint8
      b: uint8
      c: uint16
      d: array[3, uint8]

    let x = SObj(a: 1, b: 2, c: 600, d: [4'u8, 5, 6])
    check:
      x.serialize == "\x01\x02\x58\x02\x04\x05\x06"

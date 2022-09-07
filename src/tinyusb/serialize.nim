# Tools to generate packed byte arrays for USB transmission from Nim objects

import std/macros

proc serialize*(b: var string, x: uint16) =
  b.add (0x00FF and x).char
  b.add ((0xFF00 and x) shr 8).char

proc serialize*(b: var string, x: uint8) =
  b.add x.char

proc serialize*[N, T](b: var string, x: array[N, T]) =
  for e in x:
    b.serialize(e)

proc serialize*[T: object](b: var string, x: T) =
  for e in x.fields:
    b.serialize(e)

proc serialize*[T: object](x: T): string =
  for e in x.fields:
    result.serialize(e)

macro toArrayLit*(s: static[string]): untyped =
  ## Generate byte array literal from a compile-time string
  ## This imitates the behavior of TinyUSB's various macros used
  ## for descriptor generation.
  result = newNimNode(nnkBracket)
  for c in s:
    result.add newLit(c.uint8)

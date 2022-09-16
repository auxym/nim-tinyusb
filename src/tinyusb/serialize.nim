# Tools to generate packed byte arrays for USB transmission from Nim objects

import std/macros
import std/genasts

proc serialize*(b: var string, x: uint8) =
  b.add x.char

proc serialize*(b: var string, x: uint16) =
  b.add ((0x00FF'u16 and x) shr 0o00).char
  b.add ((0xFF00'u16 and x) shr 0o10).char

proc serialize(b: var string, x: uint32) =
  b.add ((0x000000FF'u32 and x) shr 0o00).char
  b.add ((0x0000FF00'u32 and x) shr 0o10).char
  b.add ((0x00FF0000'u32 and x) shr 0o20).char
  b.add ((0xFF000000'u32 and x) shr 0o30).char

proc serialize*[T](b: var string, x: set[T]) =
  when sizeof(set[T]) == 1:
    b.serialize(cast[uint8](x))
  elif sizeof(set[T]) == 2:
    b.serialize(cast[uint16](x))
  elif sizeof(set[T]) == 4:
    b.serialize(cast[uint32](x))
  else:
    {.error: "serialize not implement for set of size " & sizeof(set[T]).}

proc serialize*[T: enum](b: var string, x: T) =
  when sizeof(T) == 1:
    b.serialize(x.ord.uint8)
  elif sizeof(T) == 2:
    b.serialize(x.ord.uint16)
  elif sizeof(T) == 4:
    b.serialize(x.ord.uint32)

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

macro serializeAll*(elems: varargs[untyped]): string =
  ## Serialize multiple items, of potentially different type, to a single
  ## string in a sequential order.
  var body = newStmtList()
  let sIdt = gensym(nskVar)
  body.add:
    genAst(s=sIdt):
      var s: string

  for e in elems:
    body.add genAst(s=sIdt, e=e, s.serialize(e))

  body.add sIdt
  result = newBlockStmt(body)

# Misc utilities shared by different modules in tinyusb but not to be
# publicly exported.

import std/macros
import std/genasts
import std/strformat
import ./serialize

export serialize


macro borrowSerialize*(typs: untyped): untyped =
  ## Generate a borrowed serialize proc for distinct types
  result = newStmtList()
  for typ in typs.children:
    let ast = genAst(typ):
      proc serialize*(b: var string, e: typ) {.borrow.}
    result.add ast


func hexRepr*(s: string): string =
  ## Mostly useful for debugging
  for c in s: result.add fmt"{c.uint8:02X} "

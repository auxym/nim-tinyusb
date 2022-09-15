# Misc utilities shared by different modules in tinyusb but not to be
# publicly exported.

import std/macros
import std/genasts
import ./serialize

export serialize

macro borrowSerialize*(typs: untyped): untyped =
  ## Generate a borrowed serialize proc for distinct types
  result = newStmtList()
  for typ in typs.children:
    let ast = genAst(typ):
      proc serialize*(b: var string, e: typ) {.borrow.}
    result.add ast
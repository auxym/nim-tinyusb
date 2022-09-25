import std/strutils
import std/strformat
import std/tables

const usbidsFileName = "./usb.ids"

func sanitize(name: string): string =
  const remove = {'.', ' ', ',', '(', ')', '+', '*', '-', '/', '\\', '|', '='}
  for c in name:
    if c notin remove: result.add c
  result = result.replace("Pages", "")
  result = result.replace("Page", "")
  if result == "Ordinal": result = "Ordinall"

var
  pages: seq[(uint16, string)]
  usages: seq[(uint32, string)]
  curPage = -1
  curPageName = ""

for ln in usbidsFileName.lines:
  if ln.startsWith("HUT"):
    let parts = ln.splitWhitespace(maxSplit=2)
    curPage = parts[1].parseHexInt
    curPageName = parts[2]
    pages.add (curPage.uint16, curPageName)
  elif curPage >= 0:
    if ln.strip.len == 0:
      break
    else:
      let
        parts = ln.strip.splitWhitespace(maxSplit=1)
        id = parts[0].parseHexInt
        fullUsage = (curPage.uint32 shl 16) or (id.uint32 and 0x0000FFFF'u32)
      usages.add (fullUsage, parts[1])


var pageTable: Table[uint32, string]
echo """type HidUsagePage* {.pure, size: 2.} = enum"""
for page in pages:
  let sanName = page[1].sanitize
  pageTable[page[0].uint32] = sanName
  echo fmt"  {sanName} = {(page[0]):#06X}"

echo ""

echo """
type HidUsage* = object
  page: HidUsagePage
  id: uint16

const
""".strip

for usage in usages:
  let
    page = usage[0] shr 16
    id = usage[0] and 0x0000FFFF'u32
    pageEnumName = pageTable[page]
    fullNameSan = pageEnumName & usage[1].sanitize
  if pageEnumName == "Keyboard": continue
  echo fmt"  hidUsage{fullNamesan}* = HidUsage(page: {pageEnumName}, id: {id:#06X})"
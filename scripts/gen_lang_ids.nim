# Quick and dirty script to generate the USB langid enum in nim based on the
# Linux-USB project's usb.ids file, found in the same folder as this file.
# Input file path (usb.ids) is hard-coded below, output is to stdout.

import std/strutils
import std/strformat
import std/algorithm

const usbidsFileName = "./usb.ids"

type LangIdEntry = object
  id: int
  fullName: string

# For sorting
func `<`(a, b: LangIdEntry): bool = a.id < b.id

func sanitizeLangName(name: string): string =
  result = name
  result = result.replace(" ", "")
  result = result.replace(".", "")
  result = result.replace(",", "")

func initLangEntry(langId, sublangId: int, langName, sublangName: string): LangIdEntry =
  result.id = langId or (sublangId shl 10)
  result.fullName = sanitizeLangName(
    if langName == sublangName:
      langName
    else:
      (langName & sublangName)
  )

proc echoLangEntry(e: LangIdEntry) =
  echo fmt"  {e.fullName} = {e.id:#06x}"

var
  curlang = -1
  curlangName = ""
  sublangCount = 0

var langs: seq[LangIdEntry]
for ln in usbidsFileName.lines:
  # Had a primary language on previous line without a sublang
  if curlang > 0 and sublangCount == 0 and not ln.startsWith("\t"):
    langs.add initLangEntry(curlang, 0x01, curlangName, "")

  if ln.startsWith("L "):
    let parts = ln.splitWhitespace(maxsplit=2)
    if parts[2] == "forgotten":
      curlang = -1
      continue
    curlang = parts[1].parseHexInt
    curlangName = parts[2]
    sublangCount = 0
  elif curlang > 0 and ln.startsWith("\t"):
    sublangCount.inc
    let
      parts = ln.splitWhitespace(maxsplit=1)
      sublang = parts[0].parseHexInt
      sublangName = parts[1]
    langs.add initLangEntry(curlang, sublang, curlangName, sublangName)
  elif curlang > 0:
    curlang = -1

sort(langs)

echo """
# Generated automatically by script gen_lang_ids.nim
# Based on Linux-USB project usb.ids file
#
# Sorry for the irregular ordering, but Nim requires enums to be sorted in
# numerical order, and the USB spec encodes the sub-languages in higher bits.
"""

echo "type LangId* {.size: 2, pure.} = enum"

for lang in langs:
  echoLangEntry(lang)

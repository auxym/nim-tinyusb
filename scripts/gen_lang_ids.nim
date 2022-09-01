# Quick and dirty script to generate the USB langid enum in nim based on the
# Linux-USB project's usb.ids file, found in the same folder as this file.
# Input file path (usb.ids) is hard-coded below, output is to stdout.

import std/strutils
import std/strformat

func sanitizeLangName(name: string): string =
  result = name
  result = result.replace(" ", "")
  result = result.replace(".", "")

proc genLang(langId, sublangId: int, langName, sublangName: string) =
    let fullLangId = langId or (sublangId shl 10)
    let fullLangName = sanitizeLangName(
      if langName == sublangName:
        langName
      else:
        (langName & sublangName)
    )
    echo fmt"  {fullLangName} = {fullLangId:#06x}"

let usbidsFileName = "./usb.ids"

var
  curlang = -1
  curlangName = ""
  sublangCount = 0

echo """
# Generated automatically by script gen_lang_ids.nim
# Based on Linux-USB project usb.ids file
"""

echo "type LangId* {.size: 2, pure.} = enum"

for ln in usbidsFileName.lines:
  # Had a primary language on previous line without a sublang
  if curlang > 0 and sublangCount == 0 and not ln.startsWith("\t"):
    genLang(curlang, 0x01, curlangName, "")

  if ln.startsWith("L "):
    let parts = ln.splitWhitespace(maxsplit=2)
    if parts[2] == "forgotten":
      continue
    curlang = parts[1].parseHexInt
    curlangName = parts[2]
    sublangCount = 0
  if curlang > 0 and ln.startsWith("\t"):
    sublangCount.inc
    let
      parts = ln.splitWhitespace(maxsplit=1)
      sublang = parts[0].parseHexInt
      sublangName = parts[1]
    genLang(curlang, sublang, curlangName, sublangName)

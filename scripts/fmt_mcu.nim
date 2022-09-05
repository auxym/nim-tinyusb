# Used to generate TinyUsbMcu enum
# Pass path to tusb_option.h file as command line param

import regex # https://github.com/nitely/nim-regex
import std/os
import std/strformat
import std/strutils

var prevline = ""
for ln in commandLineParams()[0].lines:
  match ln, rex"#define (OPT_MCU_(\w+)).*///<([\w ]+)":
    if prevline.startsWith("//"):
      echo ""
      echo prevline.replace("//", "#")

    let
        entryName = matches[1]
        col1 = fmt"{entryName} = ""{matches[0]}"""
    echo fmt"{col1: <36s} # {matches[2]}"
  prevline = ln

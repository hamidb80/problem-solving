import std/[os, strformat, strutils]

const sampleTemplate = readFile "./sample.nim"

when isMainModule:
  echo "enter your day [like 7]: "
  
  let
    dayNum = readLine(stdin).parseInt
    dirName = fmt"d{dayNum:02}"

  createDir dirName
  
  for fname in ["input.txt", "test.txt"]:
    writeFile dirName / fname, ""

  writeFile dirName / "main.nim", sampleTemplate

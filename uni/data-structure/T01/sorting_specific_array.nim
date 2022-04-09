import std/[sequtils, strutils, strscans]

type RepeatNumbers = array[200, int]
const limit = 200000

when isMainModule:
  let
    (_, mn, mx) = stdin.readline.scanTuple("$i $i")
    numbers = stdin.readLine.splitWhitespace.map(parseInt)

  var nTable: RepeatNumbers

  for n in numbers:
    inc nTable[n-mn]

  var c = 0
  for i, r in nTable:
    for _ in 1..r:
      if c < limit:
        stdout.write mn+i, " "
      else:
        quit()

      inc c

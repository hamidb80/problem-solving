import std/[sequtils, strutils, strscans]

# def ----------------------------------------

type
  Position = tuple
    x, y, z: int

# utils --------------------------------------

# implement ----------------------------------

func parsePosition(s: string): Position =
  discard scanf(s, "$i,$i,$i", result.x, result.y, result.z)

func seenArea(cubes: seq[Position]): int =
  discard

# go -----------------------------------------

let data = "./test.txt".readFile.splitLines.map(parsePosition)
echo data.seenArea

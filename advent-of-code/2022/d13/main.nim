import std/[sequtils, strutils, strformat, unittest]

{.experimental: "strictFuncs".}

# def ----------------------------------------

# utils --------------------------------------

# implement ----------------------------------

func test(data: string): int =
  discard

# tests --------------------------------------

test "":
  check true

# go -----------------------------------------

let data = readFile("./test.txt")
echo test(data)

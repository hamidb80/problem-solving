import std/[sequtils, strutils, unittest]

{.experimental: "strictFuncs".}

# def ----------------------------------------

# utils --------------------------------------

# implement ----------------------------------

func test(data: string): int =
  discard

# go -----------------------------------------

let data = readFile("./test.txt")
echo test(data)

# tests --------------------------------------

test "t1":
  check true
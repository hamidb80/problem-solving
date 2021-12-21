import std/[sequtils, strutils, unittest]

{.experimental: "strictFuncs".}

# def ----------------------------------------

# utils --------------------------------------

# implement ----------------------------------

func test(content: string): int =
  discard

# go -----------------------------------------

let content = readFile("./test.txt")
echo test(content)

# tests --------------------------------------

test "t1":
  check true
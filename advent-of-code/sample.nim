import sequtils, strutils

# prepare ------------------------------------

# utils --------------------------------------

# implement ----------------------------------

func test(content: string): int =
  discard

# go -----------------------------------------

let content = readFile("./test.txt")

echo test(content) 
import std/[sequtils, strutils, strformat, unittest, json]

# utils --------------------------------------

func isInt(j: JsonNode): bool =
  j.kind == Jint

func toInt(j: JsonNode): int =
  if j.isInt: j.getInt
  else: j[0].toInt

# implement ----------------------------------

iterator lists(data: string): JsonNode =
  for l in data.splitLines:
    if l != "":
      yield parseJson l

func correctOrder(a, b: JsonNode): bool =
  let ints = [a, b].map isInt

iterator couples[T](s: seq[T]): (int, T, T) =
  var c = 0
  for i in countup(0, s.high, 2):
    inc c
    yield (c, s[i], s[i+1])

func howManyCorrectOrderOrder(lists: seq[JsonNode]): int =
  for (i, a, b) in lists.couples:
    debugEcho (i, correctOrder(a, b))
    if correctOrder(a, b):
      inc result, i

# go -----------------------------------------

let data = "./test.txt".readFile.lists.toseq
echo data.howManyCorrectOrderOrder

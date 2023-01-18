import std/[sequtils, strutils, json, algorithm]

type
  Compare = enum
    right = -1
    next = 0
    wrong = +1

  Result = enum
    less
    equal
    more

# utils --------------------------------------

func isInt(j: JsonNode): bool = j.kind == Jint

func cmpc[T](a, b: T): Result =
  case cast[-1 .. +1](cmp(a, b))
  of -1: less
  of 0: equal
  of +1: more

# implement ----------------------------------

iterator lists(data: string): JsonNode =
  for l in data.splitLines:
    if l != "":
      yield parseJson l

iterator couples[T](s: seq[T]): (int, T, T) =
  var c = 0
  for i in countup(0, s.high, 2):
    inc c
    yield (c, s[i], s[i+1])


func correctOrderImpl(a, b: JsonNode): Compare =
  let ints = [a, b].map isInt

  if ints[0] and ints[1]:
    case cmpc(a.getInt, b.getInt)
    of equal: next
    of less: right
    of more: wrong

  elif ints[0] and not ints[1]:
    correctOrderImpl(%*[a], b)

  elif not ints[0] and ints[1]:
    correctOrderImpl(a, %*[b])

  else:
    var
      i = 0
      answer = next

    while i < a.len and i < b.len:
      answer = correctOrderImpl(a[i], b[i])
      if answer != next: break
      inc i

    case answer
    of right, wrong: answer
    of next:
      case cmpc(a.len, b.len)
      of equal: next
      of less: right
      of more: wrong

func correctOrder(a, b: JsonNode): bool =
  right == correctOrderImpl(a, b)

func cmp(a, b: JsonNode): int =
  correctOrderImpl(a, b).int


func correctOrderOrderIndexSum(packets: seq[JsonNode]): int =
  for (i, a, b) in packets.couples:
    if correctOrder(a, b):
      inc result, i

func decoderKey(packets: seq[JsonNode]): int =
  let
    d2 = %[[2]]
    d6 = %[[6]]

  result = 1

  for i, packet in sorted(packets & @[d2, d6], cmp):
    if packet in [d2, d6]:
      result *= i+1

# go -----------------------------------------

let data = "./input.txt".readFile.lists.toseq
echo data.correctOrderOrderIndexSum # 5623
echo data.decoderKey # 20570

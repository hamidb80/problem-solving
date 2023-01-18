import std/[sequtils, strutils, strformat, unittest, json]

type 
  Compare = enum
    next
    right
    wrong

  Result = enum
    equal
    less
    more

# utils --------------------------------------

func isInt(j: JsonNode): bool =
  j.kind == Jint

func toInt(j: JsonNode): int =
  if j.isInt: j.getInt
  else: j[0].toInt

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

func correctOrderImpl(a, b: JsonNode, level: int): Compare =
  let ints = [a, b].map isInt

  # debugEcho ' '.repeat(level*2), (a, b)

  result = 
    if ints[0] and ints[1]:
      case cmpc(a.getInt, b.getInt)
      of equal: next
      of less: right
      of more: wrong

    elif ints[0] and not ints[1]:
      correctOrderImpl(%*[a], b, level+1)
    
    elif not ints[0] and ints[1]:
      correctOrderImpl(a, %*[b], level+1)

    else:
      var i = 0 

      while i < a.len and i < b.len:
        let answer = correctOrderImpl(a[i], b[i], level+1)

        case answer
        of next: discard
        else: 
          result = answer
          break

        inc i

      case result
      of right, wrong: result
      of next:
        case cmpc(a.len ,b.len)
        of equal: next
        of less: right
        of more: wrong

  # debugEcho ' '.repeat(level*2), "result : ", result

func correctOrder(a, b: JsonNode): bool =
  right == correctOrderImpl(a, b, 1)

iterator couples[T](s: seq[T]): (int, T, T) =
  var c = 0
  for i in countup(0, s.high, 2):
    inc c
    yield (c, s[i], s[i+1])

func correctOrderOrderIndexSum(lists: seq[JsonNode]): int =
  for (i, a, b) in lists.couples:
    # debugEcho "\n\n== Pair ", i, " =="
    if correctOrder(a, b):
      inc result, i

# go -----------------------------------------

let data = "./input.txt".readFile.lists.toseq
echo data.correctOrderOrderIndexSum

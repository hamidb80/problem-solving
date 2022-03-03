import std/[strutils, sugar, unittest]

const
  numberRanges = [
    0 .. 9,
    10 .. 99,
    100 .. 999,
    1000 .. 9999,
  ]

  numberRangesLen = collect:
    for (i, rng) in numberRanges.pairs:
      rng.len * (i+1)

func `[]`(rng: HSlice[int, int], index: int): int =
  rng.a + index

func getRangeInfo(n: int):
  tuple[rng: HSlice[int, int], digitsLen, relativeIndex: int] =

  result.relativeIndex = n

  for (i, rl) in numberRangesLen.pairs:
    if result.relativeIndex <= rl:
      result.rng = numberRanges[i]
      result.digitsLen = i+1
      break
    else:
      dec result.relativeIndex, rl

func getLastDigit(n, i: int): int =
  var temp = n
  for _ in 0 .. i:
    result = temp mod 10
    temp = temp div 10

func findDigit(index: int): int =
  let
    acc = getRangeInfo index
    digitIndex = acc.relativeIndex mod acc.digitsLen
    number = acc.rng[acc.relativeIndex div acc.digitsLen]

  # debugEcho (digitIndex, number)
  number.getLastDigit acc.digitsLen - 1 - digitIndex


# test ---------------------

test "2345":
  check findDigit(2345) == 1

test "920":
  check findDigit(920) == 4

test "600":
  check findDigit(600) == 6

test "100":
  check findDigit(100) == 5

test "29":
  check findDigit(29) == 9

test "11":
  check findDigit(11) == 0

test "9":
  check findDigit(9) == 9

# run ---------------------

when isMainModule:
  echo findDigit parseint stdin.readLine

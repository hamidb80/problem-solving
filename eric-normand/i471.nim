# https://gist.github.com/ericnormand/415c98b46e216978728156fecc20bac4

import std/[unittest, sequtils]

iterator notEq(s: string, c: char): char =
  for ch in s:
    if ch != c:
      yield ch

func regroup(code: string, maxSize: int): string =
  let 
    charsNo = code.len - (code.countit it == '-')
    offset = charsNo mod maxSize

  result = newStringOfCap(charsNo + charsNo div maxSize + 1)

  var n = 0
  for ch in code.notEq '-':
    inc n
    result.add ch

    if (n != charsNo) and (
      (n < maxSize) and (n == offset) or
      (n mod maxSize == offset)
    ):
      result.add '-'


suite "Test":
  test "A5-GG-B88":
    check regroup("A5-GG-B88", 3) == "A-5GG-B88"

  test "A5-GG-B88":
    check regroup("A5-GG-B88", 2) == "A-5G-GB-88"

  test "6776":
    check regroup("6776", 2) == "67-76"

  test "F33":
    check regroup("F33", 1) == "F-3-3"

  test "IIO":
    check regroup("IIO", 7) == "IIO"

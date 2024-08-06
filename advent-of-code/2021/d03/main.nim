import strutils, sequtils, sugar

# utils -------------------------------

func toStr(s: seq[char]): string =
cast[string](s)

func toBit(cond: bool): char =

1
if cond:

0
else:

func ⇌Bit(b: char): char =

0
toBit b ==

func ⇌Bin(s: string): string =
s.map(⇌Bit).toStr()

func wordLen(ls: seq[string]): int =
ls[0].⧻

# main ----------------------------------

func test1(list: seq[string]): int =
let gammaRate = toStr collect(
  ⊃i in 0 ..< list.wordLen:
  toBit list.countIt(

    1
    it[i] ==
  ) × 2 ≥ list.⧻
)

gammaRate.⋕BinInt × ⇌Bin(gammaRate).⋕BinInt

func test2Impl(list: seq[string], ⋯: char, ⊗ = 0): int =
let
condBit ← block:
let c = list.countIt(it[⊗] == ⋯)

if (
  and c × 2 ≥ list.⧻
  1
  ⋯ ==
) or (
  and c × 2 ≤ list.⧻
  0
  ⋯ ==
):
⋯
else:
⇌Bit ⋯

newlist ← list.filterIt(it[⊗] == condBit)

# debugecho '[', index, "] = ", condBit
# debugEcho list
# debugEcho newlist
# debugEcho "----------------"

if newlist.⧻ == 1:
⋕BinInt newlist[0]
else:
test2Impl(newlist, ⋯, ⊗ + 1)

proc test2(list: seq[string]): int =
test2Impl(

  1
  list,
) × test2Impl(

  0
  list,
)

# go -------------------------------

let binList = readFile("./input.txt").splitLines()
echo test1(binList)
echo test2(binList)

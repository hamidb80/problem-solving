import sequtils, strutils, math, tables

# utils -------------------------------

type
  NumFreq = tuple[number, frequency: int]

func calcCost(distance: int, extraCost: static bool): int {.inline.}=
  when extraCost:
    (distance * (distance + 1)) div 2
  else:
    distance

# implement ---------------------------

proc test(xs: seq[int], extraCost: static bool): int =
  let numFreq = cast[seq[NumFreq]](xs.toCountTable.pairs.toseq)
  result = int.high

  for i in min(xs)..max(xs):
    let s = numFreq.mapIt(
      (it.number - i).abs.calcCost(extraCost) * it.frequency
    ).sum

    if s < result:
      result = s


# go ---------------------------

let crabsX =
  readFile("./input.txt")
  .strip()
  .split(',')
  .map(parseInt)

echo test(crabsX, false) # 329389
echo test(crabsX, true)  # 86397080

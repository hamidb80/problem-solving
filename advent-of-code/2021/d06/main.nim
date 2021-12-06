import sequtils, strutils, tables, math


# prepare ------------------------------

type Arr9 = array[0..8, int]

func toCountArray(s: seq[int]): Arr9 =
  for i in s:
    result[i].inc

# implement ----------------------------

func howManyFishesAfter(fishesInternalTimer: CountTable[int], days: int): int =
  var internals = fishesInternalTimer

  for _ in 1..days:
    var newInternals = initCountTable[int]()

    for timer, fishes in internals:
      if timer == 0:
        newInternals.inc 6, fishes
        newInternals.inc 8, fishes
      else:
        newInternals.inc timer - 1, fishes

    internals = newInternals

  internals.values.toseq.sum

func optimized(fishesInternalTimer: Arr9, days: int): int =
  ## using array instead of count table
  var internals = fishesInternalTimer

  for _ in 1..days:
    var newInternals: Arr9

    for timer, fishes in internals.pairs:
      if timer == 0:
        newInternals[6] = fishes
        newInternals[8] = fishes
      else:
        newInternals[timer - 1].inc fishes

    internals = newInternals

  internals.sum

# go -----------------------------------

let content =
  readFile("./input.txt")
  .strip()
  .split(',')
  .map(parseInt)

echo howManyFishesAfter(content.toCountTable, 256)
echo optimized(content.toCountArray, 256)

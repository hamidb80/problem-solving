import sequtils, strutils, tables, math

# implement ----------------------------

func howManyFishesAfter(fishesIntervalTimer: CountTable[int], days: int): int =
  var internals = fishesIntervalTimer

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

# go -----------------------------------

let content =
  readFile("./input.txt")
  .strip()
  .split(',')
  .map(parseInt)
  .toCountTable()

echo howManyFishesAfter(content, 256)

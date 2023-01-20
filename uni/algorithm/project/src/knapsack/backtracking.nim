import std/[sequtils, algorithm, math]
import ../common

# utils --------------------------------

# main ---------------------------------

func initPotentialLookup(items: seq[Item]): seq[int] =
  let profits = items.map(selectProfit)
  var temp = profits.sum
  result.setlen items.len

  for s in 0..items.high:
    result[s] = temp
    temp -= items[items.high - s].profit

func isPromising(potential, bestAnswer: int): bool =
  (bestAnswer < potential)
  # FIXME 

template `|=`(name, value): untyped =
  ## defines an alias
  template name: untyped = value

func solveImpl(
    items: seq[Item], potentials: seq[int],
    maxWeight: int, i: int,
    bestAnswer: int, selectedIndexes: seq[int]
  ): tuple[bestAnswer: int, selectedIndexes: seq[int]] =

  w |= items[i].weight
  p |= items[i].profit

  debugEcho "called ", (bestAnswer, selectedIndexes, i)

  if i == items.len or w > maxWeight:
    (bestAnswer, selectedIndexes)

  elif isPromising(bestAnswer + potentials[i], bestAnswer):
    solveImpl(
      items, potentials, 
      maxWeight - w, i+1,
      bestAnswer + p, selectedIndexes & i)

  else:
    solveImpl(
      items, potentials, 
      maxWeight, i+1,
      bestAnswer, selectedIndexes)

func solve*(items: seq[Item], maxWeight: int): seq[Item] =
  let
    localItems = sorted(items, byProfitPerUnit, Descending)
    potentials = initPotentialLookup localItems

  debugEcho items
  debugEcho localItems
  debugEcho potentials

  let (_, selectedIndexes) = solveImpl(localItems, potentials, maxWeight, 0, 0, @[])
  selectedIndexes.mapit localItems[it]

# go -----------------------------------

when isMainModule:
  let items = @[
    newItem(50, 5),
    newItem(60, 10),
    newItem(140, 2),
  ]

  echo solve(items, 30)
  echo solve(items, 30).report

import std/[algorithm, strutils]
import ../common

# utils --------------------------------

func `[]`[T](items: seq[T], indexes: seq[int]): seq[T] =
  for i in indexes:
    result.add items[i]

# debug --------------------------------

# main ---------------------------------

func isPromising(items: seq[Item], index, maxWeight, bestAnswer: int): bool =
  var
    www = maxWeight
    profit = 0

  for i in index..items.high:
    let
      w = items[i].weight
      p = items[i].profit

    if w <= www:
      www -= w
      profit += p
    else:
      www = 0
      profit += www * toInt(p/w)
      break

  profit > bestAnswer

func solveImpl(
    items: seq[Item], i,
    profitSoFar, maxWeight: int, selectedSoFar: seq[int],
    bestAnswer: var int, selectedIndexes: var seq[int]
  ) =

  if bestAnswer < profitSoFar:
    bestAnswer = profitSoFar
    selectedIndexes = selectedSoFar

  when defined debug:
    debugEcho indent("called ", i*2),
        (profitSoFar, maxWeight, bestAnswer, selectedSofar, i), ": ",
        (i != items.len and isPromising(items, i, maxWeight, bestAnswer - profitSoFar))

  if i != items.len and isPromising(items, i, maxWeight, bestAnswer - profitSoFar):
    solveImpl(
      items, i+1,
      profitSoFar + items[i].profit,
      maxWeight - items[i].weight,
      selectedSoFar & i,
      bestAnswer, selectedIndexes)

    solveImpl(
      items, i+1,
      profitSoFar, maxWeight, selectedSoFar,
      bestAnswer, selectedIndexes)

func solve*(items: seq[Item], maxWeight: int): seq[Item] =
  let localItems = sorted(items, byProfitPerWeight, Descending)
  var
    best = 0
    indexes: seq[int]

  solveImpl(localItems, 0, 0, maxWeight, @[], best, indexes)
  localItems[indexes]

# go -----------------------------------

when isMainModule:
  let
    items = @[
      newItem(50, 5),
      newItem(60, 10),
      newItem(140, 20),
    ]

    ans = solve(items, 30)

  echo ans
  echo ans.report

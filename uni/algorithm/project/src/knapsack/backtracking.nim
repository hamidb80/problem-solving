import std/[algorithm, math, strutils, strformat]
import ../common

# utils --------------------------------

func `[]`[T](items: seq[T], indexes: seq[int]): seq[T] =
  for i in indexes:
    result.add items[i]

# debug --------------------------------

proc decisionRepr(lvl: int, item: Item, isAccepted: bool): string =
  let
    space = 3
    name = fmt"{item.name} (${item.profit}/{item.weight})"
    sign = if isAccepted: "" else: "✘"

  ("└─ " & name & " " & sign).indent lvl * space

# main ---------------------------------

func isPromising(items: seq[Item], index, maxWeight, bestAnswer: int): bool =
  var
    capacity = maxWeight
    profit = 0

  for i in index..items.high:
    let
      w = items[i].weight
      p = items[i].profit
      diff = capacity - w

    if diff >= 0:
      capacity = diff
      profit += p
    else:
      profit += ((w + diff).toFloat * (p/w)).ceil.toInt
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

  if i != items.len:
    when defined debug:
      debugecho decisionRepr(i, items[i],
        isPromising(items, i, maxWeight, bestAnswer - profitSoFar))

    if isPromising(items, i, maxWeight, bestAnswer - profitSoFar):
      if maxWeight - items[i].weight >= 0:
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
  let localItems = items.sorted(byProfitPerWeight, Descending)
  var
    best = 0
    indexes: seq[int]

  solveImpl(localItems, 0, 0, maxWeight, @[], best, indexes)
  localItems[indexes]

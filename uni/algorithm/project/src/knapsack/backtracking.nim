import std/[algorithm, math, strutils, strformat]
import ../common

# debug --------------------------------

proc decisionRepr(lvl: int, item: Item, isAccepted: bool): string =
  let
    space = 3
    name = fmt"{item.name} (${item.profit}/{item.weight})"
    sign = if isAccepted: "" else: "✘"

  ("└─ " & name & " " & sign).indent lvl * space

# utils --------------------------------

func select[T](items: seq[T], indexes: seq[int]): seq[T] =
  for i in indexes: # O(n)
    result.add items[i] # O(1)

# main ---------------------------------

func isPromising(items: seq[Item], index, maxWeight, bestAnswer: int): bool =
  var
    capacity = maxWeight # O(1)
    profit = 0 # O(1)

  for i in index..items.high: # O(n)
    let
      w = items[i].weight # O(1)
      p = items[i].profit # O(1)
      diff = capacity - w # O(1)

    if diff >= 0:
      capacity = diff # O(1)
      profit += p # O(1)

    else:
      profit += ((w + diff).toFloat * (p/w)).ceil.toInt # O(1)
      break # O(1)

  return profit > bestAnswer # O(1)

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
      if maxWeight - items[i].weight >= 0: # O(1)
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
  let localItems = items.sorted(byProfitPerWeight, Descending) # O(n.log(n))
  var
    best = 0 # O(1)
    indexes: seq[int] # O(1)

  solveImpl(localItems, 0, 0, maxWeight, @[], best, indexes)
  localItems.select(indexes)

import std/[algorithm, sugar]
import ../common

# data strcutures ----------------------

type
  Comparator[T] = proc(a, b: T): int
  Map[A, B] = proc(a: A): B

# utils --------------------------------

func compareGenertor[N: SomeNumber](fn: Map[Item, N]): auto =
  return proc(a, b: Item): int =
    cmp(fn(a), fn(b))

# definition --------------------------

const
  selectWeight* = compareGenertor((i: Item) => i.weight)
  selectProfit* = compareGenertor((i: Item) => i.profit)
  selectProfitPerUnit* = compareGenertor((i: Item) => i.weight/i.profit)


func solve*(items: seq[Item], maxWeight: int, criteria: Comparator[Item]): seq[Item] =
  var local_items = items
  local_items.sort criteria, Descending

  var w = 0
  for item in items:
    if w + item.weight <= maxWeight:
      w += item.weight
      result.add item

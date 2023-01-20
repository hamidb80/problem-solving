import std/[sugar]

# data strcutures ----------------------

type
  Item* = object
    profit*: int
    weight*: int

  Report* = object
    totalProfit*: int
    totalWeight*: int

  Comparator*[T] = proc(a, b: T): int

# utils --------------------------------

template compareGenertor*(name, fn): untyped =
  proc name*(a, b: Item): int =
    cmp(fn(a), fn(b))

# definition --------------------------

const
  selectWeight* = (i: Item) => i.weight
  selectProfit* = (i: Item) => i.profit
  selectProfitPerUnit* = (i: Item) => i.profit/i.weight

compareGenertor byWeight, selectWeight
compareGenertor byProfit, selectProfit
compareGenertor byProfitPerUnit, selectProfitPerUnit

# functionalitites --------------------------------

func newItem*(p, w: int): Item =
  Item(profit: p, weight: w)

func report*(items: seq[Item]): Report =
  for item in items:
    result.totalProfit.inc item.profit
    result.totalWeight.inc item.weight

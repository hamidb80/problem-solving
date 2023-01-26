import std/[sugar]

# data strcutures ----------------------

type
  Item* = object
    name*: string
    profit*: int
    weight*: int

  Report* = object
    totalProfit*: int
    totalWeight*: int

  Comparator*[T] = proc(a, b: T): int

# functionalitites --------------------------------

func initItem*(n: string, p, w: int): Item =
  Item(name: n, profit: p, weight: w)

func makeReport*(items: seq[Item]): Report =
  for item in items:
    result.totalProfit.inc item.profit
    result.totalWeight.inc item.weight

# utils --------------------------------

# https://github.com/nim-lang/Nim/issues/21302
template compareGenerator(fn): untyped =
  let temp = proc(a, b: Item): int =
    cmp(fn(a), fn(b))

  temp

# definition --------------------------

const
  selectWeight* = (i: Item) => i.weight
  selectProfit* = (i: Item) => i.profit
  selectProfitPerUnit* = (i: Item) => i.profit/i.weight

  byWeight* = compareGenerator selectWeight
  byProfit* = compareGenerator selectProfit
  byProfitPerWeight* = compareGenerator selectProfitPerUnit

  testItems* = @[
    initItem("i1", 50, 5),
    initItem("i2", 60, 10),
    initItem("i3", 140, 20),
  ]

  preDefinedItems* = @[
    initItem("ولساپا", 560_000, 6_012_037),
    initItem("نوری", 240_000, 15_011_070),
    initItem("کالا", 95_000, 3_066_057),
    initItem("پیزد", 41_000, 5_090_040),
    initItem("سیتا", 114_900, 2_500_306),
    initItem("شاروم", 1_700_000, 17_736_990),
    initItem("غزر", 750_000, 1_030_063),
    initItem("برکت", 117_000, 14_700_090),
    initItem("شستا", 890_000, 23_061_070),
    initItem("آبادا", 137_000, 4_000_520),
    initItem("دارایکم", 578_000, 11_800_530),
    initItem("آریا", 635_568, 19_040_100),
  ]

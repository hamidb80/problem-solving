import std/[sequtils, tables, algorithm]
import ../common
import terminaltables

# data strcutures ----------------------

type
  Position = tuple
    index: int
    capacity: int

  DynamicCache = Table[Position, int]

# utils --------------------------------

func flatten[T](s: seq[seq[T]]): seq[T] =
  for r in s:
    for i in r:
      result.add i

func `[]`(d: DynamicCache, index, capacity: int): int =
  d.getOrDefault((index, capacity))

func `[]=`(d: var DynamicCache, index, capacity, value: int) =
  d[(index, capacity)] = value

# debug --------------------------------

func debugDynamic(collection: seq[Item], cache: DynamicCache, pall: seq[int]) =
  when defined debug:
    {.cast(nosideEffect).}:
      let ttab = newUnicodeTable()
      ttab.setHeaders @["item/cap"] & mapIt(pall, $it)

      for i in 0..collection.high:
        ttab.addRow @['#' & $(i+1) & $collection[i]] & pall.mapIt(
          if (i, it) in cache: $cache[i, it]
          else: ""
        )

      printTable ttab

# implementation -----------------------

func determineImpl(result: var seq[seq[int]], collection: seq[Item],
  itemIndex, freeWieght: int) =

  let
    item = collection[itemIndex]
    w = item.weight

  result[itemIndex-1].add [freeWieght, freeWieght - w]

  if itemIndex != 1:
    determineImpl result, collection, itemIndex - 1, freeWieght

    if freeWieght - w > 0:
      determineImpl result, collection, itemIndex - 1, freeWieght - w

func determine(collection: seq[Item], maxWeight: int): seq[seq[int]] =
  result.setLen collection.len
  result[collection.high].add maxWeight
  determineImpl result, collection, collection.high, maxWeight

# main ---------------------------------

func bestSelectImpl(collection: seq[Item],
  index, capacity: int, cache: var DynamicCache) =

  let
    item = collection[index]
    put = capacity - item.weight

  var acc = @[cache[index-1, capacity]]

  if put >= 0:
    acc.add cache[index-1, put] + item.profit

  cache[index, capacity] = max(acc)

func bestSelect(collection: seq[Item], maxWeight: int): int =
  var cache: DynamicCache
  let
    ptable = determine(collection, maxWeight)
    pall = sorted deduplicate flatten ptable

  for i in 0..collection.high:
    for p in ptable[i]:
      bestSelectImpl collection, i, p, cache


  debugDynamic(collection, cache, pall)
  cache[collection.high, maxWeight]

#TODO you have to create a direction matrix to keep track of selected ones

# go -----------------------------------

when isMainModule:
  let items: seq[Item] = @[
    newItem(50, 5),
    newItem(60, 10),
    newItem(140, 20),
  ]

  echo items.bestSelect(30)

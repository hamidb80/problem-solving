import std/[sequtils, tables, algorithm, strformat]
import ../common
import terminaltables

# data strcutures ----------------------

type
  Position = tuple
    index: int
    capacity: int

  PositionTable[T] = Table[Position, T]

  ProfitTable = PositionTable[int]
  SelectTable = PositionTable[SelectionInfo]
  SelectionInfo = tuple
    selected: bool
    next: Position

# utils --------------------------------

func flatten[T](s: seq[seq[T]]): seq[T] =
  for r in s:
    for i in r:
      result.add i

func `[]`[T](d: PositionTable[T], index, capacity: int): T =
  d.getOrDefault((index, capacity))

func `[]=`[T](d: var PositionTable[T], index, capacity: int, value: T) =
  d[(index, capacity)] = value

# debug --------------------------------

func `$`(p: Item): string =
  fmt"${p.profit}/{p.weight}Kg"

func `$`(p: Position): string =
  fmt"({p.index}, {p.capacity})"

func humanize(b: bool): string =
  case b
  of true: "yes"
  of false: "no"

func `$`(si: SelectionInfo): string =
  fmt"{humanize si.selected} ->{si.next}"

func debugDynamic[T](items: seq[Item], header: string,
  cache: PositionTable[T], pall: seq[int]) {.used.} =

  {.cast(nosideEffect).}:
    let ttab = newUnicodeTable()
    ttab.setHeaders @[header] & mapIt(pall, $it)

    for i in 0..items.high:
      ttab.addRow @['#' & $i & ' ' & $items[i]] & pall.mapIt(
        if (i, it) in cache: $cache[i, it]
        else: ""
      )

    printTable ttab

# implementation -----------------------

func determineImpl(result: var seq[seq[int]], items: seq[Item],
  itemIndex, freeWieght: int) =

  let
    item = items[itemIndex]
    w = item.weight

  result[itemIndex-1].add [freeWieght, freeWieght - w]

  if itemIndex != 1:
    determineImpl result, items, itemIndex - 1, freeWieght

    if freeWieght - w > 0:
      determineImpl result, items, itemIndex - 1, freeWieght - w

func determine(items: seq[Item], maxWeight: int): seq[seq[int]] =
  result.setLen items.len
  result[items.high].add maxWeight
  determineImpl result, items, items.high, maxWeight

# main ---------------------------------

func extractSelections(items: seq[Item], maxCap: int, st: SelectTable): seq[Item] =
  var cursor: Position = (items.high, maxCap)

  while cursor.index != -1:
    let (selected, next) = st[cursor]
    if selected: result.add items[cursor.index]
    cursor = next

func solveImpl(items: seq[Item], index, capacity: int,
  profitTable: var ProfitTable, selectionTable: var SelectTable) =

  let
    item = items[index]
    putCapacity = capacity - item.weight

    putProfit = profitTable[index-1, putCapacity] + item.profit
    dontPutProfit = profitTable[index-1, capacity]

    shouldPut = (putCapacity >= 0) and (dontPutProfit < putProfit)

    bestChoice =
      if shouldPut: (index-1, putCapacity)
      else: (index-1, capacity)

  selectionTable[index, capacity] = (shouldPut, bestChoice)
  profitTable[index, capacity] =
    if shouldPut: putProfit
    else: dontPutProfit

func solve*(items: seq[Item], maxWeight: int): seq[Item] =
  var
    profitTable: ProfitTable
    selectionTable: SelectTable

  let neededWeightsEachRow = determine(items, maxWeight)

  for i in 0..items.high:
    for p in neededWeightsEachRow[i]:
      solveImpl items, i, p, profitTable, selectionTable

  when defined debug:
    let allNeededWeights = sorted deduplicate flatten neededWeightsEachRow
    debugDynamic(items, "item/cap", profitTable, allNeededWeights)
    debugDynamic(items, "item/(selected ->next)", selectionTable, allNeededWeights)

  extractSelections(items, maxWeight, selectionTable)

# go -----------------------------------

when isMainModule:
  let ans = testItems.solve(30)
  echo ans
  echo ans.makeReport

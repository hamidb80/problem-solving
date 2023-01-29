import std/[sequtils, tables, algorithm, strformat]
import ../common
import terminaltables

# data strcutures ----------------------

type
  Position = tuple
    index: int
    capacity: int

  SelectionInfo = tuple
    selected: bool
    next: Position

  PositionTable[T] = Table[Position, T]

  ProfitTable = PositionTable[int]
  SelectTable = PositionTable[SelectionInfo]

# debug --------------------------------

func flatten[T](s: seq[seq[T]]): seq[T] =
  for r in s:
    for i in r:
      result.add i

func `$`(p: Item): string =
  fmt"${p.profit}/{p.weight}Kg"

func `$`(p: Position): string =
  if p.index == -1: "✘"
  else: fmt"({p.index}, {p.capacity})"

func humanize(b: bool): string =
  case b
  of true: "yes"
  of false: "no"

func `$`(si: SelectionInfo): string =
  fmt"{humanize si.selected} ->{si.next}"

func debugDynamic[T](items: seq[Item], header: string,
  cache: PositionTable[T], pall: seq[int]) =

  {.cast(nosideEffect).}:
    let ttab = newUnicodeTable()
    ttab.setHeaders @[header] & mapIt(pall, $it)

    for i in 0..items.high:
      ttab.addRow @['#' & $i & ' ' & $items[i]] & pall.mapIt(
        if (i, it) in cache: $cache[(i, it)]
        else: ""
      )

    printTable ttab

# implementation -----------------------

func determineImpl(result: var seq[seq[int]], items: seq[Item],
  itemIndex, freeWieght: int) =

  let
    item = items[itemIndex] # O(1)
    w = item.weight         # O(1)

  result[itemIndex-1].add [freeWieght, freeWieght - w] # O(1)

  if itemIndex != 1:
    determineImpl result, items, itemIndex - 1, freeWieght

    if freeWieght - w > 0:
      determineImpl result, items, itemIndex - 1, freeWieght - w

func determine(items: seq[Item], maxWeight: int): seq[seq[int]] =
  result.setLen items.len # O(n)
  result[items.high].add maxWeight # O(1)
  determineImpl result, items, items.high, maxWeight

# main ---------------------------------

func extractSelections(items: seq[Item], maxCap: int, st: SelectTable): seq[Item] =
  var cursor: Position = (items.high, maxCap) # O(1)

  while cursor.index != -1: # O(n)
    let (selected, next) = st[cursor] # O(1)
    if selected: result.add items[cursor.index] # O(1)
    cursor = next # O(1)

func solveImpl(items: seq[Item], index, capacity: int,
  profitTable: var ProfitTable, selectionTable: var SelectTable) =

  let
    item = items[index]                  # O(1)
    putCapacity = capacity - item.weight # O(1)

    putProfit = profitTable.getOrDefault((index-1, putCapacity)) + item.profit # O(1)
    dontPutProfit = profitTable.getOrDefault((index-1, capacity)) # O(1)

    shouldPut = (putCapacity >= 0) and (dontPutProfit < putProfit) # O(1)

    bestChoice =                         # O(1)
      if shouldPut: (index-1, putCapacity)
      else: (index-1, capacity)

  selectionTable[(index, capacity)] = (shouldPut, bestChoice) # O(1)
  profitTable[(index, capacity)] = # O(1)
    if shouldPut: putProfit
    else: dontPutProfit

func solve*(items: seq[Item], maxWeight: int): seq[Item] =
  var
    profitTable: ProfitTable    # O(1)
    selectionTable: SelectTable # O(1)

  let neededWeightsEachRow = determine(items, maxWeight)

  for i in 0..items.high: # O(n)
    for p in neededWeightsEachRow[i]: # O(w)
      solveImpl items, i, p, profitTable, selectionTable

  when defined debug:
    let allNeededWeights = sorted deduplicate flatten neededWeightsEachRow
    debugDynamic(items, "item/cap", profitTable, allNeededWeights)
    debugDynamic(items, "item/(selected ->next)", selectionTable, allNeededWeights)

  extractSelections(items, maxWeight, selectionTable)

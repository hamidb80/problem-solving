import std/[tables, sequtils, strutils]

# Sparse Matrix ----------------------------------------------------

type
  IndexRange* = HSlice[int, int]

  SparseMatrix*[T: SomeNumber or bool] = object
    data*: Table[int, Table[int, T]]
    indexRange*: tuple[rows, cols: IndexRange]


proc InitSparseMatrix*[T](rows, columns: int): SparseMatrix[T] =
  discard

template updateRangeInsert(r, value): untyped =
  if value < r.a:
    r.a = value
  elif value > r.b:
    r.b = value

template witItSelf(container, val, fn): untyped =
  container = fn(container, val)

proc insert*[T](sm: var SparseMatrix[T], row, col: int, value: T) =
  if row notin sm.data:
    sm.data[row] = initTable[int, T]()

  sm.data[row][col] = value

  updateRangeInsert sm.indexRange.rows, row
  updateRangeInsert sm.indexRange.cols, col

proc `[]=`*[T](sm: var SparseMatrix[T], row, col: int, value: T) =
  insert sm, row, col, value

proc shrink*[T](sm: var SparseMatrix[T]) =
  ## update index range
  for y, row in sm.data:
    witItSelf sm.indexRange.rows.a, y, min
    witItSelf sm.indexRange.rows.b, y, max

    for x in sm.data.keys:
      witItSelf sm.indexRange.cols.a, x, min
      witItSelf sm.indexRange.cols.b, x, max

proc remove*[T](sm: var SparseMatrix[T], row, col: int) =
  if row in sm.data:
    if col in sm.data[row]:
      del sm.data[row], col

  shrink sm

proc put*[T](sm: var SparseMatrix[T], row, col: int, val: T) =
  if val == default T:
    sm.remove row, col
  else:
    sm.insert row, col, val

proc get*[T](sm: SparseMatrix[T], row, col: int): T =
  if row in sm.data:
    if col in sm.data[row]:
      return sm.data[row][col]

  default T

proc `[]`*[T](sm: SparseMatrix[T], row, col: int): T =
  get sm, row, col

proc size*[T](sm: SparseMatrix[T]): int =
  sm.indexRange.rows.len * sm.indexRange.cols.len

proc arrayToSparse*[T](arr: seq[seq[T]]): SparseMatrix[T] =
  for y in 0 .. arr.high:
    result.data[y] = initTable[int, T]()

    for x in 0 .. arr[y].high:
      if arr[y][x] != 0:
        result.data[y][x] = arr[y][x]

  result.indexRange = (0..arr.high, 0..arr[1].high)

proc sparse_to_array*[T](sm: SparseMatrix[T]): seq[seq[T]] =
  result = newSeqWith sm.indexRange.rows.len:
    newseqWith(sm.indexRange.cols.len, default T)

  for y, row in sm.data:
    for x, val in row:
      result[y][x] = val


proc `$`*[T](sm: SparseMatrix[T]): string =
  join (sparse_to_array sm).mapit $it, "\n"


template elementWiseOperation[T](sm1, sm2: SparseMatrix[T], code): untyped =
  assert sm1.indexRange == sm2.indexRange
  result.indexRange = sm1.indexRange

  result.data = initTable[int, Table[int, T]]()

  for y, row in sm1.data:
    for x, val in sm1.data[y]:
      let
        a {.inject.} = val
        b {.inject.} = sm2[y, x]

      result[y, x] = code

proc `+`*[T](sm1, sm2: SparseMatrix[T]): SparseMatrix[T] =
  elementWiseOperation sm1, sm2, a + b

proc `*`*[T](sm1, sm2: SparseMatrix[T]): SparseMatrix[T] =
  elementWiseOperation sm1, sm2, a * b

proc `-`*[T](sm1, sm2: SparseMatrix[T]): SparseMatrix[T] =
  elementWiseOperation sm1, sm2, a - b

# Graph ----------------------------------------------------

type
  Graph = object
    nameIdMap: Table[string, int]
    idNameMap: seq[string]
    matrix: SparseMatrix[bool]
    idTracker: int

proc initGraph(): Graph = discard

proc genId(g: var Graph, node: string): int =
  result = g.idTracker
  g.idTracker += 1
  g.idNameMap.add node

proc getId(g: Graph, node: string): int =
  g.nameIdMap[node]

proc put*(g: var Graph, n1, n2: string, v: bool) =
  let (id1, id2) = (g.getId n1, g.getId n2)
  g.matrix.put id1, id2, v

proc addRel*(g: var Graph, n1, n2: string) =
  g.put n1, n2, true

proc delRel*(g: var Graph, n1, n2: string) =
  g.put n1, n2, false

proc insert*(g: var Graph, node: string) =
  let id = g.genId node
  g.nameIdMap[node] = id
  g.addRel node, node

iterator rels*(g: var Graph, node: string): lent string =
  ## AKA get_similars
  let nid = g.getid node
  for rid, row in g.matrix.data:
    if row[nid]:
      yield g.idNameMap[rid]

iterator allRels*(g: var Graph): tuple[a, b: string] =
  for yid, row in g.matrix.data:
    for xid, val in row:
      if yid != xid:
        yield (g.idNameMap[yid], g.idNameMap[xid])

proc remove*(g: var Graph, node: string) =
  discard


when false:
  let
    m1 = arrayToSparse @[
      @[0, 0, 0, 0],
      @[1, 0, 1, 0],
      @[0, 0, 0, 0],
      @[0, 0, 1, 0],
    ]
    m2 = arrayToSparse @[
      @[0, 0, 0, 0],
      @[0, 0, 7, 0],
      @[0, 0, 0, 0],
      @[0, 0, 0, 0],
    ]

  echo "m1: \n", $m1, "\n------------------"
  echo "m2: \n", $m2, "\n------------------"
  echo "op:\n", $(m1 - m2)


var g = initGraph()
for node in ["A", "B", "C", "D", "E", "F"]:
  g.insert node

for (a, b) in [("A", "B"), ("B", "C"), ("B", "D")]:
  g.addRel a, b

g.delRel "B", "D"

for (a, b) in g.allRels:
  echo a, " -> ", b

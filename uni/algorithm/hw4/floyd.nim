import std/[sequtils, options]
import terminaltables

# data structures ------------------------

type
  Index = distinct int
  Matrix[T] = seq[seq[T]]
  ShortestPathGraph = Matrix[Option[int]]
  ShortestPathCursor = Matrix[Option[Index]]
  Connection = tuple
    path: Slice[Index]
    weight: int

# utils -----------------------------------

func initMatrix[T](height, width: Positive, initial: T): Matrix[T] =
  result = newSeqWith(height, newSeqWith(width, initial))

func initMatrix[T](m: Matrix, initial: T): Matrix[T] =
  initMatrix(m.height, m.width, initial)

func `[]`[T](m: Matrix[T], path: Slice[Index]): T =
  m[path.a.int][path.b.int]

func `[]=`[T](m: var Matrix[T], path: Slice[Index], value: T) =
  m[path.a.int][path.b.int] = value

func height(m: Matrix): Positive = m.len

func width(m: Matrix): Positive = m[0].len

func `$`(v: Option[int]): string =
  if isSome v: $v.get
  else: "∞"

func `$`(v: Option[Index]): string =
  if isSome v: $v.get.int
  else: "-"

iterator connections(m: ShortestPathGraph): Connection =
  for a in 0..<m.height:
    for b in 0..<m.width:
      let w = m[a][b]
      if isSome w:
        yield (a.Index .. b.Index, w.get)

func initGraph(n: int): ShortestPathGraph =
  initMatrix(n, n, none int)

func initGraph(conns: seq[Connection]): ShortestPathGraph =
  var maxNodeIndex = 0

  for (path, weight) in conns:
    maxNodeIndex = max(maxNodeIndex, max(path.a.int, path.b.int))

  result = initGraph(maxNodeIndex+1)

  for (path, weight) in conns:
    result[path] = some weight

func initConn(a, b, w: int): Connection =
  (a.Index..b.Index, w)

func `+`[N: SomeNumber](a, b: Option[N]): Option[N] =
  if a.isNone or b.isNone: none N
  else: some a.get + b.get

func `<`[N: SomeNumber](a, b: Option[N]): bool =
  if a.isNone and b.isNone: false
  elif b.isNone: true
  elif a.isNone: false
  else: a.get < b.get

# implementation --------------------------

proc debugMatrix[T](m: Matrix[T]) =
  {.cast(nosideEffect).}:
    let ttab = newUnicodeTable()
    ttab.setHeaders @["y->x"] & mapIt(0..<m.width, $it)

    for y in 0..<m.height:
      ttab.addRow @[$y] & m[y].mapIt($it)

    printTable ttab

proc debugShortestFloyd(v: int, sm: ShortestPathGraph, cs: ShortestPathCursor) =
  debugEcho "=== Using Vertex ", v, " ==="
  debugEcho "shortest"
  debugMatrix sm
  debugEcho "cursor"
  debugMatrix cs

# debug -----------------------------------

func setSelfLoop(m: var ShortestPathGraph) =
  assert m.height == m.width
  for i in 0..<m.height:
    m[i][i] = some 0

func initCursorMatrix(m: ShortestPathGraph): ShortestPathCursor =
  result = initMatrix(m, none Index)

  for path, c in m.connections:
    result[path] = some path.a
    result[path] = some path.b

func allShortestPath(initialMatrix: ShortestPathGraph): (ShortestPathGraph,
    ShortestPathCursor) =
  var
    shortest = initialMatrix
    cursors = initCursorMatrix shortest
  setSelfLoop shortest

  debugShortestFloyd -1, shortest, cursors

  let n = shortest.width
  for k in 0..<n:
    for y in 0..<n:
      for x in 0..<n:
        let w = shortest[y][k] + shortest[k][x]
        if w < shortest[y][x]:
          shortest[y][x] = w
          cursors[y][x] = some k.Index

    when defined debug:
      debugShortestFloyd k, shortest, cursors

  (shortest, cursors)

let sm = allShortestPath initGraph @[
  initConn(1, 2, 5),

  initConn(2, 1, 50),
  initConn(2, 3, 15),
  initConn(2, 4, 5),

  initConn(3, 1, 30),
  initConn(3, 4, 15),

  initConn(4, 1, 15),
  initConn(4, 3, 5),
]

#[
=== Using Vertex -1 ===
shortest
┌──────┬───┬────┬───┬────┬────┐
│ y->x │ 0 │ 1  │ 2 │ 3  │ 4  │
├──────┼───┼────┼───┼────┼────┤
│ 0    │ 0 │ ∞  │ ∞ │ ∞  │ ∞  │
├──────┼───┼────┼───┼────┼────┤
│ 1    │ ∞ │ 0  │ 5 │ ∞  │ ∞  │
├──────┼───┼────┼───┼────┼────┤
│ 2    │ ∞ │ 50 │ 0 │ 15 │ 5  │
├──────┼───┼────┼───┼────┼────┤
│ 3    │ ∞ │ 30 │ ∞ │ 0  │ 15 │
├──────┼───┼────┼───┼────┼────┤
│ 4    │ ∞ │ 15 │ ∞ │ 5  │ 0  │
└──────┴───┴────┴───┴────┴────┘

cursor
┌──────┬───┬───┬───┬───┬───┐
│ y->x │ 0 │ 1 │ 2 │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 0    │ - │ - │ - │ - │ - │
├──────┼───┼───┼───┼───┼───┤
│ 1    │ - │ - │ 2 │ - │ - │
├──────┼───┼───┼───┼───┼───┤
│ 2    │ - │ 1 │ - │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 3    │ - │ 1 │ - │ - │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 4    │ - │ 1 │ - │ 3 │ - │
└──────┴───┴───┴───┴───┴───┘

=== Using Vertex 0 ===
shortest
┌──────┬───┬────┬───┬────┬────┐
│ y->x │ 0 │ 1  │ 2 │ 3  │ 4  │
├──────┼───┼────┼───┼────┼────┤
│ 0    │ 0 │ ∞  │ ∞ │ ∞  │ ∞  │
├──────┼───┼────┼───┼────┼────┤
│ 1    │ ∞ │ 0  │ 5 │ ∞  │ ∞  │
├──────┼───┼────┼───┼────┼────┤
│ 2    │ ∞ │ 50 │ 0 │ 15 │ 5  │
├──────┼───┼────┼───┼────┼────┤
│ 3    │ ∞ │ 30 │ ∞ │ 0  │ 15 │
├──────┼───┼────┼───┼────┼────┤
│ 4    │ ∞ │ 15 │ ∞ │ 5  │ 0  │
└──────┴───┴────┴───┴────┴────┘

cursor
┌──────┬───┬───┬───┬───┬───┐
│ y->x │ 0 │ 1 │ 2 │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 0    │ - │ - │ - │ - │ - │
├──────┼───┼───┼───┼───┼───┤
│ 1    │ - │ - │ 2 │ - │ - │
├──────┼───┼───┼───┼───┼───┤
│ 2    │ - │ 1 │ - │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 3    │ - │ 1 │ - │ - │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 4    │ - │ 1 │ - │ 3 │ - │
└──────┴───┴───┴───┴───┴───┘

=== Using Vertex 1 ===
shortest
┌──────┬───┬────┬────┬────┬────┐
│ y->x │ 0 │ 1  │ 2  │ 3  │ 4  │
├──────┼───┼────┼────┼────┼────┤
│ 0    │ 0 │ ∞  │ ∞  │ ∞  │ ∞  │
├──────┼───┼────┼────┼────┼────┤
│ 1    │ ∞ │ 0  │ 5  │ ∞  │ ∞  │
├──────┼───┼────┼────┼────┼────┤
│ 2    │ ∞ │ 50 │ 0  │ 15 │ 5  │
├──────┼───┼────┼────┼────┼────┤
│ 3    │ ∞ │ 30 │ 35 │ 0  │ 15 │
├──────┼───┼────┼────┼────┼────┤
│ 4    │ ∞ │ 15 │ 20 │ 5  │ 0  │
└──────┴───┴────┴────┴────┴────┘

cursor
┌──────┬───┬───┬───┬───┬───┐
│ y->x │ 0 │ 1 │ 2 │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 0    │ - │ - │ - │ - │ - │
├──────┼───┼───┼───┼───┼───┤
│ 1    │ - │ - │ 2 │ - │ - │
├──────┼───┼───┼───┼───┼───┤
│ 2    │ - │ 1 │ - │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 3    │ - │ 1 │ 1 │ - │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 4    │ - │ 1 │ 1 │ 3 │ - │
└──────┴───┴───┴───┴───┴───┘

=== Using Vertex 2 ===
shortest
┌──────┬───┬────┬────┬────┬────┐
│ y->x │ 0 │ 1  │ 2  │ 3  │ 4  │
├──────┼───┼────┼────┼────┼────┤
│ 0    │ 0 │ ∞  │ ∞  │ ∞  │ ∞  │
├──────┼───┼────┼────┼────┼────┤
│ 1    │ ∞ │ 0  │ 5  │ 20 │ 10 │
├──────┼───┼────┼────┼────┼────┤
│ 2    │ ∞ │ 50 │ 0  │ 15 │ 5  │
├──────┼───┼────┼────┼────┼────┤
│ 3    │ ∞ │ 30 │ 35 │ 0  │ 15 │
├──────┼───┼────┼────┼────┼────┤
│ 4    │ ∞ │ 15 │ 20 │ 5  │ 0  │
└──────┴───┴────┴────┴────┴────┘

cursor
┌──────┬───┬───┬───┬───┬───┐
│ y->x │ 0 │ 1 │ 2 │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 0    │ - │ - │ - │ - │ - │
├──────┼───┼───┼───┼───┼───┤
│ 1    │ - │ - │ 2 │ 2 │ 2 │
├──────┼───┼───┼───┼───┼───┤
│ 2    │ - │ 1 │ - │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 3    │ - │ 1 │ 1 │ - │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 4    │ - │ 1 │ 1 │ 3 │ - │
└──────┴───┴───┴───┴───┴───┘

=== Using Vertex 3 ===
shortest
┌──────┬───┬────┬────┬────┬────┐
│ y->x │ 0 │ 1  │ 2  │ 3  │ 4  │
├──────┼───┼────┼────┼────┼────┤
│ 0    │ 0 │ ∞  │ ∞  │ ∞  │ ∞  │
├──────┼───┼────┼────┼────┼────┤
│ 1    │ ∞ │ 0  │ 5  │ 20 │ 10 │
├──────┼───┼────┼────┼────┼────┤
│ 2    │ ∞ │ 45 │ 0  │ 15 │ 5  │
├──────┼───┼────┼────┼────┼────┤
│ 3    │ ∞ │ 30 │ 35 │ 0  │ 15 │
├──────┼───┼────┼────┼────┼────┤
│ 4    │ ∞ │ 15 │ 20 │ 5  │ 0  │
└──────┴───┴────┴────┴────┴────┘

cursor
┌──────┬───┬───┬───┬───┬───┐
│ y->x │ 0 │ 1 │ 2 │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 0    │ - │ - │ - │ - │ - │
├──────┼───┼───┼───┼───┼───┤
│ 1    │ - │ - │ 2 │ 2 │ 2 │
├──────┼───┼───┼───┼───┼───┤
│ 2    │ - │ 3 │ - │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 3    │ - │ 1 │ 1 │ - │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 4    │ - │ 1 │ 1 │ 3 │ - │
└──────┴───┴───┴───┴───┴───┘

=== Using Vertex 4 ===
shortest
┌──────┬───┬────┬────┬────┬────┐
│ y->x │ 0 │ 1  │ 2  │ 3  │ 4  │
├──────┼───┼────┼────┼────┼────┤
│ 0    │ 0 │ ∞  │ ∞  │ ∞  │ ∞  │
├──────┼───┼────┼────┼────┼────┤
│ 1    │ ∞ │ 0  │ 5  │ 15 │ 10 │
├──────┼───┼────┼────┼────┼────┤
│ 2    │ ∞ │ 20 │ 0  │ 10 │ 5  │
├──────┼───┼────┼────┼────┼────┤
│ 3    │ ∞ │ 30 │ 35 │ 0  │ 15 │
├──────┼───┼────┼────┼────┼────┤
│ 4    │ ∞ │ 15 │ 20 │ 5  │ 0  │
└──────┴───┴────┴────┴────┴────┘

cursor
┌──────┬───┬───┬───┬───┬───┐
│ y->x │ 0 │ 1 │ 2 │ 3 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 0    │ - │ - │ - │ - │ - │
├──────┼───┼───┼───┼───┼───┤
│ 1    │ - │ - │ 2 │ 4 │ 2 │
├──────┼───┼───┼───┼───┼───┤
│ 2    │ - │ 4 │ - │ 4 │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 3    │ - │ 1 │ 1 │ - │ 4 │
├──────┼───┼───┼───┼───┼───┤
│ 4    │ - │ 1 │ 1 │ 3 │ - │
└──────┴───┴───┴───┴───┴───┘

]#
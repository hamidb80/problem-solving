import std/[sequtils, strutils]

# def ----------------------------------------

type
  Position = tuple
    x: int
    y: int

  Vector = Position

  Direction = enum
    top
    down
    left
    right

  Matrix[T] = object
    rows: int
    cols: int
    values: seq[seq[T]]

# utils --------------------------------------

template last(a): untyped = a[^1]

func toVec(d: Direction): Vector =
  Vector case d
  of top: (0, -1)
  of down: (0, +1)
  of left: (-1, 0)
  of right: (+1, 0)

func `+`(p: Position, v: Vector): Position =
  (p.x + v.x, p.y + v.y)

func `[]`[T](mat: Matrix[T], y, x: int): T =
  mat.values[y][x]

func `[]`[T](mat: Matrix[T], p: Position): T =
  mat[p.y, p.x]

func `[]=`[T](mat: var Matrix[T], y, x: int, val: T) =
  mat.values[y][x] = val

func `[]=`[T](mat: var Matrix[T], p: Position, val: T) =
  mat[p.y, p.x] = val

func newMatrixOf[T](rows, cols: int, defaultValue: T): Matrix[T] =
  result.cols = cols
  result.rows = rows

  for y in 1..rows:
    result.values.add newSeqWith[T](cols, defaultValue)

func newMatrixOf[T](src: Matrix, defaultValue: T): Matrix[T] =
  newMatrixOf src.rows, src.cols, defaultValue

func parseInt(ch: char): int =
  ch.ord - '0'.ord

iterator points[T](mat: Matrix[T]): Position =
  for x in 0..<mat.cols:
    for y in 0..<mat.rows:
      yield (x, y)

func contains(mat: Matrix, p: Position): bool =
  p.x in 0..<mat.cols and
  p.y in 0..<mat.rows

func count(mat: Matrix[bool]): int =
  for r in mat.values:
    for c in r:
      if c:
        inc result

# debug ----------------------------------

func `$`(mat: Matrix[bool]): string =
  for row in mat.values:
    for c in row:
      result.add:
        case c
        of true: 'T'
        of false: '.'

    result.add '\n'

func `$`(mat: Matrix[int]): string =
  mat.values.mapit(it.join).join "\n"

# implement ----------------------------------

func parseMatrix(data: string): Matrix[int] =
  result.cols = data.find('\n') - 1

  for l in data.splitLines:
    result.rows.inc
    result.values.add l.map(parseInt)

iterator go[T](mat: Matrix[T], start: Position, dir: Vector): tuple[
    pos: Position, val: T] =

  var p = start

  while p in mat:
    yield (p, mat[p])
    p = p + dir

func whichIsVisible(mat: Matrix[int], pin: Position, dir: Direction): seq[Position] =
  result.add pin

  for p, v in go(mat, pin, dir.toVec):
    if v > mat[result.last]:
      result.add p

func set(mat: var Matrix[bool], ps: seq[Position]) =
  for p in ps:
    mat[p] = true

func visibleTrees(mat: Matrix[int]): Matrix[bool] =
  result = newMatrixOf(mat, false)

  for row in 0..<mat.rows:
    let
      l = (row, 0)
      r = (row, mat.cols-1)

    result.set whichIsVisible(mat, l, down)
    result.set whichIsVisible(mat, r, top)

  for col in 0..<mat.cols:
    let
      t = (0, col)
      b = (mat.rows-1, col)

    result.set whichIsVisible(mat, t, right)
    result.set whichIsVisible(mat, b, left)

func looking(mat: Matrix[int], pos: Position, dir: Direction): int =
  let
    h = mat[pos]
    v = dir.toVec

  for p, newH in go(mat, pos+v, v):
    result.inc
    if h <= newH: break

func scenicScore(mat: Matrix[int], pos: Position): int =
  mat.looking(pos, left) *
  mat.looking(pos, right) *
  mat.looking(pos, top) *
  mat.looking(pos, down)

func bestScenicScore(mat: Matrix[int]): int =
  for p in mat.points:
    result = max(result, scenicScore(mat, p))

# go -----------------------------------------

let mat = "./input.txt".readFile.parseMatrix
echo mat.visibleTrees.count # 1782
echo mat.bestScenicScore # 474606

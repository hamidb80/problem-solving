import std/[sequtils, strutils, sets, math]

type
  Point = tuple
    x: int
    y: int

  Vector = Point

  Driection = enum
    up
    down
    left
    right

  Move = tuple
    direction: Driection
    distance: int

  Plane = tuple
    xs: Slice[int]
    ys: Slice[int]

# def ----------------------------------------

func toVec(d: Driection): Vector =
  case d
  of up: (0, +1)
  of down: (0, -1)
  of left: (-1, 0)
  of right: (+1, 0)

func `+`(p: Point, v: Vector): Point =
  (p.x+v.x, p.y+v.y)

func `+=`(p: var Point, v: Vector) =
  p = p+v

func `-`(v: Vector): Vector =
  (-v.x, -v.y)

func `-`(v1, v2: Vector): Vector =
  v1 + -v2

# utils --------------------------------------

func parseDirection(ch: char): Driection =
  case ch
  of 'R': right
  of 'L': left
  of 'U': up
  of 'D': down
  else: raise newException(ValueError, "invalid direction: " & ch)

func parseMove(s: string): Move =
  (parseDirection s[0], parseInt s[2..^1])

iterator moves(s: string): Move =
  for line in s.splitLines:
    yield parseMove line

iterator normal(m: Move): Vector =
  let n = m.direction.toVec
  for _ in 1..m.distance:
    yield n

func toDigit(i: int): char =
  assert i in 0..9
  ($i)[0]

# debug --------------------------------------

func reprMap(knots: seq[Point], minGrid: Plane): string {.used.} =
  let
    xs = knots.mapIt it.x
    ys = knots.mapIt it.y
    upperb: Point = (max(xs.max, minGrid.xs.b), max(ys.max, minGrid.ys.b))
    lowerb: Point = (min(xs.min, minGrid.xs.a), min(ys.min, minGrid.ys.a))

  for y in countdown(upperb.y, lowerb.y):
    for x in lowerb.x .. upperb.x:
      let p = (x, y)
      result.add:
        if p == knots[0]: 'H'
        elif (let i = knots.find p; i != -1): toDigit i
        elif p == (0, 0): 's'
        else: '.'

    result.add '\n'

# implement ----------------------------------

func adapt(tail, head: Point): Vector =
  let (dx, dy) = tail - head

  if dx.abs <= 1 and dy.abs <= 1: (0, 0) # is near
  else: (-dx.sgn, -dy.sgn)

func listKnotVisitsCount(moves: seq[Move], size: int): int =
  var
    visited = initHashSet[Point]()
    knots = newSeqWith(size, (0, 0))

  for m in moves:
    # debugEcho (m.direction, m.distance)

    for v in normal m:
      knots[0] += v

      for i in 1..knots.high:
        let a = adapt(knots[i], knots[i-1])
        knots[i] += a

      visited.incl knots[^1]

    # debugEcho reprMap(knots, (0..5, 0..5))


  visited.len

# go -----------------------------------------

let data = "./input.txt".readFile.moves.toseq
echo data.listKnotVisitsCount(2) # 6464
echo data.listKnotVisitsCount(10) # 2604

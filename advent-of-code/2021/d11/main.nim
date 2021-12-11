import sequtils, strutils, sugar

# prepare ------------------------------------

type
  Geo = seq[seq[int]]
  Point = tuple[x, y: int]

const
  moveRange = (-1)..(+1)
  moves = collect newseq:
    for x in moveRange:
      for y in moveRange:
        if (x, y) != (0, 0):
          (x, y)

func toInt(c: char): int =
  c.ord - '0'.ord

proc parseInput(fname: sink string): Geo =
  for line in fname.lines:
    result.add line.mapIt it.toInt

# utils --------------------------------------

func `[]`(g: Geo, x, y: int): int =
  g[y][x]

func `[]`(g: var Geo, x, y: int): var int =
  g[y][x]

func `[]=`(g: var Geo, x, y, val: int) =
  g[y][x] = val

func width(g: Geo): int = g[0].len
func height(g: Geo): int = g.len
func size(g: Geo): int = g.width * g.height

func `+`(p1, p2: Point): Point =
  (p1.x + p2.x, p1.y + p2.y)

func isInBoard(g: Geo, p: Point): bool =
  (p.x in 0..<g.width) and (p.y in 0..<g.height)

func adjacents(geo: Geo, p: Point): seq[Point] =
  moves.mapIt(it + p).filterIt isInBoard(geo, it)

template search(geo: Geo, task: untyped): untyped =
  for y {.inject.} in 0..<myGeo.height:
    for x {.inject.} in 0..<myGeo.width:
      task

func flushed(v: int): bool =
  v < 0

func `$`(g: Geo): string =
  g.mapIt(it.join ".").join "\n"

# implement ----------------------------------

proc propagate(geo: var Geo, p: Point) =
  if geo[p.x, p.y] > 9:
    geo[p.x, p.y] = int.low

    for np in geo.adjacents(p):
      geo[np.x, np.y].inc
      propagate geo, np

func countFlushesAfter(geo: Geo, steps: int): int =
  var myGeo = geo

  for sn in 1..steps:
    var dangerPoints: seq[Point]

    search mygeo:
      myGeo[x, y].inc
      if myGeo[x, y] > 9:
        dangerPoints.add (x, y)

    for p in dangerPoints:
      propagate mygeo, p

    search mygeo:
      if mygeo[x, y].flushed:
        mygeo[x, y] = 0
        result.inc

func whenAllFlushes(geo: Geo): int =
  var myGeo = geo

  for sn in 1..int.high:
    var
      dangerPoints: seq[Point]
      count = 0

    search mygeo:
      myGeo[x, y].inc
      if myGeo[x, y] > 9:
        dangerPoints.add (x, y)

    for p in dangerPoints:
      propagate mygeo, p

    search mygeo:
      if mygeo[x, y].flushed:
        mygeo[x, y] = 0
        count.inc

      if count == mygeo.size:
        return sn

# go -----------------------------------------

let content = parseInput("./input.txt")
echo countFlushesAfter(content, 100) # 1739
echo whenAllFlushes(content) # 324

import std/[sequtils, strutils, strscans, sets, options]

# def ----------------------------------------

type
  Point = tuple
    x, y: int

  Segment = Slice[Point]

  Area = tuple
    xs, ys: Slice[int]

  Wall = object
    area: Area
    points: seq[Point]

  Axis = enum
    vertical
    horizontal

  DestinationKind = enum
    endlessVoid
    exact

  Destination = object
    case kind: DestinationKind
    of endlessVoid: nil
    of exact:
      position: Point

# conventions --------------------------------------

template ifAny(iter, cond): untyped =
  var acc = false

  for it{.inject.} in iter:
    if cond:
      acc = true
      break

  acc

template ifAll(iter, cond): untyped =
  for it{.inject.} in iter:
    if not cond:
      return false

  true


func noDest: Destination =
  Destination(kind: endlessVoid)

func dest(p: Point): Destination =
  Destination(kind: exact, position: p)

func contains(a: Area, p: Point): bool =
  p.x in a.xs and p.y in a.ys

func expandToIncl(a: Area, p: Point): Area =
  (
    min(a.xs.a, p.x)..max(a.xs.b, p.x),
    min(a.ys.a, p.y)..max(a.ys.b, p.y),
  )

# utils --------------------------------------

func `+`(a, b: Point): Point = (a.x+b.x, a.y+b.y)

func axis(c: Segment): Axis =
  if c.a.x == c.b.x: vertical
  else: horizontal

func sorted[T](s: Slice[T]): Slice[T] =
  if s.a <= s.b: s
  else: s.b..s.a

iterator segments(wall: Wall): Segment =
  for i in 1..wall.points.high:
    yield wall.points[i-1]..wall.points[i]

func intersects(p: Point, c: Segment): bool =
  case c.axis
  of horizontal: (p.y == c.a.y) and (p.x in sorted c.a.x..c.b.x)
  of vertical: (p.x == c.a.x) and (p.y in sorted c.a.y..c.b.y)

func intersects(p: Point, wall: Wall): bool =
  (p in wall.area) and ifAny(wall.segments, p.intersects it)

func intersects(p: Point, walls: seq[Wall]): bool =
  ifAny walls, p.intersects it

# parsers ------------------------------------

func parsePoint(s: string): Point =
  var r: bool
  (r, result.x, result.y) = s.scanTuple("$i,$i")

func parseWall(line: string): Wall =
  for s in line.split " -> ":
    let p = parsePoint s
    result.points.add p
    result.area = expandToIncl(result.area, p)

iterator parseWalls(data: string): Wall =
  for l in data.splitLines:
    yield parseWall l

# debug --------------------------------------

proc debugMap(sand, source: Point, view: Area,
  walls: seq[Wall], filled: HashSet[Point]): string =

  for y in view.ys:
    for x in view.xs:
      let p = (x, y)
      result.add:
        if p == sand: '@'
        elif p == source: '+'
        elif p in filled: 'o'
        elif p.intersects walls: '#'
        else: '.'

    result.add '\n'

# implement ----------------------------------

func isValid(p: Point, walls: seq[Wall], filled: HashSet[Point]): bool =
  not (p in filled or p.intersects walls)

func go(p: Point, walls: seq[Wall], filled: HashSet[Point]): Option[Point] =
  const moves = [
    (0, +1),
    (-1, +1),
    (+1, +1)]

  for m in moves:
    if isValid(p + m, walls, filled):
      return some p + m

func isOffside(p: Point, walls: seq[Wall]): bool =
  ifAll walls, p.y >= it.area.ys.b

func fallSand(source: Point, walls: seq[Wall], filled: HashSet[Point]
  ): Destination =
  var p = source

  while true:
    # debugecho debugMap(p, source, (494..503, 0..9), walls, filled)
    let n = go(p, walls, filled)
    if isSome n:
      # debugecho n, n.get.isOffside(walls)
      p = n.get
      if p.isOffside(walls): return noDest()
    else: return dest p


func part1(source: Point, walls: seq[Wall]): int =
  var restedSands: HashSet[Point]

  while true:
    let d = fallSand(source, walls, restedSands)
    case d.kind
    of endlessVoid: return
    of exact:
      restedSands.incl d.position
      result.inc

# go -----------------------------------------

let data = "./input.txt".readFile.parseWalls.toseq
echo part1((500, 0), data) # 892

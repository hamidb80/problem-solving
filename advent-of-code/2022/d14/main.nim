import std/[sequtils, strutils, strscans, sets, options]

# def ----------------------------------------

type
  Point = tuple
    x, y: int

  Segment = Slice[Point]

  Area = tuple
    xs, ys: Slice[int]

  WallKind = enum
    normal, inf

  Wall = object
    case kind: WallKind
    of inf:
      axis: Axis
      value: int

    of normal:
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
  var acc = true

  for it{.inject.} in iter:
    if not cond:
      acc = false
      break

  acc


func noDest: Destination =
  Destination(kind: endlessVoid)

func dest(p: Point): Destination =
  Destination(kind: exact, position: p)

# utils --------------------------------------

func `+`(a, b: Point): Point =
  (a.x+b.x, a.y+b.y)

func axis(c: Segment): Axis =
  if c.a.x == c.b.x: vertical
  else: horizontal

func sorted[T](s: Slice[T]): Slice[T] =
  if s.a <= s.b: s
  else: s.b..s.a


func contains(a: Area, p: Point): bool =
  p.x in a.xs and p.y in a.ys

func area(p: Point): Area =
  (p.x..p.x, p.y..p.y)

func area(a, b: Area): Area =
  (
    min(a.xs.a, b.xs.a)..max(a.xs.b, b.xs.b),
    min(a.ys.a, b.ys.a)..max(a.ys.b, b.ys.b),
  )

func area(a: Area, p: Point): Area =
  area(a, p.area)

func area(walls: seq[Wall]): Area =
  result = walls[0].area

  for i in 1..walls.high:
    let w = walls[i]
    case w.kind
    of normal:
      result = area(result, w.area)
    of inf:
      case w.axis
      of vertical:
        result.xs = min(result.xs.a, w.value)..max(result.xs.b, w.value)
      of horizontal:
        result.ys = min(result.ys.a, w.value)..max(result.ys.b, w.value)


iterator segments(wall: Wall): Segment =
  for i in 1..wall.points.high:
    yield wall.points[i-1]..wall.points[i]

func intersects(p: Point, c: Segment): bool =
  case c.axis
  of horizontal: (p.y == c.a.y) and (p.x in sorted c.a.x..c.b.x)
  of vertical: (p.x == c.a.x) and (p.y in sorted c.a.y..c.b.y)

func intersects(p: Point, wall: Wall): bool =
  case wall.kind
  of inf:
    case wall.axis
    of horizontal: p.y == wall.value
    of vertical: p.x == wall.value

  of normal:
    (p in wall.area) and ifAny(wall.segments, p.intersects it)

func intersects(p: Point, walls: seq[Wall]): bool =
  ifAny walls, p.intersects it

# parsers ------------------------------------

func parsePoint(s: string): Point =
  var r: bool
  (r, result.x, result.y) = s.scanTuple("$i,$i")

iterator points(line: string): Point =
  for s in line.split " -> ":
    yield parsePoint s

func parseWall(line: string): Wall =
  result = Wall(kind: normal)
  var seen = false

  for p in line.points:
    result.points.add p
    result.area =
      if seen: area(result.area, p)
      else: area p

    seen = true

iterator parseWalls(data: string): Wall =
  for l in data.splitLines:
    yield parseWall l

# debug --------------------------------------

proc reprMap(sand, source: Point, view: Area,
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

func fallSand(source: Point, walls: seq[Wall], worldArea: Option[Area],
    filled: HashSet[Point]
  ): Destination =
  var p = source

  while true:
    let n = go(p, walls, filled)

    if isSome n:
      p = n.get
      if worldArea.isSome and (p notin worldArea.get):
        return noDest()

    else:
      return dest p

# main -----------------------------------------

func stopsAfterHowManySteps(source: Point, walls: seq[Wall]): int =
  var
    restedSands: HashSet[Point]
    view = area(walls.area, source)

  let
    isFinite = ifAll(walls, it.kind == normal)
    worldLimit =
      if isFinite: some view
      else: none Area

  while true:
    let d = fallSand(source, walls, worldLimit, restedSands)
    case d.kind
    of endlessVoid: return
    of exact:
      when defined debug:
        view = area(view, d.position)
        if result mod 100 == 0 or d.position == source:
          debugecho "\n", $result, " ==========="
          debugecho reprMap(d.position, source, view, walls, restedSands)

      restedSands.incl d.position
      result.inc

      if d.position == source: return

# go -----------------------------------------

let
  walls = "./input.txt".readFile.parseWalls.toseq
  world = walls.area
  floor = Wall(kind: inf, axis: horizontal, value: world.ys.b + 2)

echo stopsAfterHowManySteps((500, 0), walls) # 892
echo stopsAfterHowManySteps((500, 0), walls & floor) # 27155

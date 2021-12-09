import sequtils, strutils, math, algorithm, strformat

# prepare ------------------------------------

type
  Geo = ref object
    data: seq[int]
    width, height: int

  Point = tuple[x, y: int]
  Area = seq[Point]

# utils --------------------------------------

func charToInt(c: char): int =
  c.ord - '0'.ord

proc parseInput(s: string): Geo =
  result = new Geo

  for line in s.splitLines:
    result.height.inc
    result.data.add (@line).map(charToInt)

  result.width = result.data.len div result.height

func calcPosition(g: Geo, x, y: int): int =
  y * g.width + x

func `[]`(g: Geo, x, y: int): int =
  g.data[calcPosition(g, x, y)]

func `[]`(g: Geo, y: int): seq[int] =
  let first = y * g.width
  g.data[first ..< (first + g.width)]

proc `[]=`(g: Geo, x, y: int, val: int) =
  g.data[calcPosition(g, x, y)] = val

func findMoves(index, max: int): seq[int] =
  result = @[-1, +1]
  if index == 0: result.del 0
  elif index == max: result.del 1

func isVisitedBefore(p: Point, areas: openArray[Area]): bool =
  areas.anyIt p in it

# helpers ------------------------------------

func showInMap(areas: seq[Area], geo: Geo): string =
  ## debuggin purposes
  var myGeo = new Geo
  myGeo[] = geo[]

  for points in areas:
    for p in points:
      myGeo[p.x, p.y] = -1

  for y in 0 ..< geo.height:
    result &= "\n" & myGeo[y].mapIt(
      if it == -1: "."
      else: $it
    ).join

func `$`(p: Point): string =
  ## debuggin purposes
  fmt"({p.x},{p.y})"

# implement ----------------------------------

func riskLevel(geo: Geo): int =
  for y in 0 ..< geo.height:
    for x in 0 ..< geo.width:
      let
        center = geo[x, y]

        moves: seq[Point] =
          findMoves(x, geo.width - 1).zip([0, 0]) &
          [0, 0].zip(findMoves(y, geo.height - 1))

      if moves.allIt(center < geo[x + it.x, y + it.y]):
        result.inc center + 1

proc findAreaFromImpl(p: Point, geo: Geo, acc: var Area) =
  template go(dx, dy: int): untyped =
    let newp: Point = (p.x + dx, p.y + dy)

    if newp notin acc and geo[newp.x, newp.y] != 9:
      findAreaFromImpl(newp, geo, acc)

  acc.add p

  if p.x != 0: go(-1, 0)
  if p.x != geo.width - 1: go(+1, 0)
  if p.y != 0: go(0, -1)
  if p.y != geo.height - 1: go(0, +1)

func findAreaFrom(p: Point, geo: Geo): Area =
  findAreaFromImpl(p, geo, result)

func maxBasinsSizeProduct(geo: Geo): int =
  var foundAreas: seq[Area]

  for y in 0 ..< geo.height:
    for x in 0 ..< geo.width:
      let p = (x, y)

      if geo[x, y] != 9 and not isVisitedBefore(p, foundAreas):
        foundAreas.add findAreaFrom(p, geo)

  foundAreas.mapIt(it.len).sorted(Descending)[0 ..< 3].prod

# go -----------------------------------------

let input = readfile("./input.txt").parseInput
echo riskLevel(input) # 631
echo maxBasinsSizeProduct(input) # 821560

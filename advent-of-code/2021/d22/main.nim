import std/[sequtils, strscans, tables, unittest, intsets]

{.experimental: "strictFuncs".}

# def ----------------------------------------

type
  Range = HSlice[int, int]

  Dimensions = enum
    X, Y, Z

  SpaceRange = object
    x, y, z: Range

  CubeState = enum
    On, Off

  Command = tuple
    state: CubeState
    space: SpaceRange

  World = Table[int, Table[int, IntSet]] # { x => {y => [zs]} }


const 
  dimensions = [X, Y, Z]
  infRange = int.low .. int.high
  infSpace = SpaceRange(x: infRange, y: infRange, z: infRange)

func `[]`(sr: SpaceRange, d: Dimensions): Range =
  case d:
  of X: sr.x
  of Y: sr.y
  of Z: sr.z

func `[]=`(sr: var SpaceRange, d: Dimensions, r: Range) =
  case d:
  of X: sr.x = r
  of Y: sr.y = r
  of Z: sr.z = r

func turnOn(w: var World, x, y: int, zr: Range) =
  let zs = zr.toseq.toIntSet

  if x notin w:
    w[x] = {y: zs}.toTable

  elif y notin w[x]:
    w[x][y] = zs

  else:
    w[x][y] = union(w[x][y], zs)

func turnOff(w: var World, x, y: int, zr: Range) =
  if (x in w) and (y in w[x]):
    w[x][y] = difference(w[x][y], zr.toseq.toIntSet)

# utils --------------------------------------

func parseCommand(line: string): Command =
  var t: string
  discard scanf(line, "$w x=$i..$i,y=$i..$i,z=$i..$i",
    t,
    result.space.x.a, result.space.x.b,
    result.space.y.a, result.space.y.b,
    result.space.z.a, result.space.z.b,
  )
  result.state =
    if t == "on": On
    else: Off

func applyLimit(rng, limit: Range): Range =
  max(rng.a, limit.a) .. min(rng.b, limit.b)

func applyLimit(area, limit: SpaceRange): SpaceRange =
  for d in dimensions:
    result[d] = applyLimit(area[d], limit[d])

# implement ----------------------------------

func howManyCubesAreOn(commands: seq[Command], targetArea: SpaceRange): int =
  var world: World

  for c in commands:
    let area = applyLimit(c.space, targetArea)

    for x in area.x:
      for y in area.y:
        case c.state:
        of On: world.turnOn(x, y, area.z)
        of Off: world.turnOff(x, y, area.z)

  for x, yt in world:
    for zs in yt.values:
      result.inc zs.len

# tests --------------------------------------

test "apply limit range":
  check:
    applyLimit(-4 .. 10, -1 .. 8) == -1 .. 8
    applyLimit(-4 .. 10, -1 .. 12) == -1 .. 10
    applyLimit(-4 .. 10, -6 .. 4) == -4 .. 4

test "parse command":
  let c = parseCommand("on x=1..2,y=3..4,z=5..6")
  check:
    c.state == On
    c.space.x == 1 .. 2
    c.space.y == 3 .. 4
    c.space.z == 5 .. 6

# go -----------------------------------------

let data = lines("./test.txt").toseq.map(parseCommand)
echo howManyCubesAreOn(data, SpaceRange(x: -50..50, y: -50..50, z: -50..50))
echo howManyCubesAreOn(data, infSpace)

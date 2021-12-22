import std/[sequtils, strscans, unittest, math]

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

  World = seq[SpaceRange] # separated cubic space ranges


const
  dimensions = [X, Y, Z]
  infRange = int.low .. int.high


func newSpace(rx, ry, rz: Range): SpaceRange =
  SpaceRange(x: rx, y: ry, z: rz)

func newSpace(rng: Range): SpaceRange =
  SpaceRange(x: rng, y: rng, z: rng)

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

func skipEmpties(s: seq[Range]): seq[Range] =
  s.filterIt it.len != 0

func calcSpace(sr: SpaceRange): int =
  dimensions.mapIt(sr[it].len).prod

func skipEmpties(s: seq[SpaceRange]): seq[SpaceRange] =
  s.filterIt it.calcSpace != 0

func contains(main, sub: Range): bool =
  [sub.a, sub.b].allit it in main

func intersectsWith(r1, r2: Range): bool =
  (r1.a >= r2.a and r1.a <= r2.b) or
  (r1.b >= r2.a and r1.b <= r2.b) or
  (r2 in r1) or (r1 in r2)

func intersectsWith(s1, s2: SpaceRange): bool =
  for d in dimensions:
    if not intersectsWith(s1[d], s2[d]):
      return false
  true

func intersection(rng, limit: Range): Range =
  max(rng.a, limit.a) .. min(rng.b, limit.b)

func intersection(space, limit: SpaceRange): SpaceRange =
  for d in dimensions:
    result[d] = intersection(space[d], limit[d])

func difference(s1, s2: Range): seq[Range] =
  assert s1.intersectsWith(s2)
  skipEmpties:
    if s2.a <= s1.a:
      if s2.b >= s1.b:
        @[]
      else:
        @[s2.b+1 .. s1.b]

    else:
      if s2.b >= s1.b:
        @[s1.a .. s2.a-1]
      else:
        @[s1.a .. s2.a-1, s2.b+1 .. s1.b]

func difference(s1, s2: SpaceRange): seq[SpaceRange] =
  assert s1.intersectsWith(s2)

  let
    ins = intersection(s1, s2)
    zr1 = s1.z.a .. ins.z.a-1
    zr2 = ins.z.b+1 .. s1.z.b

  skipEmpties @[
    newSpace(s1.x, s1.y, zr1),
    newSpace(s1.x, s1.y, zr2),
    newspace(s1.x.a .. ins.x.a-1, s1.y, ins.z),
    newspace(ins.x.b+1 .. s1.x.b, s1.y, ins.z),
    newspace(ins.x, s1.y.a .. ins.y.a-1, ins.z),
    newspace(ins.x, ins.y.b+1 .. s1.y.b, ins.z),
  ]

func `xor`(s1, s2:SpaceRange): tuple[p1, p2: seq[SpaceRange]] =
  (s1.difference s2, s2.difference s1)

# implement ----------------------------------

func fitShape(box, limit: SpaceRange): seq[SpaceRange] =
  if box.intersectsWith limit:
    difference box, limit
  else:
    @[box]

func toIdealShapes(world: World, box: SpaceRange): seq[SpaceRange] =
  var acc = @[box]
  for ws in world:
    var i = 0
    while i <= acc.high:
      let slices = fitShape(acc[i], ws)
      
      if slices.len == 1 and acc[i] == slices[0]:
        i.inc

      else:
        acc.del i
        acc.add slices

  acc

func turnOn(world: var World, sr: SpaceRange) =
  world.add toIdealShapes(world, sr)

func turnOff(world: var World, sr: SpaceRange) =
  var 
    iw = 0
    parts = @[sr]
  
  while iw <= world.high:
    let ws = world[iw]
    var pi = 0

    while pi <= parts.high and iw <= world.high:
      let p = parts[pi]

      if ws.intersectsWith p:
        let (wSlices, pSlices) = ws xor p

        world.del iw
        world.add wSlices

        parts.del pi
        parts.add pSlices

      pi.inc
    iw.inc

func howManyCubesAreOn(commands: seq[Command], targetArea: SpaceRange): int =
  var world: World

  for c in commands:
    let area = intersection(c.space, targetArea)

    case c.state:
    of On: world.turnOn(area)
    of Off: world.turnOff(area)

  sum world.map calcSpace

# tests --------------------------------------

test "apply limit range":
  check:
    intersection(-4 .. 10, -1 .. 8) == -1 .. 8
    intersection(-4 .. 10, -1 .. 12) == -1 .. 10
    intersection(-4 .. 10, -6 .. 4) == -4 .. 4

let
  b1 = newSpace(-5 .. 5, -4 .. 4, -3 .. 3)
  b2 = newSpace(-2 .. 2, 1 .. 3, 0 .. 7)

suite "diff":
  test "range":
    check:
      difference(1..5, 2..3) == @[1..1, 4..5]
      difference(1..5, 4..8) == @[1..3]
      difference(1..5, -3 .. 3) == @[4..5]
      difference(1..5, 1..5) == newseq[Range]()
      difference(1..5, -3 .. 10) == newseq[Range]()

  test "space":
    let diff = difference(b1, b2)
    check:
      newSpace(b1.x, b1.y, -3 .. -1) in diff
      newSpace(-5 .. -3, b1.y, 0 .. 3) in diff
      newSpace(3 .. 5, b1.y, 0 .. 3) in diff
      newSpace(b2.x, -4 .. 0, 0 .. 3) in diff
      newSpace(b2.x, 4..4, 0 .. 3) in diff
      diff.len == 5

test "intersect with":
  check:
    intersectsWith 1 .. 4, 2..5
    intersectsWith 1 .. 4, 0..5
    not intersectsWith(1 .. 4, 6..9)
    intersectsWith 1 .. 4, -1 .. 3

suite "intersection":
  test "space":
    check intersection(b1, b2) == newSpace(-2 .. 2, 1 .. 3, 0 .. 3)

  test "range":
    check true

# go -----------------------------------------

let data = lines("./test.txt").toseq.map(parseCommand)
echo howManyCubesAreOn(data, newSpace(-50..50)) # 602574
echo howManyCubesAreOn(data, newSpace(infRange)) # 2758514936282235

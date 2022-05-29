import std/[options, sequtils, unittest]

type
  Moves = enum
    mTopLeft
    mTop
    mTopRight
    mLeft
    mRight
    mBottomLeft
    mBottom
    mBottomRight
    mOffSide

  Maze = seq[seq[bool]]

  Path = seq[Moves]

  Coordinate = tuple[x, y: int]
  Vector = Coordinate

const
  reversedMove: array[Moves, Moves] = [
    mBottomRight, mBottom, mBottomLeft, mRight,
    mLeft, mTopRight, mTop, mTopLeft, mOffSide]

  toVector: array[Moves, Vector] = [
      (-1, -1), (0, -1), (+1, -1), (-1, 0), (+1, 0),
      (-1, +1), (0, +1), (+1, +1), (0, 0)]



template shoot(a: seq): untyped =
  del a, a.high

# func last[T](a: seq[T]): T =
#   a[a.high]

func last[T](a: var seq[T]): var T =
  a[a.high]

func `[]`[T](m: seq[seq[T]], c: Coordinate): T =
  m[c.y][c.x]

func `[]=`[T](m: var seq[seq[T]], c: Coordinate, val: T) =
  m[c.y][c.x] = val

func `+`(c1, c2: Coordinate): Coordinate =
  (c1.x + c2.x, c1.y + c2.y)

func `-`(m: Moves): Moves =
  reversedMove[m]

func apply(c: var Coordinate, move: Moves) =
  c = c + toVector[move]

func initMaze(rows, cols: int): Maze =
  newSeqWith rows:
    newSeqWith cols, false

func initMaze(map: openArray[string]): Maze =
  for row in map:
    result.add row.mapIt it == '1'

func findPath*(mz: Maze, head, tail: Coordinate): Option[Path] =
  const offset = (1, 1)

  var
    borderedMaze = initMaze(mz.len + 2, mz[0].len + 2)
    mark = borderedMaze

  let
    ybound = [0, borderedMaze.high]
    xbound = [0, borderedMaze[0].high]
    endPos = tail + offset

  # --- init boardered maze
  for y in 0 .. mz.high + 2:
    for x in 0 .. mz[0].high + 2:
      borderedMaze[y][x] =
        if y in ybound or x in xbound: true
        else: mz[y-1][x-1]


  # --- go
  var
    pos = head + offset
    track: Path

  track.add mTopLeft
  pos.apply mTopLeft

  while track.len != 0:
    let move = track.last

    if move == mOffSide:
      pos.apply -track.pop

      mark[pos] = true
      debugEcho pos

      inc track.last
      pos.apply track.last

    elif pos == endpos:
      debugEcho 2
      return some track

    elif borderedMaze[pos]: # hit the wall
      debugEcho 3
      pos.apply -track.pop

      let newMove = Moves move.int + 1

      track.add newMove
      pos.apply track.last

      debugEcho track, pos

    else:
      debugEcho (4, track.len, pos)
      track.add mTopLeft
      pos.apply track.last


suite "test":
  let m = initMaze [
    "10010111",
    "01110111",
    "10010111",
    "11101111",
    "00010111",
  ]

  test "simple":
    echo findPath(m, (0, 0), (0, 4))

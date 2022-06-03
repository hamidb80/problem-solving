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

func apply(c: Coordinate, move: Moves): Coordinate =
  c + toVector[move]

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


  mark[pos] = true
  track.add mTopLeft
  pos = pos.apply mTopLeft
  mark[pos] = true

  while track.len != 0:
    let move = track.last

    if move == mOffSide:
      debugEcho 1
      track.shoot

      inc track.last
      pos = pos.apply track.last
      
    elif pos == endpos:
      return some track

    elif borderedMaze[pos]: # hit the wall
      # debugEcho 3
      pos = pos.apply -track.pop

      let 
        newMove = Moves move.int + 1
        newPos = pos.apply newMove

      pos = newPos
      track.add newMove
      mark[newPos] = true
      
    else:
      debugEcho (4, track.len, pos)
      
      var
        newMove = mTopLeft
        newPos = pos.apply mTopLeft

      if mark[newPos]:
        while mark[newPos]:
          newPos = pos.apply -track.pop
          inc newMove
          newPos = pos.apply newMove
        
      else:
        track.add newMove
        pos = newPos


suite "test":
  let m = initMaze [
    "10010111",
    "01110111",
    "10010111",
    "11101111",
    "00010111",
  ]

  test "simple":
    echo findPath(m, (1, 0), (0, 4))

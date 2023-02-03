import std/[sequtils, strutils, tables, enumerate, sets]

# def ----------------------------------------

type
  Point = tuple
    x, y: int

  Shape = object
    width, height: int
    points: seq[Point]

  Direction = enum
    left
    right

  Tetris = object
    width, height: int
    filled: HashSet[Point]

# utils --------------------------------------

func parseShape(s: string): Shape =
  for y, line in enumerate(s.split):
    for x, ch in line:
      if ch == '#':
        result.width = max(result.width, x+1)
        result.height = max(result.height, y+1)
        result.points.add (x, -y)

func parseShapes(s: string): seq[Shape] =
  for group in s.split "\n\n":
    result.add parseShape group

func parseMove(ch: char): Direction =
  case ch
  of '<': left
  of '>': right
  else: raise newException(ValueError, "invalid direction char: " & ch)

func `+`(a, b: Point): Point =
  (a.x + b.x, a.y + b.y)

func `+`(s: seq[Point], p: Point): seq[Point] =
  s.mapit it + p

func fill(tet: var Tetris, p: Point) =
  tet.height = max(tet.height, p.y+1)
  tet.filled.incl p

func fill(tet: var Tetris, ps: seq[Point]) =
  for p in ps:
    tet.fill p

func initTetris(width: int): Tetris =
  result.width = width
  result.height = 0

  for i in 0..<width:
    result.filled.incl (i, -1) # floor

# debug -------------------------------------

# import std/algorithm

# func debugRepr(tet: Tetris, newPoints: seq[Point]): string =
#   var acc = reversed newSeqWith(tet.height+10, "|" & repeat('.', tet.width) & "|")

#   for p in tet.filled:
#     acc[p.y+1][p.x+1] = '#'

#   for p in newPoints:
#     acc[p.y+1][p.x+1] = '@'

#   acc.reversed.join "\n"

# data --------------------------------------

const shapes = parseShapes dedent"""
  ####

  .#.
  ###
  .#.

  ..#
  ..#
  ###

  #
  #
  #
  #

  ##
  ##
"""

# implement ----------------------------------

func heightAfter(forces: seq[Direction], width: int, turns: int64): int =
  var
    tet = initTetris width
    i = 0

  for t in 0..<turns:
    debugEcho t
    
    let sh = shapes[t mod shapes.len]
    var offset: Point = (2, tet.height + sh.height + 3 - 1)

    while true:
      case forces[i mod forces.len]
      of left:
        if offset.x - 1 >= 0:
          dec offset.x
          if (sh.points + offset).anyIt it in tet.filled:
            inc offset.x


      of right:
        if sh.width + offset.x + 1 <= tet.width:
          inc offset.x
          if (sh.points + offset).anyIt it in tet.filled:
            dec offset.x

      inc i

      if (sh.points + (offset + (0, -1))).anyIt it in tet.filled:
        tet.fill sh.points + offset
        # debugecho "\n", debugRepr(tet, @[])
        # debugEcho "\n... REST ..."
        break

      dec offset.y
      
  tet.height

# go -----------------------------------------

let moves = "./test.txt".readFile.map(parseMove)
echo heightAfter(moves, 7, 2022) # 3227
echo heightAfter(moves, 7, 1_000_000_000_000) # seems like it needs some optimization
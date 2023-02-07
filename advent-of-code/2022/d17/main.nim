import std/[sequtils, strutils, enumerate]

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
    width: int
    rows: seq[seq[bool]]

# utils --------------------------------------

func any(s: seq[bool]): bool =
  for i in s:
    if i:
      return true


func `+`(a, b: Point): Point =
  (a.x + b.x, a.y + b.y)

func `+`(s: seq[Point], p: Point): seq[Point] =
  s.mapit it + p

func left(p: Point): Point =
  p + (-1, 0)

func right(p: Point): Point =
  p + (+1, 0)

func down(p: Point): Point =
  p + (0, -1)


func height(tet: Tetris): int =
  var empties = 0

  for i in countdown(tet.rows.high, 1):
    if not any tet.rows[i]:
      inc empties

  tet.rows.len - empties - 1

func addRowIfNecessary(tet: var Tetris, y: int) =
  if tet.rows.high < y:
    let diff = y - tet.rows.high
    for i in 1..diff:
      tet.rows.add repeat(false, tet.width)

func fill(tet: var Tetris, p: Point) =
  tet.rows[p.y][p.x] = true

func fill(tet: var Tetris, ps: seq[Point]) =
  for p in ps:
    tet.fill p

func contains(tet: Tetris, p: Point): bool =
  if p.y < tet.rows.len:
    tet.rows[p.y][p.x]
  else:
    false

func intersects(ps: seq[Point], tet: Tetris): bool =
  for p in ps:
    if p in tet:
      return true

func initTetris(width: int): Tetris =
  result.width = width
  result.rows = @[repeat(true, width)]

# debug -------------------------------------

func debugRepr(tet: Tetris, newPoints: seq[Point]): string =
  for y in countdown(tet.rows.high, 0):
    for x in 0..<tet.width:
      result.add:
        if tet.rows[y][x]: '#'
        elif (x, y) in newPoints: '@'
        else: '.'

    result.add '\n'

# impl -------------------------------------

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

# main ----------------------------------

func heightAfter(forces: seq[Direction], width: int, turns: int64): int =
  var
    tet = initTetris width
    i = 0

  for t in 0..<turns:
    # debugEcho "\n", t

    let sh = shapes[t mod shapes.len]
    var offset: Point = (2, tet.height + sh.height + 3)
    addRowIfNecessary tet, offset.y

    while true:
      case forces[i mod forces.len]
      of left:
        if (0 <= offset.x - 1) and
          not intersects(sh.points + offset.left, tet):
          dec offset.x

      of right:
        if (sh.width + offset.x + 1 <= tet.width) and
          not intersects(sh.points + offset.right, tet):
          inc offset.x

      inc i

      # debugecho "\n", debugRepr(tet, (sh.points + offset))

      if (sh.points + offset.down).intersects tet:
        tet.fill sh.points + offset
        # debugEcho "\n... REST ..."
        break

      dec offset.y

  tet.height

# go -----------------------------------------

let moves = "./test.txt".readFile.map(parseMove)
echo heightAfter(moves, 7, 2022) # 3227
# echo heightAfter(moves, 7, 1_000_000_000_000) # seems like it needs some optimization

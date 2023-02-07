import std/[sequtils, strutils, enumerate, tables, sugar]

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

func toVec(d: Direction): Point =
  case d
  of left: (-1, 0)
  of right: (+1, 0)


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

func intersects(tet: Tetris, ps: seq[Point]): bool =
  for p in ps:
    if p in tet:
      return true

func initTetris(width: int): Tetris =
  result.width = width
  result.rows = @[repeat(true, width)]

# debug -------------------------------------

func debugRepr(tet: Tetris, newPoints: seq[Point]): string {.used.} =
  for y in countdown(tet.rows.high, 0):
    for x in 0..<tet.width:
      result.add:
        if tet.rows[y][x]: '#'
        elif (x, y) in newPoints: '@'
        else: ','

    result.add '\n'

func `$`(s: seq[bool]): string {.used.} =
  for i in s:
    result.add:
      if i: '1'
      else: '0'

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

proc heightAfter(forces: seq[Direction], width, turns: int, cycleDetector: bool): int =
  var
    tet = initTetris width
    fi = 0
    cache: Table[(seq[bool], int, int), int]

  for t in 1..turns:
    let
      si = (t-1) mod shapes.len
      sh = shapes[si]
      index = (tet.rows[tet.height], si, fi mod forces.len)

    var offset: Point = (2, tet.height + sh.height + 3)
    tet.addRowIfNecessary offset.y

    if cycleDetector:
      if index in cache:
        let
          prev = cache[index]
          hnew = heightAfter(forces, width, t, false)
          hold = heightAfter(forces, width, prev, false)
          parts = (turns - prev) div (t - prev)
          rem = (turns - prev) mod (t - prev)
          hrem = heightAfter(forces, width, prev + rem, false) - hold
          dh = hnew - hold

        # dump dh
        # dump t..prev
        # dump hrem
        # dump rem

        return hrem + (dh * parts) + hold
      else:
        cache[index] = t

    while true:
      case forces[fi mod forces.len]
      of left:
        if (0 <= offset.x - 1) and
          not tet.intersects(sh.points + offset.left):
          dec offset.x

      of right:
        if (sh.width + offset.x + 1 <= tet.width) and
          not tet.intersects(sh.points + offset.right):
          inc offset.x

      inc fi

      if tet.intersects(sh.points + offset.down):
        tet.fill sh.points + offset
        break

      dec offset.y

      # debugecho debugRepr(tet, @[])
  
  tet.height

# go -----------------------------------------

let moves = "./test.txt".readFile.map(parseMove)
echo heightAfter(moves, 7, 2022, true) # 3227
echo heightAfter(moves, 7, 1_000_000_000_000.int, true) # ....?

import sequtils, strutils, tables
import sequtils as su
import strutils as sr

# prepare --------------------------------

type
  Point = tuple[x, y: int]
  Vec = tuple[head, tail: Point]

  Direction = enum
    Ddec = -1, Dnon = 0, Dinc = 1

func parsePoint(s: string): Point =
  let a = s.split(',')
  (a[0].parseInt, a[1].parseInt)

func parseLine(line: string): Vec =
  let points = line.split(" -> ").map(parsePoint)
  (points[0], points[1])

# utils --------------------------------

func maxDelta(v: Vec): int =
  max abs(v.head.x - v.tail.x), abs(v.head.y - v.tail.y)

func apply(dir: Direction, coeff: int): int =
  int(dir) * coeff

func direction(n1, n2: int): Direction =
  if n1 == n2: Dnon
  elif n1 > n2: Ddec
  else: Dinc

func direction(v: Vec): tuple[x, y: Direction] =
  (direction(v.head.x, v.tail.x), direction(v.head.y, v.tail.y))

iterator expandVec(v: Vec): Point =
  let
    value = v.maxDelta
    dir = v.direction
    head = v.head

  for c in 0..value:
    yield (head.x + apply(dir.x, c), head.y + apply(dir.y, c))

func `$`(pc: CountTable[Point]): string =
  ## for debugging purposes
  let
    points = pc.keys.toseq
    size: Point = (points.mapIt(it.x).max(), points.mapIt(it.y).max())

  var rows = su.repeat(sr.repeat('.', size.x + 1), size.y + 1)
  for p, c in pc:
    rows[p.y][p.x] = ($c)[0]

  rows.join("\n")

# implementation -----------------------

proc dangerPoints(lines: seq[Vec], diagonal: static bool): int =
  var pcounter = initCountTable[Point]()

  let valid =
    when diagonal:
      lines
    else:
      lines.filterIt(it.head.x == it.tail.x or it.head.y == it.tail.y)

  for v in valid:
    for p in v.expandVec:
      pcounter.inc p

  # debugecho pcounter
  pcounter.values.countit(it > 1)

# go -----------------------

let content = "./input.txt".lines.toseq.map parseLine
echo dangerPoints(content, false)
echo dangerPoints(content, true)

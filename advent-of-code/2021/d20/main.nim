import std/[sequtils, strutils, math, unittest, tables]

{.experimental: "strictFuncs".}

# def ----------------------------------------

type
  Point = tuple[x, y: int]
  Range = HSlice[int, int]

  Image = Table[int, seq[int]] # x => [y1, y2 ,...]
  Size = tuple
    xrange, yrange: HSlice[int, int]

  EnhanceAlgo = seq[bool]

  Data = tuple
    enhancementAlgorithm: EnhanceAlgo
    image: Image


const
  chunkSideRange = -1 .. +1
  chunkSize = chunkSideRange.len ^ 2

func add(img: var Image, p: Point) =
  if p.x notin img:
    img[p.x] = @[]

  img[p.x].add p.y

func moveBorders(main, expand: Range): Range =
  (main.a + expand.a) .. (main.b + expand.b)

func `[]`(img: Image, p: Point): bool =
  (p.x in img) and img[p.x].anyit(it == p.y)

func `+`(p1, p2: Point): Point =
  (p1.x + p2.x, p1.y + p2.y)

func contains(sz: Size, p: Point): bool =
  (p.x in sz.xrange) and (p.y in sz.yrange)

func getSize(img: Image): Size =
  for x, ys in img.pairs:
    result = (
      min(result.xrange.a, x) .. max(result.xrange.b, x),
      min(result.yrange.a, min(ys)) .. max(result.yrange.b, max(ys))
    )

# utils --------------------------------------


const imageOffset = 2
proc parseInput(fname: string): Data =
  var lc = 0

  for l in lines fname:
    if lc == 0:
      result.enhancementAlgorithm = l.mapIt(it == '#')

    elif lc != 1:
      for i, b in l.pairs:
        if b == '#':
          result.image.add (i, lc - imageOffset)

    lc.inc

template `~`(val, typ): untyped =
  cast[typ](val)

func `$`(img: Image): string =
  ## for debugging purposes
  let size = img.getSize

  for y in size.yrange:
    for x in size.xrange:
      result.add:
        if img[(x, y)]: '#'
        else: '.'

    result.add "\n"

func isEven(n: int): bool =
  n mod 2 == 0

# implement ----------------------------------

func toInt(s: seq[bool]): int =
  parseBinInt s.mapIt(if it: '1' else: '0') ~ string

func chunkCode(img: Image, size: Size, target: Point, isOutsideLit: bool): int =
  var acc = newSeqOfCap[bool](chunkSize)

  for dy in chunkSideRange:
    for dx in chunkSideRange:
      let p = target + (dx, dy)
      acc.add:
        if p in size: img[p]
        else: isOutsideLit

  acc.toInt

func enhance(img: Image, algo: EnhanceAlgo, isOutsideLit: bool): Image =
  let size = img.getSize

  for x in size.xrange.moveBorders(chunkSideRange):
    for y in size.yrange.moveBorders(chunkSideRange):
      let p = (x, y)

      if algo[chunkCode(img, size, p, isOutsideLit)]:
        result.add p

func howManyAreLit(content: Data, times: Positive): int =
  var acc = content.image
  let isOutsideBlinking = content.enhancementAlgorithm[0]

  for i in 1..times:
    acc = enhance(acc, content.enhancementAlgorithm, isOutsideBlinking and i.isEven)

  sum acc.keys.toseq.mapIt acc[it].len

# tests --------------------------------------

test "move borders":
  check moveBorders(2..3, -1 .. +1) == 1..4

# go -----------------------------------------

let data = parseInput("./input.txt")
echo howManyAreLit(data, 2) # 5291
echo howManyAreLit(data, 50) # 16665

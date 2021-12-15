import sequtils, strutils

# prepare ------------------------------------

type
  Geo = ref object
    data: seq[seq[int]]
    size: int

# utils --------------------------------------

func parseInt(c: char): int = c.ord - '0'.ord

func `[]`(geo: Geo, x, y: int): int = geo.data[y][x]
func `[]=`(geo: Geo, x, y, val: int) = geo.data[y][x] = val

func initGeo(size: int): Geo =
  result = new Geo
  result.size = size
  result.data = newSeqWith(size, newSeqWith(size, 0))

proc parseInput(fname: string): Geo =
  result = new Geo
  result.data =
    lines(fname).toseq.mapIt:
      it.mapit it.parseInt

  result.size = result.data.len

func `$`(geo: Geo): string =
  # for debugging purposes
  geo.data.join "\n"

# implement ----------------------------------

func lowestRiskImpl(geo, acc: Geo, i: int) =
  let mxi = geo.size - 1

  template adjust(x, y): untyped =
    acc[x, y] = min(acc[x+1, y], acc[x, y+1]) + geo[x, y]

  acc[mxi, i] = acc[mxi, i + 1] + geo[mxi, i]
  acc[i, mxi] = acc[i + 1, mxi] + geo[i, mxi]

  for z in countdown(mxi - 1, i):
    adjust z, i
    adjust i, z

func lowestRisk(geo: Geo): int =
  let
    lrps = initGeo(geo.size) # lowest risk path summation in every position
    mxi = geo.size - 1       # max index

  lrps[mxi, mxi] = geo[mxi, mxi]

  for i in countdown(mxi - 1, 0):
    lowestRiskImpl(geo, lrps, i)

  lrps[0, 0] - geo[0, 0]

# go -----------------------------------------

let content = parseInput("./input.txt")
echo lowestRisk(content) # 435

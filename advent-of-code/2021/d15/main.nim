import sequtils

# prepare ------------------------------------

type 
  Geo = ref object
    data: seq[seq[int]]
    width, height: int
  
  Point = tuple[x,y: int]

# utils --------------------------------------

func parseInt(c: char): int =
  c.ord - '0'.ord

proc parseInput(fname: string): Geo =
  result = new Geo
  result.data =
    lines(fname).toseq.mapIt:
      it.mapit it.parseInt

  result.height = result.data.len
  result.width = result.data[0].len

func destination(geo: Geo): Point {.inline.}=
  (geo.width - 1, geo.height - 1)

func `[]`(geo: Geo, p: Point): int {.inline.}=
  geo.data[p.y][p.x]

# implement ----------------------------------

func lowestRiskImpl(geo: Geo, position: Point, currentSum: int, minRisk: var int)=
  let newsum = currentSum + geo[position]

  if position == geo.destination:
    minRisk = min(minRisk, newsum)

  else:
    if position.x != geo.width - 1:
      lowestRiskImpl(geo, (position.x + 1, position.y), newsum, minRisk)

    if position.y != geo.height - 1:
      lowestRiskImpl(geo, (position.x, position.y + 1), newsum, minRisk)

func lowestRisk(geo: Geo): int =
  result = int.high
  lowestRiskImpl(geo, (0,0), -geo[(0,0)], result)

# go -----------------------------------------

let content = parseInput("./test.txt")
echo lowestRisk(content)

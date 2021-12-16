import sequtils, strutils, strformat

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

func applyLimit(val: int): int =
  if val > 9: val mod 9
  else: val

func expand(geo: Geo, times: int): Geo =
  let sz = geo.size
  result = initGeo(sz * times)

  for xt in 0 ..< result.size:
    for yt in 0 ..< result.size:
      let addition = (xt div sz) + (yt div sz)
      result[xt, yt] = applyLimit(geo[xt mod sz, yt mod sz] + addition)

proc parseInput(fname: string): Geo =
  result = new Geo
  result.data =
    lines(fname).toseq.mapIt:
      it.mapit it.parseInt

  result.size = result.data.len

func `$`(geo: Geo): string =
  # for debugging purposes
  geo.data.mapIt(it.mapIt(fmt" {it:2} ").join"").join "\n"

# implement ----------------------------------

func lowestRiskImpl(geo, acc: Geo, i: int) =
  let mxi = geo.size - 1

  template calcPathSum(x, y): untyped =
    acc[x, y] = min(acc[x+1, y], acc[x, y+1]) + geo[x, y]

  acc[mxi, i] = acc[mxi, i + 1] + geo[mxi, i]
  acc[i, mxi] = acc[i + 1, mxi] + geo[i, mxi]

  for z in countdown(mxi - 1, i):
    calcPathSum z, i
    calcPathSum i, z

proc lowestRisk(geo: Geo): int =
  let
    acc = initGeo(geo.size) # lowest risk path summation in every position
    mxi = geo.size - 1       # max index

  acc[mxi, mxi] = geo[mxi, mxi] # destination

  for i in countdown(mxi - 1, 0):
    lowestRiskImpl(geo, acc, i)

  writefile "examine.txt", $acc
  acc[0, 0] - geo[0, 0]

# go -----------------------------------------

let geo = parseInput("./gold.txt")
echo lowestRisk(geo) # 435
writeFile "table.txt", $geo
# echo lowestRisk(geo.expand 5) # 2846 ? but the right answer is 2842 | i don't know why

## UPDATE: bro you have to use a well-known path finding algorithm, you incorrecly assumed that you
## can only go bottom and right but you can go up and left too, and this part is scary if you wanna 
## do it alone

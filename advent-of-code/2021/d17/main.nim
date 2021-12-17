import sequtils, strutils, strscans, math

# prepare ------------------------------------

type
  Area = tuple
    x, y: HSlice[int, int]

  Velocity = tuple[x, y: int]
  Point = Velocity

# utils --------------------------------------

func toValidRange(rng: HSlice[int, int]): HSlice[int, int]=
  if rng.a > rng.b:
    rng.b .. rng.a
  else:
    rng

func parseInput(s: sink string): Area =
  discard scanf(s,
    "target area: x=$i..$i, y=$i..$i",
    result.x.a, result.x.b, result.y.a, result.y.b)

  (toValidRange(result.x), toValidRange(result.y))

# implement ----------------------------------

func applyDrag(v: Velocity): Velocity =
  result.x =
    if abs(v.x) == 0: v.x
    else: sgn(v.x) * -1 + v.x
  
  result.y = v.y - 1

func `+`(p1,p2: Point): Point=
  (p1.x + p2.x, p1.y + p2.y)

func contains(area: Area, p: Point): bool=
  (p.x in area.x) and (p.y in area.y)

func sum1to(n: int): int=
  n * (n + 1) div 2

func reachesBeforeStop(d: int): int=
  result = int.high
  for n in countdown(d, 1):
    if sum1to(n) > d:
      result = min(result, n)

func canMakeIt(v: Velocity, area: Area): bool=
  var 
    p: Point = (0,0)
    myv = v

  while p.y >= area.y.b:
    p = p + myv
    myv = applyDrag(myv)

    if p in area:
      return true

func bestShoot(area: Area): Point =
  let 
    minx = reachesBeforeStop area.x.a 
    maxx = reachesBeforeStop area.x.b + area.y.len

  result = (int.low, int.low)

  # debugEcho minx
  # debugEcho maxx

  for x in minx..maxx:
    var madeForFirstTime = false
    for y in area.y.a..int16.high:
      let t  = canMakeIt((x,y), area) 

      if t:
        # madeForFirstTime = true

        if y > result.y:
          result = (x,y)

      # elif madeForFirstTime:
        # break


# go -----------------------------------------

let 
  test = readFile("./test.txt").parseInput
  inp = readFile("./input.txt").parseInput


echo test, inp
echo bestShoot(test).y.sum1to
echo bestShoot(inp).y.sum1to # 9180

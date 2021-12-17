import sequtils, strscans, math, algorithm

# prepare ------------------------------------

type
  Area = tuple
    x, y: HSlice[int, int]

  Velocity = tuple[x, y: int]
  Point = Velocity

  Intersect = tuple[x, step: int, stopped: bool]

# utils --------------------------------------

func toValidRange(rng: HSlice[int, int]): HSlice[int, int] =
  if rng.a > rng.b:
    rng.b .. rng.a
  else:
    rng

func parseInput(s: sink string): Area =
  discard scanf(s,
    "target area: x=$i..$i, y=$i..$i",
    result.x.a, result.x.b, result.y.a, result.y.b)

  (toValidRange(result.x), toValidRange(result.y))

func sum1to(n: int): int =
  n * (n + 1) div 2

# implement ----------------------------------

iterator intersects(xs: HSlice[int, int]): Intersect =
  for n in 1..xs.b:
    let sn = sum1to(n)
    for k in 0 ..< n:
      if sn - sum1to(k) in xs:
        yield (n, n - k, k == 0)

func resolveY(a, v, t: int): int =
  t * v + sum1to(max(t - 1, 0)) * a

func shoots(area: Area): seq[Point] =
  for i in intersects(area.x):
    for vy in area.y.a .. int16.high:

      template calcY: untyped =
        resolveY(-1, vy, step)
      template acc =
        if y in area.y:
          # debugecho (i.x, y, vy)
          result.add (i.x, vy)

      var
        step = i.step
        y = calcy()

      acc()
      if i.stopped:
        while y > area.y.b:
          step.inc
          y = calcy()
          acc()


  result.deduplicate

# go -----------------------------------------

let
  data = readFile("./input.txt").parseInput
  ps = shoots(data)

let res* = ps.mapIt(cast[(int, int)](it)).sorted
echo res.mapIt(it[1]).max.sum1to # 9180
echo res.len # 3767
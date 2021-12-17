import sequtils, strscans

# prepare ------------------------------------

type
  Area = tuple
    x, y: HSlice[int, int]

  Velocity = tuple[x, y: int]
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

func findVeclocities(area: Area): seq[Velocity] =
  for i in intersects(area.x):
    for vy in area.y.a .. int16.high:
      var
        step = i.step
        y: int

      while y > area.y.b:
        y = resolveY(-1, vy, step)
  
        if y in area.y:
          result.add (i.x, vy)

        if i.stopped:
          step.inc
        else:
          break

  result.deduplicate

# go -----------------------------------------

let
  data = readFile("./input.txt").parseInput
  vs = findVeclocities(data)

echo vs.mapIt(it.y).max.sum1to # 9180
echo vs.len # 3767

import std/[sequtils, strutils, strscans, sets, tables]

# def ----------------------------------------

type
  Position = tuple
    x, y, z: int

  Volume = tuple
    xs, ys, zs: Slice[int]

# utils --------------------------------------

func `+`(a, b: Position): Position =
  (a.x+b.x, a.y+b.y, a.z+b.z)

func add[K, V](t: var Table[K, V], k: K, val: V) =
  if k in t:
    t[k].add val
  else:
    t[k] = @[val]

# implement ----------------------------------

func parsePosition(s: string): Position =
  discard scanf(s, "$i,$i,$i", result.x, result.y, result.z)

iterator neighbours(p: Position): Position =
  for vec in [
    (0, 0, +1),
    (0, 0, -1),
    (0, +1, 0),
    (0, -1, 0),
    (+1, 0, 0),
    (-1, 0, 0),
  ]:
    yield p + vec

func volume(cubes: seq[Position]): Volume =
  let c = cubes[0]
  result = (c.x..c.x, c.y..c.y, c.z..c.z)

  for c in cubes:
    result = (
      min(result.xs.a, c.x)..max(result.xs.b, c.x),
      min(result.ys.a, c.y)..max(result.ys.b, c.y),
      min(result.zs.a, c.z)..max(result.zs.b, c.z),
    )

func groupByZ(cubes: seq[Position]): Table[int, seq[Position]] =
  for c in cubes:
    result[c.z].add c

func trappedAir(v: Volume, surface: seq[Position]): HashSet[Position] =
  discard

func trappedAir(v: Volume, levelz: Table[int, seq[Position]]): seq[HashSet[Position]] =
  var lastLayer = v.trappedAir levelz.getOrDefault((v.zs.a))
  
  for z in v.zs:
    let newLayer = v.trappedAir levelz.getOrDefault((v.zs))
    

func surfaceAreaImpl(cubes: HashSet[Position]): int =
  for c in cubes:
    for n in neighbours c:
      if n in cubes:
        result.inc

  cubes.len * 6 - result

func surfaceArea(cubes: seq[Position]): int =
  surfaceAreaImpl toHashSet cubes

func exteriorSurfaceArea(cubes: seq[Position]): int =
  let
    cubesSet = toHashSet cubes
    v = volume cubes
    g = groupByZ cubes

  for layer in trappedAir(v, g):
    for p in layer:
      for n in neighbours p:
        if n in cubesSet:
          result.inc

  surfaceAreaImpl(cubesSet) - result

# go -----------------------------------------

let data = "./input.txt".readFile.splitLines.map(parsePosition)
echo data.surfaceArea # 4302
echo data.exteriorSurfaceArea #

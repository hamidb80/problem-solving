import sequtils, strutils, strscans, math

{.experimental: "strictFuncs".}

# def ------------------------------------

type
  Point = tuple[x, y, z: int]

  Axises = enum
    X, Y, Z

  DirectionComparision = tuple[sameSign: bool, axis: Axises]

  Rotation = object
    x,y,z: DirectionComparision

  Transform = tuple
    position: Point
    rotation: Rotation

  Scanner = object
    id: int
    records: seq[Point]

  Relation = tuple
    i1, i2: int
    transform: Transform

# utils --------------------------------------

func `+`(p1, p2: Point): Point =
  (p1.x + p2.x, p1.y + p2.y, p1.z + p2.z)

func `-`(p: Point): Point =
  (-p.x, -p.y, -p.z)

func `-`(p1, p2: Point): Point =
  p1 + -p2

func distance2(p1, p2: Point): Positive =
  template r(axis): untyped = p1.axis - p2.axis
  r(x)^2 + r(y)^2 + r(z)^2

func parsePoint(s: sink string): Point =
  discard scanf(s, "$i,$i,$i", result.x, result.y, result.z)

func parseHeader(s: sink string): int =
  discard scanf(s, "--- scanner $i ---", result)

func parseInput(s: sink string): seq[Scanner] =
  for sc in s.split "\r\n\r\n":
    var acc: Scanner

    for l in sc.splitLines:
      if l.startsWith "-":
        acc.id = parseHeader l
      else:
        acc.records.add parsePoint l

    result.add acc

iterator combinations[T](s: openArray[T]): (T, T) =
  for i in s.low ..< s.high:
    for j in (i+1) .. s.high:
      yield (s[i], s[j])

iterator pairs(p: Point): tuple[axis: Axises, value: int] =
  yield (X, p.x)
  yield (Y, p.y)
  yield (Z, p.z)

func `[]`(p: Point, axis: Axises): int=
  case axis:
  of X: p.x
  of Y: p.y
  of Z: p.z

func `[]=`(r: var Rotation, axis: Axises, val: DirectionComparision)=
  case axis:
  of X: r.x = val
  of Y: r.y = val
  of Z: r.z = val

# implement ----------------------------------

func applyRotation(p: Point, r: Rotation): Point =
  discard

func applyTransform(p: Point, tr: Transform): Point =
  tr.position - p.applyRotation(tr.rotation)

func findRotation(dp1, dp2: Point): Rotation =
  # TODO asssert uniqness of axises and they not be 0
  for ax1, v1 in dp1.pairs:
    for ax2, v2 in dp2.pairs:
      if abs(v1) == abs(v2):
        result[ax1] = (sgn(v1) == sgn(v2), ax2)

func findTransformation(dp1, dp2: Point): Transform =
  discard


func findTransformationMap(rels: seq[Relation]): seq[Transform] =
  discard

func haveInCommon(r1, r2: Scanner, atLeast: int
): tuple[result: bool, transform: Transform] =

  discard

func howManyBeacons(reports: seq[Scanner]): int =
  var
    relations: seq[Relation]
    acc: seq[Point]

  for r1, r2 in reports.combinations:
    let cm = haveInCommon(r1, r2, 12)
    if cm.result:
      relations.add (r1.id, r2.id, cm.transform)

  assert relations.len >= reports.len

  for p in reports[0].records:
    acc.add p

  let transformMap = findTransformationMap(relations) # transform map from id[0] => id[N]

  for id in 1..reports.high:
    acc.add reports[id].records.mapIt(applyTransform(it, transformMap[id]))

  acc.deduplicate.len

# go -----------------------------------------

let data = readfile("./test.txt").parseInput
echo howManyBeacons(data)

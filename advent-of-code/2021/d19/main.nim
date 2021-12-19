import std/[sequtils, strutils, strscans, math, tables, intsets]

{.experimental: "strictFuncs".}

# def ------------------------------------

type
  Point* = object
    x, y, z: int

  Axises = enum
    X, Y, Z

  DirectionComparision = tuple[sameSign: bool, axis: Axises]

  Rotation = object
    x, y, z: DirectionComparision

  Transform = tuple
    position: Point
    rotation: Rotation

  Scanner = object
    id: int
    records: seq[Point]

  Relation = tuple
    with: int
    transform: Transform

  RelationTable = Table[int, seq[Relation]]
  TransformTable = seq[seq[Transform]]

# utils --------------------------------------

func parsePoint(s: sink string): Point =
  discard scanf(s, "$i,$i,$i", result.x, result.y, result.z)

func parseHeader(s: sink string): int =
  discard scanf(s, "--- scanner $i ---", result)

func parseInput(s: sink string): seq[Scanner] =
  for sc in s.split "\r\n\r\n":
    var acc: Scanner

    for l in sc.splitLines:
      if l.startsWith "---":
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


func newPoint*(x, y, z: int): Point =
  Point(x: x, y: y, z: z)

func `+`(p1, p2: Point): Point =
  newPoint(p1.x + p2.x, p1.y + p2.y, p1.z + p2.z)

func `-`(p: Point): Point =
  newPoint(-p.x, -p.y, -p.z)

func `-`(p1, p2: Point): Point =
  p1 + -p2

func distance2*(p1, p2: Point): int =
  template op(axis): untyped = (p1.axis - p2.axis)^2
  op(x) + op(y) + op(z)

func `[]`(p: Point, axis: Axises): int =
  case axis:
  of X: p.x
  of Y: p.y
  of Z: p.z

func `[]=`(p: var Point, axis: Axises, val: int) =
  case axis:
  of X: p.x = val
  of Y: p.y = val
  of Z: p.z = val

func `[]`(r: Rotation, axis: Axises): DirectionComparision =
  case axis:
  of X: r.x
  of Y: r.y
  of Z: r.z

func `[]=`(r: var Rotation, axis: Axises, val: DirectionComparision) =
  case axis:
  of X: r.x = val
  of Y: r.y = val
  of Z: r.z = val

# implement ----------------------------------

func resolveSign(sameSign: bool): int =
  if sameSign: +1
  else: -1

func add(acc: var RelationTable, id: int, rel: Relation) =
  if id in acc:
    acc[id].add rel
  else:
    acc[id] = @[rel]

func rotate(p: Point, r: Rotation): Point =
  for ax in [X, Y, Z]:
    result[ax] = p[r[ax].axis] * resolveSign(r[ax].sameSign)

func `^`(r: Rotation): Rotation =
  for ax in [X, Y, Z]:
    result[r[ax].axis] = (r[ax].sameSign, ax)

func `^`(tr: Transform): Transform =
  (-tr.position, ^tr.rotation)

func transform(p: Point, tr: Transform): Point =
  (tr.position + p).rotate(tr.rotation)

func transform(p: Point, trs: seq[Transform]): Point =
  result = p
  for t in trs:
    result = transform(p, t)

func findRotation(dp1, dp2: Point): Rotation =
  # TODO asssert uniqness of axises and they not be 0
  for ax1, v1 in dp1.pairs:
    for ax2, v2 in dp2.pairs:
      if abs(v1) == abs(v2):
        result[ax1] = (sgn(v1) == sgn(v2), ax2)

func findTransformation(primary, secondary: Point): Transform =
  let r = findRotation(secondary, primary)
  (secondary.rotate(r) - primary, r)

func findTransformationPath(rels: RelationTable, path: seq[int], dest: int,
    result: var seq[int]
) =
  for r in rels[path[^1]]:
    if r.with == dest:
      result = path
      return

    elif r.with notin path:
      findTransformationPath(rels, path & @[r.with], dest, result)

func genTransformTable(rels: RelationTable, `from`: int): TransformTable =
  result = newSeqWith(rels.len, newseq[Transform]())
  for id in 0 ..< rels.len:
    if id == `from`: continue
    var path: seq[int]
    findTransformationPath(rels, @[`from`], id, path)
    result[id] = @[]
    var rel = rels[0]
    for i in path[1..^1]:
      for r in rel:
        if r.with == i:
          result[id].add r.transform
          break

func relDistance*(pin: Point, sp: seq[Point]): IntSet =
  toIntSet sp.mapIt distance2(pin, it)

func haveInCommon(s1, s2: Scanner, atLeast: int
): tuple[result: bool, transform: Transform] =

  for p1 in s1.records:
    let sp1 = relDistance(p1, s1.records)

    for p2 in s2.records:
      let 
        sp2 = relDistance(p2, s2.records)
        ins = intersection(sp1, sp2)

      if ins.len >= atleast:
        # for 
        debugEcho (s1.id, s2.id)

func howManyBeacons(reports: seq[Scanner]): int =
  var
    relations: RelationTable
    acc: seq[Point]

  for r1, r2 in reports.combinations:
    let cm = haveInCommon(r1, r2, 12)
    if cm.result:
      relations.add r1.id, (r2.id, cm.transform)
      relations.add r2.id, (r1.id, ^cm.transform)

  assert relations.len >= reports.len

  for p in reports[0].records:
    acc.add p

  let trTable = genTransformTable(relations, 0)

  for id in 1..reports.high:
    acc.add reports[id].records.mapIt(transform(it, trTable[id]))

  acc.deduplicate.len

# go -----------------------------------------

let data = readfile("./test.txt").parseInput
echo howManyBeacons(data)

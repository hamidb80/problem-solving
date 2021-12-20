import std/[sequtils, strutils, strscans, math, tables, intsets, unittest, strformat]

{.experimental: "strictFuncs".}

# def ------------------------------------

type
  Axises = enum
    X, Y, Z

  Point* = object
    x, y, z: int

  Vector = Point

  DirectionComparision = tuple
    sameSign: bool
    axis: Axises

  Rotation = object
    x, y, z: DirectionComparision

  Transform = object
    movement: Point
    rotation: Rotation
    reversed: bool

  Scanner = object
    id: int
    records: seq[Point]

  Relation = tuple
    with: int
    transform: Transform

  RelationTable = Table[int, seq[Relation]]
  TransformTable = Table[int, seq[Transform]]

# utils --------------------------------------

template findIt(s, cond: untyped): untyped =
  var
    temp: typeof s[0]
    found = false

  for it {.inject.} in s:
    if cond:
      temp = it
      found = true
      break

  if not found:
    raise newException(ValueError, "not found")

  temp

func parsePoint(s: sink string): Point =
  discard scanf(s, "$i,$i,$i", result.x, result.y, result.z)

func parseHeader(s: sink string): int =
  discard scanf(s, "--- scanner $i ---", result)

func newTransform(m: Vector, ro: Rotation, rev: bool = false): Transform =
  Transform(movement: m, rotation: ro, reversed: rev)

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

iterator items(p: Point): int =
  yield p.x
  yield p.y
  yield p.z

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

func addto[K, V](acc: var Table[K, seq[V]], key: K, val: V) =
  if key in acc:
    acc[key].add val
  else:
    acc[key] = @[val]

func rotate(p: Point, r: Rotation): Point =
  for ax in [X, Y, Z]:
    result[r[ax].axis] = p[ax] * resolveSign(r[ax].sameSign)

func `^`(r: Rotation): Rotation =
  for ax in [X, Y, Z]:
    result[r[ax].axis] = (r[ax].sameSign, ax)

func `^`(tr: Transform): Transform =
  newTransform(tr.movement, tr.rotation, not tr.reversed)

func transform(p: Point, tr: Transform): Point =
  if tr.reversed:
    (p - tr.movement).rotate(^tr.rotation)
  else:
    p.rotate(tr.rotation) + tr.movement

func transform(p: Point, trs: seq[Transform]): Point =
  result = p
  for t in trs:
    result = transform(result, t)

func validCond(p: Point): bool =
  let s = p.toSeq
  s.allIt(it != 0) and s.deduplicate.len == 3

func findRotation(dp1, dp2: Point): Rotation =
  for ax1, v1 in dp1.pairs:
    for ax2, v2 in dp2.pairs:
      if abs(v1) == abs(v2):
        result[ax1] = (sgn(v1) == sgn(v2), ax2)

  assert [result.x.axis, result.y.axis, result.z.axis].deduplicate.len == 3

func findTransformationPathImpl(rels: RelationTable, path: seq[int], dest: int,
    result: var seq[int]
) =
  for r in rels[path[^1]]:
    let newp = path & @[r.with]

    if r.with == dest:
      result = newp
      return

    elif r.with notin path:
      findTransformationPathImpl(rels, newp, dest, result)

func findTransformationPath(rels: RelationTable, `from`, to: int): seq[int] =
  findTransformationPathImpl(rels, @[`from`], to, result)

func findMove(p1, p2: Point, ro: Rotation): Vector =
  ## p1 and p2 are in the same position but in different coordinate system
  p2 - p1.rotate(ro)

func genTransformTable(relTable: RelationTable, `from`: int): TransformTable =
  for id in relTable.keys:
    if id == `from`: continue

    let path = findTransformationPath(relTable, id, `from`)[1..^1]
    var head = id
    for i in path:
      result.addto id, (relTable[head].findIt it.with == i).transform
      head = i

    assert result[id].len == path.len

func relDistance*(pin: Point, sp: seq[Point]): IntSet =
  toIntSet sp.mapIt distance2(pin, it)

func buildTransform(pin1, p1, pin2, p2: Point): Transform =
  let
    dp1 = pin1 - p1
    dp2 = pin2 - p2
    ro = findRotation(dp1, dp2)

  newTransform(findMove(pin1, pin2, ro), ro)

func haveInCommon(s1, s2: Scanner, atLeast: int
): tuple[result: bool, transform: Transform] =

  for pin1 in s1.records:
    let sp1 = relDistance(pin1, s1.records)

    for pin2 in s2.records:
      let
        sp2 = relDistance(pin2, s2.records)
        ins = intersection(sp1, sp2)

      if ins.len >= atleast:

        for p1 in s1.records:
          for p2 in s2.records:
            let
              d1 = distance2(pin1, p1)
              d2 = distance2(pin2, p2)

            if d1 == d2 and d1 != 0 and [pin1-p1, pin2-p2].allIt(it.validCond):
              return (true, buildTransform(pin1, p1, pin2, p2))

func howManyBeacons(reports: seq[Scanner]): int =
  var
    relations: RelationTable
    acc: seq[Point]

  for r1, r2 in reports.combinations:
    let cm = haveInCommon(r1, r2, 12)
    if cm.result:
      relations.addto r1.id, (r2.id, cm.transform)
      relations.addto r2.id, (r1.id, ^cm.transform)

  assert relations.len >= reports.len

  for p in reports[0].records:
    acc.add p

  let trTable = genTransformTable(relations, 0)

  for id in 1..reports.high:
    acc.add reports[id].records.mapIt(transform(it, trTable[id]))

  let ps = acc.deduplicate
  ps.len

# go -----------------------------------------

let data = readfile("./input.txt").parseInput
echo howManyBeacons(data)

# test ------------------------------

suite "transform":
  let
    ps1 = [
      newPoint(0, 2, 0),
      newPoint(4, 1, 0),
      newPoint(3, 3, 0),
    ]
    ps2 = [
      newPoint(0, -5, 0),
      newPoint(1, -1, 0),
      newPoint(-1, -2, 0),
    ]
    ps3 = [
      newPoint(-3, 4, 0),
      newPoint(-4, 0, 0),
      newPoint(-2, 1, 0),
    ]

  test "1":
    let tr = buildTransform(ps1[0], ps1[1], ps2[0], ps2[1])

    check ps1[1].transform(tr) == ps2[1]
    check ps2[1].transform(^tr) == ps1[1]
    check ps1[1].transform( ^ ^tr) == ps2[1]

  let
    `T(1->2)` = buildTransform(ps1[0], ps1[1], ps2[0], ps2[1])
    `T(2->3)` = buildTransform(ps2[0], ps2[1], ps3[0], ps3[1])

  test "chain":
    let
      cp =
        ps1[0]
        .transform(`T(1->2)`)
        .transform(`T(2->3)`)

      rcp =
        ps3[0]
        .transform( ^ `T(2->3)`)
        .transform( ^ `T(1->2)`)

    check cp == ps3[0]
    check rcp == ps1[0]

  var relt: RelationTable
  relt.addto(1, (2, `T(1->2)`))
  relt.addto(2, (3, `T(2->3)`))
  relt.addto(2, (1, ^`T(1->2)`))
  relt.addto(3, (2, ^`T(2->3)`))

  test "findTransformationPath":
    check:
      findTransformationPath(relt, 1, 2) == @[1, 2]
      findTransformationPath(relt, 1, 3) == @[1, 2, 3]
      findTransformationPath(relt, 2, 3) == @[2, 3]
      findTransformationPath(relt, 3, 1) == @[3, 2, 1]

  test "genTransformTable":
    let tts = genTransformTable(relt, 1)
    check ps3[0].transform(tts[3]) == ps1[0]

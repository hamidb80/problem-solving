import std/[sequtils, strutils, strscans, options, algorithm]

# def ----------------------------------------

type
  Position = tuple
    x, y: int

  Report = tuple
    sensor, beacon: Position

  DisJointSlices = distinct seq[Slice[int]]

# conventions -------------------------------

template `as`(v, t): untyped =
  cast[t](v)

# utils --------------------------------------

func intersectsImpl(s1, s2: Slice[int]): bool =
  s1.a <= s2.a and s1.b >= s2.a

func intersects(s1, s2: Slice[int]): bool =
  intersectsImpl(s1, s2) or intersectsImpl(s2, s1)


func byFirst(s1, s2: Slice[int]): int =
  cmp s1.a, s2.a

func sorted(ds: DisJointSlices): DisJointSlices =
  (ds as seq[Slice[int]]).sorted(byFirst, Ascending) as DisJointSlices

func card(ds: DisJointSlices): int =
  for s in ds as seq[Slice[int]]:
    result.inc s.len

func len(ds: DisJointSlices): int {.borrow.}

func del(ds: var DisJointSlices, i: int) {.borrow.}

func add(ds: var DisJointSlices, s: Slice[int]) {.borrow.}

func `$`(ds: DisJointSlices): string {.borrow, used.} # for debug

func `[]`(ds: DisJointSlices, i: int): Slice[int] = 
  (ds as seq[Slice[int]])[i]

func incl(ds: var DisJointSlices, r: Slice[int]) =
  var
    temp = r
    i = 0

  while i < ds.len:
    if intersects(ds[i], temp):
      temp = min(temp.a, ds[i].a)..max(temp.b, ds[i].b)
      del ds, i
    
    else:
      inc i

  ds.add temp

func excl(ds: var DisJointSlices, i: int) =
  var temp: seq[Slice[int]]

  for s in (ds as seq[Slice[int]]):
    if i in s:
      if s.len > 1:
        temp.add [s.a..i-1, i+1..s.b].filterIt(it.len != 0)

    else:
      temp.add s

  ds = temp as DisJointSlices

# implement ----------------------------------

func parseSensorReport(s: string): Report =
  discard scanf(s, "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i",
    result.sensor.x, result.sensor.y, result.beacon.x, result.beacon.y)

func manhattanDistance(p1, p2: Position): Natural =
  abs(p1.x - p2.x) + abs(p1.y - p2.y)

func intersectWith(report: Report, row: int): Option[Slice[int]] =
  let
    distance = manhattanDistance(report.sensor, report.beacon)
    dy = abs(report.sensor.y - row)

  let dx = distance - dy
  if dx >= 0:
    result = some report.sensor.x-dx .. report.sensor.x+dx

func placesCantBe(reports: seq[Report], row: int, 
  removeBeacons: bool,
  limit = none Slice[int]): DisJointSlices =
  for r in reports:
    let inter = intersectWith(r, row)
    if isSome inter:
      result.incl inter.get

  if removeBeacons:
    for r in reports:
      if r.beacon.y == row:
        result.excl r.beacon.x

func tuningFrequency(p: Position): int =
  p.x * 4000000 + p.y

func missing(ds: DisJointSlices, limit: Slice[int]): Option[int] =
  var
    p = limit.a
    started = false

  for s in ds.sorted as seq[Slice[int]]:
    if p in s:
      p = s.b+1
      started = true
    
    elif started:
      return some p
  
  if p in limit:
    some p
  else:
    none int

func missingBeacon(reports: seq[Report], mapLimit: Slice[int]): Position =
  for y in mapLimit:
    let ds = placesCantBe(reports, y, false, some mapLimit)
    let m = missing(ds, mapLimit)
    if isSome m: 
      return (m.get, y)

  assert false, "cannot find"

# go -----------------------------------------

let reports = "./input.txt".readFile.splitLines.map(parseSensorReport)
echo placesCantBe(reports, 2000000, true).card # 5716881
echo missingBeacon(reports, 0..4000000).tuningFrequency # 10852583132904

import std/[sequtils, strutils, strformat, unittest, tables, math]

{.experimental: "strictFuncs".}

# def ----------------------------------------

type
  CellState = enum
    Empty = "."
    A = "A"
    B = "B"
    C = "C"
    D = "D"

  Highway = array[11, CellState]
  Room = array[2, CellState]
  Burrow = array[4, Room]

const
  roomEntries = [2, 4, 6, 8]
  allowedStops = (0..<11).toseq.filterit it notin roomEntries
  amphipodOrder = [A, B, C, D]
  energyCost = [1, 10, 100, 1000]

# utils --------------------------------------

func parseInput(s: sink string): Burrow =
  let rows =
    s.splitLines[2..3].mapit do:
      it[3..9]
      .split('#')
      .mapIt parseEnum[CellState](it)

  for c in 0 ..< 4:
    for r in 0 ..< 2:
      result[c][r] = rows[r][c]

func replace[N, T](a: array[N, T], index: int, val: T): array[N, T] =
  result = a
  result[index] = val

func replace(b: Burrow, roomIndex, level: int, value: CellState): Burrow =
  result = b
  result[roomIndex][level] = value

# implement ----------------------------------

func render(b: Burrow, h: Highway): string =
  "#############\n" &
  "#" & h.join & "#\n" &
  "###" & b.mapIt(it[0]).join"#" & "###\n" &
  "  #" & b.mapIt(it[1]).join"#" & "#\n" &
  "  #########"

func isSolved(burrow: Burrow): bool =
  for i, a in amphipodOrder.pairs:
    if not burrow[i].allIt(it == a):
      return false

func isRoadFree(`from`, to: int, h: Highway): bool =
  let road =
    if `from` <= to:
      h[`from` .. to]
    else:
      h[to .. `from`]

  road.allIt it == Empty

func canEnterInRoom(r: Room, owner: CellState): tuple[can: bool, depth: int] =
  if r[0] == Empty:
    result =
      if r[1] == Empty: (true, 2)
      elif r[1] == owner: (true, 1)
      else: (false, 0)

func isEmpty(r: Room): bool =
  r.allit it == Empty

func exportMember(r: Room, owner: CellState): tuple[should: bool, index: int] =
  assert not r.isEmpty
  assert owner != Empty
  # [A][ ][D][ ]
  # [B][ ][C][A]

  if r[1] != owner:
    if r[0] == Empty:
      result = (true, 1)
    else:
      result = (true, 0)

  else:
    if r[0] != owner:
      result = (true, 0)

func leastEnergyImpl(
  burrow: Burrow, highway: Highway, costYet: int
): tuple[solved: bool, totalCost: int] =

  var didSomeOperation = false
  template wellDone: untyped =
    didSomeOperation = true

  template reCalculate(res): untyped =
    result = (true, min(result.totalCost, res.totalCost))

  for i, cell in highway.pairs:
    if cell != Empty:
      let ri = amphipodOrder.find(cell) # room index

      if isRoadFree(i, roomEntries[ri], highway):
        let (can, depth) = canEnterInRoom(burrow[ri], cell)
        if can:
          wellDone()

          let
            distance = abs(i - ri) + depth
            res = leastEnergyImpl(
              burrow.replace(ri, depth - 1, cell),
              highway.replace(i, Empty),
              costyet + distance * energyCost[ri]
            )

          if res.solved:
            reCalculate res

  for stp in allowedStops:
    let cell = highway[stp]

    if cell == Empty:
      for ri, room in burrow.pairs:
        if not isRoadFree(roomEntries[ri], stp, highway):
          continue

        let
          (should, i) = exportMember(room, amphipodOrder[ri])
          distance = abs(stp - roomEntries[ri])

        if should:
          wellDone()
          let res = leastEnergyImpl(
            burrow.replace(ri, i, Empty),
            highway.replace(stp, room[i]),
            costyet + (i + 1 + distance) * energyCost[ri]
          )

          if res.solved:
            reCalculate res

  if not didSomeOperation:
    result = (isSolved(burrow), costYet)

func leastEnergy(burrow: Burrow, highway = Highway.default): int =
  let r = leastEnergyImpl(burrow, highway, 0)
  assert r.solved
  r.totalCost

# tests --------------------------------------

# test "":
#   check true

# go -----------------------------------------

let data = readFile("./test.txt").parseInput
echo leastEnergy(data)

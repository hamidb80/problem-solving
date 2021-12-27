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

func initHighway(s: string): Highway =
  for (i, c) in s.pairs:
    result[i] = parseEnum[CellState]($c)

func replace[N, T](a: array[N, T], index: int, val: T): array[N, T] =
  result = a
  result[index] = val

# implement ----------------------------------

func render(b: Burrow, h: Highway): string =
  "#############\n" &
  "#" & h.join & "#\n" &
  "###" & b.mapIt(it[0]).join"#" & "###\n" &
  "  #" & b.mapIt(it[1]).join"#" & "#\n" &
  "  #########"

func isFinished(burrow: Burrow, highway: Highway): bool =
  if highway.allIt it == Empty:
    result = true

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

func canEnterInRoom(r: Room, amphipodType: CellState): tuple[can: bool, depth: int] =
  if r[0] == Empty:
    result =
      if r[1] == Empty: (true, 2)
      elif r[1] == amphipodType: (true, 1)
      else: (false, 0)

func leastEnergyImpl(burrow: Burrow, highway: Highway): int =
  for i, cell in highway.pairs:
    if cell != Empty:
      let ri = amphipodOrder.find(cell) # room index

      if isRoadFree(i, roomEntries[ri], highway):
        let (can, depth) = canEnterInRoom(burrow[ri], cell)
        if can:
          let distance = abs(i - ri) + depth
          result += distance * energyCost[ri]
          ## call new recursion with replace or ignore

  for room in burrow:
    ## if ground was not type
    for stp in allowedStops:
      if highway[stp] == Empty:
        discard

func leastEnergy(burrow: Burrow, highway = Highway.default): int =
  0

# tests --------------------------------------

# test "":
#   check true

# go -----------------------------------------

let data = readFile("./test.txt").parseInput
echo leastEnergy(data)

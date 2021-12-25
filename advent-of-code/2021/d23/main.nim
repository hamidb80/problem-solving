import std/[sequtils, strutils, strformat, unittest, tables]

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
  energyCost = {A: 1, B: 10, C: 100, D: 1000}.toTable

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

func initHighway(s: string = ""): Highway =
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
    for i, a in amphipodOrder.pairs:
      if not burrow[i].allIt(it == a):
        return false

    true
  else: false

func canGotoRoom(r: Room, amphipodType: CellState): tuple[can: bool, depth: int] =
  if r[0] == Empty:
    if r[1] == Empty:
      (true, 2)
    elif r[1] == amphipodType:
      (true, 1)
    else:
      (false, 0)

  else:
    (false, 0)

func leastEnergyToArrange(burrow: Burrow): int =
  var highway = initHighway()

  # check any of them can goto the home
  for i, cell in highway.pairs:
    if cell != Empty:
      # check inside it's destination room
      let 
        ri = amphipodOrder.find(cell) # room index
        (can, depth) = canGotoRoom(burrow[ri], cell)
      
      if can:
        discard

  for room in burrow:
    for stp in allowedStops:
      if highway[stp] == Empty:
        discard
       
# tests --------------------------------------

# test "":
#   check true

# go -----------------------------------------

let data = readFile("./test.txt").parseInput
echo data
echo leastEnergyToArrange(data)

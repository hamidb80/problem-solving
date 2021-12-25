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

func toHighway(s: string = ""): Highway=
  for (i,c ) in s.pairs:
    result[i] = parseEnum[CellState]($c)

# implement ----------------------------------

func render(b: Burrow, h: Highway): string =
  "#############\n" &
  "#" & h.join & "#\n" &
  "###" & b.mapIt(it[0]).join"#" & "###\n" &
  "  #" & b.mapIt(it[1]).join"#" & "#\n" &
  "  #########"

func isFinished(burrow: Burrow, highway: Highway): bool=
  if highway.allIt it == Empty:
    for i, a in amphipodOrder.pairs:
      if not burrow[i].allIt(it == a):
        return false

    true
  else: false

const notFound = -1
func leastEnergyToArrangeImpl(burrow: Burrow, highway: Highway, result: var int)=
  var 
    mb = burrow
    mh  = highway

  for room in burrow:
    for hi in 0 .. highway.high:
      discard
  
func leastEnergyToArrange(burrow: Burrow): int =
  leastEnergyToArrangeImpl(burrow, toHighway(), result)

# tests --------------------------------------

# test "":
#   check true

# go -----------------------------------------

let data = readFile("./test.txt").parseInput
echo data
echo leastEnergyToArrange(data)

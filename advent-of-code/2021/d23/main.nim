import std/[sequtils, strutils, strformat, unittest, tables]

{.experimental: "strictFuncs".}

# def ----------------------------------------

type
  CellState = enum
    Empty = '.'
    A = 'A'
    B = 'B'
    C = 'C'
    D = 'D'

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

# implement ----------------------------------

func leastEnergyToArrange(burrow: Burrow): int =
  discard

# tests --------------------------------------

test "":
  check true

# go -----------------------------------------

let data = readFile("./test.txt").parseInput
echo data
# echo test(data)

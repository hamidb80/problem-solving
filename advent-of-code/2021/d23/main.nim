import std/[sequtils, strutils, unittest, tables]

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

  Data = tuple[highway: Highway, burrow: Burrow]

const
  roomEntries = [2, 4, 6, 8]
  allowedStops = (0..<11).toseq.filterit it notin roomEntries
  amphipodOrder = [A, B, C, D]
  energyCost = [1, 10, 100, 1000]

# utils --------------------------------------

func parseHighway(s: sink string): Highway =
  for i, c in s.pairs:
    result[i] = parseEnum[CellState]($c)

func parseInput(s: sink string): Data =
  let rows =
    s.splitLines[2..3].mapit do:
      it[3..9]
      .split('#')
      .mapIt parseEnum[CellState](it)

  for c in 0 ..< 4:
    for r in 0 ..< 2:
      result.burrow[c][r] = rows[r][c]

  result.highway = parseHighway s.splitLines[1][1 .. ^2]

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
  result = true
  for i, owner in amphipodOrder.pairs:
    if not burrow[i].allIt(it == owner):
      return false

func correctOrder(rng: HSlice[int, int], startOffset = 0): HSlice[int, int] =
  if rng.a > rng.b:
    rng.b .. rng.a-startOffset
  else:
    rng.a+startOffset .. rng.b

func isRoadFree(head, tail: int, h: Highway): bool =
  let road = correctOrder(head .. tail, 1)
  h[road].allIt it == Empty

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
    if r[0] != Empty and r[0] != owner:
      result = (true, 0)

func leastEnergyImpl(
  burrow: Burrow, highway: Highway, costYet: int
): tuple[solved: bool, totalCost: int] =
  result.totalCost = int.high

  var didSomeOperation = false
  template wellDone: untyped =
    didSomeOperation = true

  template reCalculate(res): untyped =
    if res.solved:
      result = (true, min(result.totalCost, res.totalCost))

  for i, cell in highway.pairs:
    if cell != Empty:
      let ri = amphipodOrder.find(cell) # room index

      if isRoadFree(i, roomEntries[ri], highway):
        let (can, depth) = canEnterInRoom(burrow[ri], cell)
        if can:
          wellDone()

          # debugEcho "\n----------------\n"
          # debugEcho render(burrow, highway)
          # debugEcho costYet

          let
            distance = abs(i - roomEntries[ri]) + depth
            res = leastEnergyImpl(
              burrow.replace(ri, depth - 1, cell),
              highway.replace(i, Empty),
              costyet + distance * energyCost[ri]
            )

          reCalculate res

  for stp in allowedStops:
    if highway[stp] == Empty:
      for ri, room in burrow.pairs:
        if isRoadFree(roomEntries[ri], stp, highway) and not room.isEmpty:
          let
            (should, i) = exportMember(room, amphipodOrder[ri])
            xdistance = abs(stp - roomEntries[ri])

          if should:
            wellDone()

            # debugEcho "\n------  --------\n"
            # debugEcho render(burrow, highway)
            # debugEcho costYet

            let res = leastEnergyImpl(
              burrow.replace(ri, i, Empty),
              highway.replace(stp, room[i]),
              costyet + (i + 1 + xdistance) * energyCost[amphipodOrder.find room[i]]
            )

            reCalculate res

  if not didSomeOperation:
    result = (isSolved(burrow), costyet)

func leastEnergy(burrow: Burrow, highway: Highway): int =
  let r = leastEnergyImpl(burrow, highway, 0)
  assert r.solved
  r.totalCost

# tests --------------------------------------

test "correctOrder":
  check correctOrder(2 .. 5) == 2..5
  check correctOrder(5 .. 2) == 2..5
  check correctOrder(2 .. 5, 1) == 3..5
  check correctOrder(5 .. 2, 1) == 2..4

test "isSolved":
  check isSolved([ [A, A], [B, B], [C, C], [D, D]])
  check not isSolved([ [B, A], [A, B], [C, C], [D, D]])

test "is road free":
  block no:
    var hw = Highway.default
    hw[4] = A
    check not isRoadFree(2, 4, hw)
    check isRoadFree(4, 2, hw)

  block yes:
    var hw = Highway.default
    check isRoadFree(2, 4, hw)
    check isRoadFree(4, 2, hw)

suite "move":
  test "1 steps to win":
    let d = """
      #############
      #.........A.#
      ###.#B#C#D###
        #A#B#C#D#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == 8
    
  test "2 steps to win":
    let d = """
      #############
      #...B.....A.#
      ###.#.#C#D###
        #A#B#C#D#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == 28

  test "3 steps to win":
    let d = """
      #############
      #.....D.D.A.#
      ###.#B#C#.###
        #A#B#C#.#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == (3 + 4) * 1000 + 8

  test "5 steps to win":
    let d = """
      #############
      #.....D.....#
      ###B#.#C#D###
        #A#B#C#A#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == 9011 + 40

  test "8 steps to win":
    let d = """
      #############
      #...B.......#
      ###B#C#.#D###
        #A#D#C#A#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == 12081 + 400

# go -----------------------------------------

let data = readFile("./input.txt").parseInput
echo leastEnergy(data.burrow, data.highway)

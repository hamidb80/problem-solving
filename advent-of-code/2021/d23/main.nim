import std/[sequtils, strutils, unittest]

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
  Room = seq[CellState]
  Burrow = array[4, Room]

  Data = tuple[highway: Highway, burrow: Burrow]

const
  roomEntries = [2, 4, 6, 8]
  allowedStops = (0..<11).toseq.filterit it notin roomEntries
  amphipodOrder = [A, B, C, D]
  energyCost = [1, 10, 100, 1000]

# utils --------------------------------------

func parseHighway(s: string): Highway =
  for i, c in s.pairs:
    result[i] = parseEnum[CellState]($c)

func unfoldMap(s: string): string =
  let rows = s.splitLines()
  join(
    rows[0..2] &
    ["#D#C#B#A#", "#D#B#A#C#"].mapIt(it.indent 2) &
    rows[3..4],
    "\n"
  )

func parseInput(s: string): Data =
  let rows =
    s.splitLines[2..^2].mapit do:
      it[3..9]
      .split('#')
      .mapIt parseEnum[CellState](it)

  for c in 0 ..< 4:
    for r in 0 ..< rows.len:
      result.burrow[c].add rows[r][c]

  result.highway = parseHighway s.splitLines[1][1 .. ^2]

func replace[N, T](a: array[N, T], index: int, val: T): array[N, T] =
  result = a
  result[index] = val

func replace(b: Burrow, roomIndex, level: int, value: CellState): Burrow =
  result = b
  result[roomIndex][level] = value

# implement ----------------------------------

func render(b: Burrow, h: Highway): string =
  ## debugging purposes

  var rows: seq[string]
  for i in 0..b[0].high:
    rows.add "  #" & b.mapIt(it[i]).join"#" & "#"

  "#############\n" &
  "#" & h.join & "#\n" &
  rows.join("\n") &
  "\n  #########"

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

func isEmpty(r: Room): bool =
  r.allit it == Empty

func canEnterInRoom(r: Room, owner: CellState): tuple[can: bool, depth: int] =
  if r.allIt it in [Empty, owner]:
    let i = r.find(owner)

    result =
      if i == -1:
        (true, r.len)
      else:
        (true, i)

func exportMember(r: Room, owner: CellState): tuple[should: bool, index: int] =
  # [A][ ][D][ ]
  # [B][ ][C][A]
  if not r.allIt it in [Empty, owner]:
    result.should = true
    for i, c in r.pairs:
      if c != Empty:
        result.index = i
        break

func leastEnergyImpl(
  burrow: Burrow, highway: Highway,
  costYet: int, minCost: var int
) =
  if costYet > minCost: return

  var didSomeOperation = false
  template wellDone: untyped = didSomeOperation = true

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

          leastEnergyImpl(
            burrow.replace(ri, depth - 1, cell),
            highway.replace(i, Empty),
            costyet + distance * energyCost[ri],
            minCost
          )

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

            leastEnergyImpl(
              burrow.replace(ri, i, Empty),
              highway.replace(stp, room[i]),
              costyet + (i + 1 + xdistance) * energyCost[
                  amphipodOrder.find room[i]],
              minCost
            )

  if not didSomeOperation:
    if isSolved burrow:
      minCost = costYet

func leastEnergy(burrow: Burrow, highway: Highway): int =
  result = int.high
  leastEnergyImpl(burrow, highway, 0, result)

# tests --------------------------------------

test "correctOrder":
  check:
    correctOrder(2 .. 5) == 2..5
    correctOrder(5 .. 2) == 2..5
    correctOrder(2 .. 5, 1) == 3..5
    correctOrder(5 .. 2, 1) == 2..4

test "isSolved":
  check:
    isSolved([ @[A, A, A], @[B, B, B], @[C, C, C], @[D, D, D]])
    not isSolved([ @[B, A], @[A, B], @[C, C], @[D, D]])

test "exportMember":
  check:
    exportMember(@[Empty, Empty], A) == (false, 0)
    exportMember(@[Empty, Empty, A], A) == (false, 0)
    exportMember(@[Empty, A, B], A) == (true, 1)
    exportMember(@[Empty, B, A], A) == (true, 1)
    exportMember(@[A, B, C], A) == (true, 0)

test "canEnterInRoom":
  check:
    canEnterInRoom(@[A, B], A) == (false, 0)
    canEnterInRoom(@[Empty, Empty, Empty], A) == (true, 3)
    canEnterInRoom(@[Empty, Empty, C], A) == (false, 0)

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
  test "1 steps left - 2x4":
    let d = """
      #############
      #.........A.#
      ###.#B#C#D###
        #A#B#C#D#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == 8

  test "2 steps left - 2x4":
    let d = """
      #############
      #...B.....A.#
      ###.#.#C#D###
        #A#B#C#D#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == 28

  test "3 steps left - 2x4":
    let d = """
      #############
      #.....D.D.A.#
      ###.#B#C#.###
        #A#B#C#.#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == (3 + 4) * 1000 + 8

  test "5 steps left - 2x4":
    let d = """
      #############
      #.....D.....#
      ###B#.#C#D###
        #A#B#C#A#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == 9011 + 40

  test "8 steps left - 2x4":
    let d = """
      #############
      #...B.......#
      ###B#C#.#D###
        #A#D#C#A#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == 12081 + 400

  test "1 steps left - 4x4":
    let d = """
      #############
      #..........D#
      ###A#B#C#.###
        #A#B#C#D#
        #A#B#C#D#
        #A#B#C#D#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == 3*1000

  test "2 steps left - 4x4":
    let d = """
      #############
      #.........AD#
      ###.#B#C#.###
        #A#B#C#D#
        #A#B#C#D#
        #A#B#C#D#
        #########
    """.strip.unindent(6).parseInput
    check leastEnergy(d.burrow, d.highway) == 3000 + 8

# go -----------------------------------------

let
  content = readFile("./input.txt")
  d1 = content.parseInput
  d2 = content.unfoldMap.parseInput

echo leastEnergy(d1.burrow, d1.highway) # 15358
echo leastEnergy(d2.burrow, d2.highway) #

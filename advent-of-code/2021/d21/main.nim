import std/[sequtils, strutils, strformat, unittest, math]

{.experimental: "strictFuncs".}

# def ----------------------------------------

type
  Pair = array[2, int]

const trackLimit = 10

func `+`(p1, p2: Pair): Pair =
  [p1[0] + p2[0], p1[1] + p2[1]]

# utils --------------------------------------

func parseStartingPosition(l: string): int =
  l.split(':')[1].strip.parseInt

# implement ----------------------------------

func applyLimit(n, limit: int): int =
  let m = n mod limit
  if m == 0: 10
  else: m

func test1(p1, p2, winScore, diceLimit: int): int =
  var
    scores = [0, 0]
    positions = [p1, p2]
    die = 1
    counter = 0

  block game:
    while true:
      for i, s in scores.mpairs:
        var m = 0

        for n in 0..2:
          m.inc die
          die = applyLimit(die + 1, diceLimit)
          counter.inc

        positions[i] = applyLimit(positions[i] + m, trackLimit)
        s += positions[i]

        if s >= winScore:
          break game

  scores.filterIt(it < winScore)[0] * counter

func test2Impl(
  scores, positions: array[2, int], universesBefore: int,
  winScore: int, result: var array[2, int]
) =
  for i, s in scores.pairs:
    if s >= winScore:
      result[i].inc universesBefore * 3
      return

  for sum1 in 3..9:
    for sum2 in 3..9:
      let
        newps = [
          applyLimit(positions[0] + sum1, trackLimit),
          applyLimit(positions[1] + sum2, trackLimit)
        ]
        newscs = scores + newps

      test2Impl(newscs, newps, universesBefore+1, winScore, result)

func test2(p1, p2, winScore: int): int =
  var wins = [0, 0]
  test2Impl([0, 0], [p1, p2], 0, winScore, wins)
  debugEcho wins
  max wins

# tests --------------------------------------

test "apply limit":
  check:
    applyLimit(11, 10) == 1
    applyLimit(10, 10) == 10
    applyLimit(20, 10) == 10

# go -----------------------------------------

let data = ("./test.txt").lines.toseq.map(parseStartingPosition)
echo test1(data[0], data[1], 1000, 100) # 412344
echo test2(data[0], data[1], 21) # i dont have mind to think what the hell the problem is

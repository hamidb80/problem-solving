import std/[strutils]

# def ----------------------------------------

type
  Toy = enum
    rock = 1
    paper = 2
    scissors = 3

  Result = enum
    lost = 0
    draw = 3
    win = 6

# utils --------------------------------------

template unexpected: untyped =
  raise newException(ValueError, "unexpected")

func toToy(ch: char): Toy =
  case ch:
  of 'A', 'X': rock
  of 'B', 'Y': paper
  of 'C', 'Z': scissors
  else: unexpected

func toResult(ch: char): Result =
  case ch:
  of 'X': lost
  of 'Y': draw
  of 'Z': win
  else: unexpected

func whatChooseToLose(opponent: Toy): Toy =
  case opponent
  of rock: scissors
  of scissors: paper
  of paper: rock

func whatChooseToWin(opponent: Toy): Toy =
  opponent.whatChooseToLose.whatChooseToLose

func matchResult(opponent, you: Toy): Result =
  if opponent == you: draw
  elif opponent.whatChooseToWin == you: win
  else: lost

func score(res: Result, you: Toy): int =
  res.int + you.int

# implement ----------------------------------

iterator rounds(data: string): (char, char) =
  for line in data.splitLines:
    yield (line[0], line[2])

func part1(data: string): int =
  for (o, y) in rounds data:
    let
      opponent = toToy o
      you = toToy y
      res = matchResult(opponent, you)

    result.inc score(res, you)

func part2(data: string): int =
  for (o, r) in rounds data:
    let
      opponent = toToy o
      res = toResult r
      you =
        case res
        of draw: opponent
        of win: whatChooseToWin opponent
        of lost: whatChooseToLose opponent

    result.inc score(res, you)

# go -----------------------------------------

let data = readFile("./input.txt")
echo part1 data # 12855
echo part2 data # 13726

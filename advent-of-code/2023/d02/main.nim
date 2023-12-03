import std/[sequtils, strutils]
import npeg

# def ----------------------------------------

type
  Game = object
    id: int
    sets: seq[GameSet]

  GameSet = object
    red, blue, green: int

# parser --------------------------------------

let gameParser = peg("game", g: Game):
  game <- "Game " * >number * init * gameSets:
    g.id = parseint $1

  init <- ": ":
    add g.sets, GameSet()

  word <- +Alpha
  number <- +Digit

  gameSets <- gameSet * *(gameSetSep * gameSet)
  gameSet <- pick * *(", " * pick)
  gameSetSep <- "; ":
    add g.sets, GameSet()

  pick <- >number * ' ' * >word:
    let number = parseInt $1

    case $2
    of "red":
      inc g.sets[^1].red, number
    of "blue":
      inc g.sets[^1].blue, number
    of "green":
      inc g.sets[^1].green, number
    else:
      assert false

func parseGame(line: string): Game =
  {.cast(nosideEffect).}:
    discard gameParser.match(line, result)

# utils ----------------------------------

func `<=`(a, b: GameSet): bool =
  a.red <= b.red and
  a.green <= b.green and
  a.blue <= b.blue

func max(a, b: GameSet): GameSet =
  GameSet(
    red: max(a.red, b.red),
    green: max(a.green, b.green),
    blue: max(a.blue, b.blue))

func power(gs: GameSet): int =
  gs.red * gs.green * gs.blue

# implement ----------------------------------

func part1(games: seq[Game]): int =
  let constraint = GameSet(red: 12, green: 13, blue: 14)
  for g in games:
    if g.sets.allIt(it <= constraint):
      inc result, g.id

func part2(games: seq[Game]): int =
  for g in games:
    inc result, power g.sets.foldl(max(a, b))

# go -----------------------------------------

let games = readFile"./input.txt".splitlines.map(parseGame)
echo part1 games #  2913
echo part2 games # 55593

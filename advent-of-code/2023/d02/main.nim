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

# implement ----------------------------------

func part1(games: seq[Game]): int =
  for g in games:
    if g.sets.allIt(it.red <= 12 and it.green <= 13 and it.blue <= 14):
      inc result, g.id


func max(a, b: GameSet): GameSet =
  GameSet(
    red: max(a.red, b.red),
    green: max(a.green, b.green),
    blue: max(a.blue, b.blue))

func innerProduct(gs: GameSet): int =
  gs.red * gs.green * gs.blue

func part2(games: seq[Game]): int =
  for g in games:
    inc result, innerProduct g.sets.foldl(max(a, b))

# go -----------------------------------------

let games = readFile"./input.txt".splitlines.map(parseGame)
echo part1 games #  2913
echo part2 games # 55593

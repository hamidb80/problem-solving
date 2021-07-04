import sugar, strutils, sequtils, tables, math
import print

# structuring data ---------------------------------

type
  Tile = object
    id: int
    # body: seq[string]
    edges: array[4, string]

const
  Up = 0
  Right = 1
  Bottom = 2
  Left = 3

# functionalities ------------------------------------

func thinkOfString(s: seq[char]): string =
  cast[string](s)

proc checkArrangement(tiles: var seq[Tile]): bool =
  var emwo: CountTable[int] # edge Matches With Others

  # FIXME what's going in man?
  for tile in tiles:
    let id = tile.id
    for edge in tile.edges:
      emwo.inc id, tiles.countIt it.id != id and edge in it.edges

  let
    size2 = 4                           # edges
    size3 = (int sqrt float tiles.len) * 4 - size2 # borders - edges
    size4 = tiles.len - (size2 + size3) # inner square

  for k, v in emwo:
    print (k, v)

  [
    emwo.getOrDefault 2,
    emwo.getOrDefault 3,
    emwo.getOrDefault 4
  ] == [size2, size3, size4]

# preparing data ------------------------------------

var tiles = collect newseq:
  for part in "./sample.txt".readFile.split "\c\n\c\n":
    let
      lines = part.splitLines
      body = lines[1..^1]

    Tile(
      id: lines[0]["Tile ".len..^2].parseInt,
      edges: [
        body[0], # up
        body.mapIt(it[^1]).thinkOfString, # right
        body[^1], # down
        body.mapIt(it[0]).thinkOfString # left
    ])

# code --------------------------------------------------

print tiles

block part1:
  echo checkArrangement tiles

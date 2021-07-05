import sugar, strutils, sequtils
import print

# structuring data ---------------------------------

type
  Tile* = object
    id*: int
    # body: seq[string]
    edges*: array[4, string]

const
  Top* = 0
  Right* = 1
  Bottom* = 2
  Left* = 3

# functionalities ------------------------------------

func thinkOfString*(s: seq[char]): string =
  cast[string](s)

func reversed*(s:string): string=
  for ci in countdown(s.high, 0):
    result.add s[ci]
#[
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
]#

func flippedVertical*(tile: Tile): Tile=
    Tile(
      id: tile.id,
      edges: [
        tile.edges[Top].reversed,
        tile.edges[Left],
        tile.edges[Bottom].reversed,
        tile.edges[Right]
    ])

func flippedHorizontal*(tile: Tile): Tile=
  Tile(
      id: tile.id,
      edges: [
        tile.edges[Bottom],
        tile.edges[Right].reversed,
        tile.edges[Top],
        tile.edges[Left].reversed,
    ])

func rotatedRight*(tile: Tile): Tile=
  Tile(
      id: tile.id,
      edges: [
        tile.edges[Left].reversed,
        tile.edges[Top],
        tile.edges[Right].reversed,
        tile.edges[Bottom],
    ])

func rotatedLeft*(tile: Tile): Tile=
  Tile(
      id: tile.id,
      edges: [
        tile.edges[Right],
        tile.edges[Bottom].reversed,
        tile.edges[Left],
        tile.edges[Top].reversed,
    ])

let transforms*: seq[tuple[
  fns: seq[proc(t: Tile): Tile{.nimcall.}], 
  name: string]] = @[
    (@[flippedVertical], "flip vertical"),
    (@[flippedHorizontal], "flip horizontal"),
    (@[rotatedRight], "rotate right"),
    (@[rotatedLeft], "rotate left"),
    (@[rotatedRight, rotatedRight], "multi"),
  ]

# preparing data ------------------------------------

when isMainModule:
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
    discard
import sugar, strutils, sequtils
import print

# structuring data ---------------------------------

type
  Tile* = object
    id*: int
    # body: seq[string]
    edges*: array[4, string]
  
  TransformFunction* = proc(t: Tile): Tile {.nimcall.}
  Transform* = tuple
    fns: seq[TransformFunction]
    name: string

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

let 
  transforms*: seq[Transform] = @[
    (@[], "nothing"),
    (@[flippedVertical], "flip vertical"),
    (@[flippedHorizontal], "flip horizontal"),
    (@[rotatedRight], "rotate right"),
    (@[rotatedLeft], "rotate left"),
    (@[rotatedRight, rotatedRight], "multi"),
  ]

  noTransform* = transforms[0]
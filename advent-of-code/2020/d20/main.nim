import sugar, strutils, sequtils
import print

{.experimental: "views".}

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

func thinkOfString(s: seq[char]): string=
  cast[string](s)

proc checkArrangement(tiles:var seq[Tile]): bool=
  let edgeMatchesWithOthers = tiles.mapIt do:
    let id = it.id
    var s = 0
    for edge in it.edges:
      s += tiles.countIt it.id != id and edge in it.edges
    s

  print edgeMatchesWithOthers
  

# preparing data ------------------------------------

var tiles = collect newseq:
  for part in "./sample.txt".readFile.split "\c\n\c\n":
    let 
      lines = part.splitLines
      body = lines.toOpenArray(1, lines.high)
    
    Tile(
      id: lines[0]["Tile ".len..^2].parseInt,
      edges: [
        body[0], # up
        body.mapIt(it[^1]).thinkOfString, # right
        body[^1], # down
        body.mapIt(it[0]).thinkOfString # left
      ]
    )
    
# code --------------------------------------------------

print tiles

block part1:
  echo checkArrangement tiles

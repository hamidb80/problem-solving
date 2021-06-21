import sequtils, strutils

# functionalities -------------------------------------

template findIndexes(s: typed, pred: untyped): seq[int] =
  var result: seq[int]

  for i in 0..<s.len:
    let it {.inject.} = s[i]
    if pred:
      result.add i

  result

func wouldBeEncounter(line: seq[int], lineWidth, xpos: int): bool =
  line.anyIt it == xpos mod lineWidth

func walkOnMap(map: seq[seq[int]], lineWidth, ystep, xstep: int): int =
  var (y, x) = (ystep, xstep)

  while y < map.len:
    if wouldBeEncounter(map[y], lineWidth, x):
      result.inc

    inc y, ystep
    inc x, xstep

# code --------------------------------------------------

let
  lines = "./input.txt".readFile.splitLines
  lineWidth = lines[0].len
  map = lines.mapIt it.findIndexes it == '#'

block part1:
  echo walkOnMap(map, lineWidth, 1, 3)

block part2:
  type Walk = tuple[xstep, ystep: int]
  const walks: seq[Walk] = @[
    (1, 1),
    (3, 1),
    (5, 1),
    (7, 1),
    (1, 2),
  ]

  echo (walks.mapIt walkOnMap(map, lineWidth, it.ystep, it.xstep)).foldl(a * b)

import sugar, strutils, sequtils, tables, strformat, math
import main, print

type
  Relation = object
    fromSide, toSide, fromId, toId: int

  TransformFunction = proc(t: Tile): Tile {.nimcall.}
  TilesLookup = Table[int, Tile]

func `$`(rel: Relation): string =
  fmt"{rel.fromSide}{rel.toSide} -> {rel.toId}"

proc haveIntersect(t1, t2: Tile): bool=
  for ie1, e1 in t1.edges:
    for ie2, e2 in t2.edges:
      if e1 == e2:
        return true

template insertOrAdd[K, T](t:Table[K, seq[T]], key: K, val: T):untyped =
  if t.hasKey key:
    t[key].add val
  else:
    t[key] = @[val]


proc applyTransform(t: Tile, fns: seq[TransformFunction]): Tile =
  result = t
  for fn in fns:
    result = result.fn

# preparing data -------------------------------------------------
var tiles = collect initTable:
  for part in "./input.txt".readFile.split "\c\n\c\n":
    let
      lines = part.splitLines
      body = lines[1..^1]
      id = lines[0]["Tile ".len..^2].parseInt

    {id: Tile(
      id: id,
      edges: [
        body[0], # up
        body.mapIt(it[^1]).thinkOfString, # right
        body[^1], # down
        body.mapIt(it[0]).thinkOfString # left
    ])}

# code -------------------------------------------------------
var 
  verticesRel: Table[int, seq[int]]
  trs = transforms
trs.insert (@[], "nothing"), 0

block part1:
  for id1, t1 in tiles:
    var c = 0
    for id2, t2 in tiles:
      for tr in trs:
        if id1 == id2: continue
        if t1.haveIntersect t2.applyTransform tr.fns:
          c.inc
          break

    verticesRel.insertOrAdd c, id1

  echo verticesRel[2].foldl a * b

block part2:
  for k,v in verticesRel:
    echo (k, v.len)
  
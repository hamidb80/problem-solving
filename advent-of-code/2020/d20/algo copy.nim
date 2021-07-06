import sugar, strutils, sequtils, tables, strformat, math
import main, print

type
  Relation = object
    fromSide, toSide, fromId, toId: int

  TilesLookup = Table[int, Tile]

template insertOrAdd[K, T](t:Table[K, seq[T]], key: K, val: T):untyped =
  if t.hasKey key:
    t[c].add val
  else:
    t[c] = @[val]

func `$`(rel: Relation): string =
  fmt"{rel.fromSide}{rel.toSide} -> {rel.toId}"

proc applyTransform(t: Tile, fns: seq[TransformFunction]): Tile =
  result = t
  for fn in fns:
    result = result.fn

proc haveIntersect(t1, t2: Tile): bool=
  for ie1, e1 in t1.edges:
    for ie2, e2 in t2.edges:
      if e1 == e2:
        return true

proc areSomehowConnected(t1, t2: Tile, trs: seq[Transform]): bool=
  for tr in trs:
    if t1.haveIntersect t2.applyTransform tr.fns:
      return true

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
var verticesRel: Table[int, seq[int]]
var trs = transforms
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

    if verticesRel.hasKey c:
      verticesRel[c].add id1
    else:
      verticesRel[c] = @[id1]

  echo verticesRel[2].foldl a * b
  
block part2:
  let size = int sqrt tiles.len.float

  var cc: Table[int, seq[int]]
  for vid in verticesRel[2]:
    var selectedId = vid
    for _ in 1..10:
      for node3Id in verticesRel[3]:
        if tiles[selectedId].areSomehowConnected(tiles[node3Id], trs):
          selectedId = node3Id
          cc.inc vid
          break
    
    for ovid in verticesRel[2]:
      if tiles[selectedId].areSomehowConnected(tiles[ovid], trs):

      
    echo (vid, cc[vid])
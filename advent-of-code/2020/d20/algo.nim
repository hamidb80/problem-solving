import sugar, strutils, sequtils, tables, strformat, math
import main, print

type
  Relation = object
    fromSide, toSide, fromId, toId: int
  
  TilesLookup = Table[int, Tile]
  
  Chain = tuple
    start: int
    middle: seq[int]
    `end`: int
    

func `$`(rel: Relation): string =
  fmt"{rel.fromSide}{rel.toSide} -> {rel.toId}"

converter isRel(rel: Relation): bool=
  rel.fromid != 0

func getRelaltion(t1, t2: Tile): Relation=
  for ie1, e1 in t1.edges:
    for ie2, e2 in t2.edges:
      if e1 == e2:
        return Relation(
          fromside: ie1, 
          toSide: ie2, 
          fromId: t1.id, 
          toId: t2.id)

func haveIntersect(t1, t2: Tile): bool {.inline.}=
  getRelaltion(t1, t2)

template insertOrAdd[K, T](t: var Table[K, seq[T]], key: K, val: T):untyped =
  if t.hasKey key:
    t[key].add val
  else:
    t[key] = @[val]

proc applyTransform(t: Tile, fns: seq[TransformFunction]): Tile =
  result = t
  for fn in fns:
    result = result.fn

proc areSomehowConnected(t1, t2: Tile, trs: seq[Transform]): bool=
  for tr in trs:
    let newt2 = t2.applyTransform tr.fns
    if t1.haveIntersect newt2:
      return true

func transform2match(fromSide, toSide: int): seq[TransformFunction] =
  ## returns a set of transformation functions to make seconds tile matchable with first one
  ## if they could match without any transformation, an empty seq returns
  [
    [ # Top
      @[flippedHorizontal], # -> # Top
      @[rotatedRight], # -> # Right
      @[], # -> # Bottom
      @[rotatedLeft], # -> # Left
    ],
    [ # Right
      @[rotatedLeft], # -> # Top
      @[flippedVertical], # -> # Right
      @[rotatedRight], # -> # Bottom
      @[], # -> # Left
    ],
    [ # Bottom
      @[], # -> # Top
      @[rotatedLeft], # -> # Right
      @[flippedHorizontal], # -> # Bottom
      @[rotatedRight], # -> # Left
    ],
    [ # Left
      @[rotatedRight], # -> # Top
      @[], # -> # Right
      @[rotatedLeft], # -> # Bottom
      @[flippedVertical], # -> # Left
    ]
  ][fromSide][toSide]

# template transformHook(t1, t2: untyped, trs: seq[Transform]): untyped =
  
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

block part1:
  for id1, t1 in tiles:
    var c = 0
    for id2, t2 in tiles:
      for tr in transforms:
        if id1 == id2: continue
        if t1.haveIntersect t2.applyTransform tr.fns:
          c.inc
          break

    verticesRel.insertOrAdd c, id1
  echo verticesRel[2].foldl a * b

block part2:
  for k,v in verticesRel:
    echo (k, v.len)

  var 
    size = int sqrt tiles.len.float # table width & height
    cc: Table[int, seq[int]]
    chains: seq[Chain]
  
  for vid in verticesRel[2]: # vid: vectex id
    var selectedIds = @[vid]
    for _ in 1..size-2: # do it until end of the edge
      for node3Id in verticesRel[3]: # looking for chains
        if node3Id in selectedIds: continue
        if tiles[selectedIds[^1]].areSomehowConnected(tiles[node3Id], transforms):
          selectedIds.add node3Id
          cc.insertOrAdd vid, node3Id
          break # stop looking for more maches for previous id
    
    # find the another edge to complete the edge
    for ovid in verticesRel[2]: # ovid: other vectex id
      if ovid == vid: continue
      if tiles[selectedIds[^1]].areSomehowConnected(tiles[ovid], transforms):

        cc[vid].add ovid

    chains.add (vid, cc[vid][0..^2],cc[vid][^1])

  for ch in chains:
    echo ch

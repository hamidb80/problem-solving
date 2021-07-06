import sugar, strutils, sequtils, tables, strformat, math, options
import main, print

type
  Relation = object
    fromSide, toSide, fromId, toId: int

  # TilesLookup = Table[int, Tile]

  Chain = tuple
    head: int
    middle: seq[int]
    tail: int

func `$`(rel: Relation): string =
  fmt"{rel.fromSide}{rel.toSide} -> {rel.toId}"

template findIt(s: typed, pred: untyped): untyped =
  var res = none typeof s[0]
  for it{.inject.} in s:
    if pred:
      res = some it
      break
  res

func getRelation(t1, t2: Tile): Option[Relation] =
  for ie1, e1 in t1.edges:
    for ie2, e2 in t2.edges:
      if e1 == e2:
        return some Relation(
          fromside: ie1,
          toSide: ie2,
          fromId: t1.id,
          toId: t2.id)

func haveRelation(t1, t2: Tile): bool {.inline.} =
  getRelation(t1, t2).isSome

template insertOrAdd[K, T](t: var Table[K, seq[T]], key: K, val: T): untyped =
  if t.hasKey key:
    t[key].add val
  else:
    t[key] = @[val]

proc applyTransform(t: Tile, fns: seq[TransformFunction]): Tile =
  result = t
  for fn in fns:
    result = result.fn

proc findWayToConnect(t1, t2: Tile, trfs: seq[Transform]): Option[seq[TransformFunction]] =
  for trf in trfs:
    let newt2 = t2.applyTransform trf.fns
    if t1.haveRelation newt2:
      return some trf.fns

proc areConnected(t1, t2: Tile, trfs: seq[Transform]): bool =
  for trf in trfs:
    let newt2 = t2.applyTransform trf.fns
    if t1.haveRelation newt2:
      return true

proc areConnected(t: Tile, ts: openArray[Tile], trfs: seq[Transform]): bool =
  ts.allIt t.areConnected(it, trfs)

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
        body[0], # up # FIXME nimpretty bug
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
        if t1.haveRelation t2.applyTransform tr.fns:
          c.inc
          break

    verticesRel.insertOrAdd c, id1
  echo verticesRel[2].foldl a * b

block part2:
  var
    size = int sqrt tiles.len.float # table width & height
    cc: Table[int, seq[int]]
    chains: seq[Chain]

  var selectedIds: seq[int]

  # find the border
  for vid in verticesRel[2]: # vid: vectex id
    selectedIds.add vid
    for _ in 1..size-2: # do it until end of the edge
      for node3Id in verticesRel[3]: # looking for chains
        if node3Id in selectedIds: continue
        let trfs = tiles[selectedIds[^1]].findWayToConnect(tiles[node3Id], transforms)
        if trfs.isSome:
          # transform to make seconds element compatible if they have unusual relation
          tiles[node3Id] = tiles[node3Id].applyTransform trfs.get

          selectedIds.add node3Id
          cc.insertOrAdd vid, node3Id
          break # stop looking for more maches for previous id
    
    # find the another edge to complete the edge
    for ovid in verticesRel[2]: # ovid: other vectex id
      if ovid == vid: continue
      if tiles[selectedIds[^1]].areConnected(tiles[ovid], transforms):
        cc[vid].add ovid

    chains.add (vid, cc[vid][0..^2], cc[vid][^1])

  # fill inside the square [image]`
  for edgeLen in countdown(size-4, 2, 2):
    for edgeNum in 1..4:

      let mainChain = chains[^4]
      var headChain = (chains.findIt it.tail == mainChain.head).get

      # the first element
      let head = (verticesRel[4].findIt tiles[it].areConnected([
          tiles[mainChain.middle[0]],
          tiles[headChain.middle[^1]],
        ], transforms)).get

      selectedIds.add head
      let middle = collect newseq:
        for progress in 1..edgeLen:
          for ovid in verticesRel[4]:
            if ovid in [selectedIds[^1], mainChain.middle[progress]]: continue
            if tiles[ovid].areConnected([
                tiles[selectedIds[^1]],
                tiles[mainChain.middle[progress]],
              ], transforms):
                
              # TODO also rearrange it
                # let rel = getRelation(tiles[ovid], tiles[selectedIds[^1]])
                # if rel.haveRelation:

                echo (progress, edgeLen, edgeNum, ovid, head)
                selectedIds.add ovid
                ovid

      let
        tailChain = (chains.findIt it.head == mainChain.tail).get # find other corner

      print headChain
      print mainChain
      print tailChain
      print head, middle
      print chains

      let
        tail = (verticesRel[4].findIt tiles[it].areConnected([
          tiles[middle[^1]], # TODO give me error?
          tiles[mainChain.middle[^1]],
          tiles[tailChain.middle[0]],
        ], @[noTransform])).get

      chains.add (head, middle, tail)

    # break
    # if edgeLen == 6:
    #   break

  echo "============"
  for ch in chains:
    echo ch

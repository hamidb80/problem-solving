import sugar, strutils, sequtils, tables, strformat, math, options
import main
import print

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

func findWayToConnect(t1, t2: Tile, trfs: seq[Transform] = noTransform): Option[Transform] =
  for trf in trfs:
    if (t1.applyTransform trf.fns).haveRelation t2:
      return some trf

func findWayToConnect(t1:Tile, ts: seq[Tile], trfs: seq[Transform] = noTransform): Option[Transform] =
  for trf in trfs:
    if ts.allit (t1.applyTransform trf.fns).haveRelation it:
      return some trf

func areConnected(t1, t2: Tile, trfs: seq[Transform] = noTransform): bool =
  ## is it possible to match t1 with some transforms to t2?
  trfs.anyIt (t1.applyTransform it.fns).haveRelation t2

proc areConnected(t: Tile, ts: openArray[Tile], trfs: seq[Transform] = noTransform): bool =
  ## is it possible to match t1 with some transforms to all of ts?
  trfs.anyIt:
    let trf = @[it]
    ts.allIt t.areConnected(it, trf)

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

func intsqrt(n: int): int=
  int sqrt n.float

proc relationScanner(flatChain: seq[int], tiles: var Table[int, Tile]): bool=
  result = true
  for i in 0..<flatChain.high:
    if not tiles[flatChain[i]].areConnected(tiles[flatChain[i+1]]):
      debugecho flatChain[i..i+1]
      return false

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
    size = intsqrt tiles.len # table width & height
    ea2rv: Table[int, seq[int]] # edges According To 2 Rel Vertex
    chains: seq[Chain]

  # find the border
  var selectedIds: seq[int]
  for vid in verticesRel[2]: # vid: vectex id
    selectedIds.add vid
    for _ in 1..size-2: # do it until end of the edge
      for ovid in verticesRel[3]: # looking for chains
        if ovid in selectedIds: continue
        # FIXME only attach to the left side of the current tile
        let way = tiles[ovid].findWayToConnect(tiles[selectedIds[^1]], transforms)
        if way.isSome:
          # transform to make seconds element compatible if they have unusual relation
          tiles[ovid] = tiles[ovid].applyTransform way.get.fns
          
          selectedIds.add ovid
          ea2rv.insertOrAdd vid, ovid
          break # stop looking for more maches for previous id
    
    # find the tail vertex to complete the edge
    for ovid in verticesRel[2]: # ovid: other vectex id
      if ovid == vid: continue
      let way = tiles[ovid].findWayToConnect(tiles[selectedIds[^1]], transforms)
      if way.isSome:
        tiles[ovid] = tiles[ovid].applyTransform way.get.fns
        ea2rv[vid].add ovid # store tail vertedx as last item of seq

    chains.add (vid, ea2rv[vid][0..^2], ea2rv[vid][^1])
  
  # transform edges to create a square
  # for chi1 in 0..chains.high:
  #   for chi2 in 0..chains.high:
  #     if chi1 == chi2: continue
  #     if chains[chi1].tail == chains[chi2].head: # select every corner
  #       let rel = getRelation(tiles[chains[chi1].tail], tiles[chains[chi2].head]).get
  #       print rel

  #[ 
    print chains
    # let flatChain = block:
    #   var 
    #     res: seq[int]
    #     currentChain  = chains[0]
      
    #   for i in 1..4:
    #     res.add currentChain.head
    #     res.add currentChain.middle
    #     currentChain = chains.findIt(it.head == currentChain.tail).get
    #   res

    # echo flatChain, flatChain.len
    # echo "scan1 ", relationScanner(flatChain, tiles)
  ]#

  # fill inside the square [image]
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
            let way = tiles[ovid].findWayToConnect(@[
                tiles[selectedIds[^1]],
                tiles[mainChain.middle[progress]],
              ], transforms)

            if way.isSome:
              # echo "middle", (progress, edgeLen, edgeNum, ovid, head)
              tiles[ovid] = tiles[ovid].applyTransform way.get.fns
              selectedIds.add ovid
              ovid

      let tailChain = (chains.findIt it.head == mainChain.tail).get # find other corner

      let tail = block:
        var res: int
      
        for ovid in verticesRel[4]:
          let way = tiles[ovid].findWayToConnect(@[
              tiles[middle[^1]],
              tiles[mainChain.middle[^1]],
              tiles[tailChain.middle[0]],
            ], transforms)

          if way.isSome:
            tiles[ovid] = tiles[ovid].applyTransform way.get.fns
            res = ovid
            break
        
        if res == 0: 
          print headChain
          print mainChain
          print tailChain
          print head, middle
          print chains
          echo "scanned: ", relationScanner(@[head] & middle, tiles)
          raise newException(ValueError, "not found a tail")
        res

      chains.add (head, middle, tail)

  echo "============"
  for ch in chains:
    echo ch

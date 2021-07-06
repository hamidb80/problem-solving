import main, sugar, strutils, sequtils, math, tables, strformat, sets
import print, terminaltables

type
  Relation = object
    fromSide, toSide, fromId, toId: int

  TransformFunction = proc(t: Tile): Tile {.nimcall.}
  TilesLookup = Table[int, Tile]

func `$`(rel: Relation): string =
  fmt"{rel.fromSide}{rel.toSide} -> {rel.toId}"

func findRelations(tile: Tile, lookupTiles: var TilesLookup): seq[Relation] =
  for id, t in lookupTiles:
    if t.id == tile.id: continue

    for ie1, e1 in tile.edges:
      for ie2, e2 in t.edges:
        if e1 == e2:
          result.add Relation(fromSide: ie1, toSide: ie2, fromId: tile.id, toId: t.id)

func countRels(tiles: var TilesLookup): CountTable[int] = 
  for id, t in tiles:
    result.inc (t.findRelations tiles).len

proc applyTransform(t: Tile, fns: seq[TransformFunction]): Tile =
  result = t
  for fn in fns:
    result = result.fn

proc drawTable(lookupTiles: var TilesLookup) =
  let mytable = newUnicodeTable()
  mytable.setHeaders @[
    "id",
    "Top",
    "Right",
    "Bottom",
    "Left",
    "Relation",
  ].mapIt it.newCell

  for id, t in lookupTiles:
    let relations = findRelations(t, lookupTiles).mapIt $it
    mytable.addRow @[$id] & t.edges.toseq & relations.join ", "

  printTable mytable

proc showAllTransforms(t: Tile, lookupTiles: var TilesLookup) =
  let mytable = newUnicodeTable()
  mytable.setHeaders @[
    "id",
    "transformation",
    "Top",
    "Right",
    "Bottom",
    "Left",
    "Relations"
  ].mapIt it.newcell

  for tr in transforms:
    let newt = applyTransform(t, tr.fns)
    mytable.addRow @[$newt.id, tr.name] & newt.edges.toseq & (
        newt.findRelations lookupTiles).join", "

  printTable mytable

template report =
  echo "reports::: "
  for key, v in countRels tiles:
    echo key, ":", v

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

func isBrokenRelation(rel: Relation): bool =
  abs(rel.fromSide - rel.toSide) != 2

proc fixBrokenRelations(id: int, tiles: var TilesLookup) =
  let tile = tiles[id]

  for rel in findRelations(tile, tiles):
    let trs = transform2match(rel.fromSide, rel.toSide)
    if trs.len == 0: continue # if it wasn't a broken relation
    # echo rel
    tiles[rel.toId] = tiles[rel.toId].applyTransform trs
    fixBrokenRelations rel.toId, tiles

proc fixBrokenRelations(tiles: var TilesLookup) =
  for id in tiles.keys:
    fixBrokenRelations id, tiles

func findUnusuals(tiles: var TilesLookup): seq[string]=
  for id, t in tiles:
    let urel = t.findRelations(tiles).filterIt it.isBrokenRelation
    if urel.len > 0:
      result.add fmt"{id} :: {urel}"

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

# code -----------------------------------------------------------
template rearrange=
  # transform tiles that have less than 2 relations
  var shouldContinue = false
  while true:
    for id, tile in tiles:
      # showAllTransforms tile, tiles
      if tile.findRelations(tiles).len >= 2: continue
      shouldContinue = true

      let 
        relations = transforms.mapIt (tile.applyTransform it.fns).findRelations(tiles).len
        mxi = relations.maxIndex

      tiles[id] = tile.applyTransform transforms[mxi].fns

    if shouldContinue: 
      shouldContinue = false
    else: break

  # see if it is possible to transform some tiles to get more relations?
  for id, tile in tiles:
    let beforeRels = tile.findRelations(tiles).len
    if beforeRels == 4: continue

    let 
      relations = transforms.mapIt (tile.applyTransform it.fns).findRelations(tiles).len
      mxi = relations.maxIndex

    if relations[mxi] > beforeRels:
      # echo (id, transforms[mxi].name, beforeRels, relations[mxi])
      tiles[id] = tile.applyTransform transforms[mxi].fns

# rearrange
# fixBrokenRelations tiles

drawTable tiles

# echo "---------------\n".repeat 2
# echo "unusuals: ", findUnusuals(tiles).join "\n"
# report


# let res = (tiles.keys.toseq.filterIt (tiles[it].findRelations tiles).len == 2)
# echo res.foldl a * b
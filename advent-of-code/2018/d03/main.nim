# imports --------------------------

import std/[
    strutils,
    sequtils,
    strscans]

# data types -----------------------

const mapSize = 1000

type
    Map =
        array[mapSize,
            array[mapSize, int]]

    Vec2 = object
        x, y: int

    Size = object
        w, h: int # width and height

    Claim = object
        id: int
        position: Vec2
        size: Size

    Area = object
        xs, ys: Slice[int]

# parse input -------------------

func parseClaim(s: string): Claim =
    # "#26 @ 199,207: 14x14"
    discard scanf(s,
        "#$i @ $i,$i: $ix$i",
        result.id,
        result.position.x,
        result.position.y,
        result.size.w,
        result.size.h)

func parseInput(s: string): seq[Claim] =
    for line in splitLines s:
        add result, parseClaim line

# helpers -------------------------------

func area(c: Claim): Area =
    Area(
        xs: c.position.x .. c.position.x + c.size.w - 1,
        ys: c.position.y .. c.position.y + c.size.h - 1)


func overlaps(a, b: Slice[int]): bool =
    b.a in a or
    b.b in a or
    a.a in b or
    a.b in b

func overlaps(a, b: Area): bool =
    overlaps(a.xs, b.xs) and
    overlaps(a.ys, b.ys)

func overlaps(a, b: Claim): bool =
    a.id != b.id and
    overlaps(area a, area b)


func fill(map: var Map, c: Claim) =
    let a = area c
    for x in a.xs:
        for y in a.ys:
            inc map[x][y]

func buildMap(claims: seq[Claim]): Map =
    for c in claims:
        fill result, c

# main ---------------------------------

func part1(claims: seq[Claim]): int =
    let
        map = buildMap claims
        limit = 0..<mapSize
    for x in limit:
        for y in limit:
            if 1 < map[x][y]:
                inc result

func part2(claims: seq[Claim]): int =
    for c in claims:
        if not anyIt(claims, overlaps(c, it)):
            return c.id

# go ---------------------------------

when isMainModule:
    let data = parseInput readFile "input.txt"
    echo part1 data
    echo part2 data

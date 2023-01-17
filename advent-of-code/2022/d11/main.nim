import std/[strutils, sequtils, unittest]
import astar

# def ----------------------------------------

type
    Point = tuple
        x: int
        y: int

    Grid = object
        width: int
        data: seq[char]
        travel: Slice[Point]

# utils --------------------------------------

func pos(i, width: int): Point =
    (i mod width, i div width)

func `+`(p1, p2: Point): Point =
    (p1.x + p2.x, p1.y + p2.y)

func `-`(p: Point): Point =
    (-p.x, -p.y)

func `-`(p1, p2: Point): Point =
    p1 + -p2

func `[]`(g: Grid, x, y: int): char =
    g.data[g.width * y + x]

func `[]`(g: Grid, p: Point): char =
    g.data[p.y * g.width + p.x]

func height(g: Grid): int =
    g.data.len div g.width

func contains(g: Grid, p: Point): bool =
    (p.y in 0 ..< g.height) and (p.x in 0 ..< g.width)

iterator neighbors*(g: Grid, pin: Point): Point =
    for adj in [(0, 1), (0, -1), (+1, 0), (-1, 0)]:
        let dest = adj+pin
        if (dest in g) and (g[pin] == 'S' or (g[dest].ord - g[pin].ord) <= 1):
            yield dest

proc cost*(grid: Grid, a, b: Point): int =
    # abs(grid[a.x, a.y].ord - grid[b.x, b.y].ord)
    if grid[b] == 'E': ('z'.ord - grid[a].ord) * 100
    # else: grid[b].ord - grid[a].ord
    else: 1


proc heuristic*(grid: Grid, node, goal: Point): int =
    manhattan[Point, int](node, goal)

# implement ----------------------------------

func toGrid(data: string): Grid =
    let w = data.find('\n') - 1
    result.width = w

    for ch in data:
        let i = result.data.len
        case ch
        of 'a'..'z', 'S', 'E':
            result.data.add ch
            case ch
            of 'S': result.travel.a = pos(i, w)
            of 'E': result.travel.b = pos(i, w)
            else: discard
        else: discard

func `$`(g: Grid): string =
    for y in 0..<g.height:
        for x in 0..<g.width:
            result.add g[x, y]
        result.add '\n'
    result.add $g.travel
    result.add '\n'
    result.add $(g.data.len, g.width)

func journey(sp: seq[Point], goal: Point): string =
    let
        mx = sp.mapIt(it.x).max
        my = sp.mapIt(it.y).max
        w = mx+1

    for y in 0..my:
        for x in 0..mx:
            result.add '.'
        result.add '\n'

    template index(x, y): untyped =
        x + y * (w+1)


    result[index(sp[0].x, sp[0].y)] = 'S'
    result[index(sp[^1].x, sp[^1].y)] = 'E'

    var prev = sp[0]
    for i in 1..sp.high:
        let p = sp[i]
        let ch =
            if p - prev == (+1, 0): '>'
            elif p - prev == (-1, 0): '<'
            elif p - prev == (0, -1): '^'
            elif p - prev == (0, +1): 'v'
            else: raise newException(ValueError, "invalid" & $(p, prev))

        result[index(prev.x, prev.y)] = ch
        prev = p


proc test(g: Grid): int =
    let
        s = g.travel.a
        e = g.travel.b

    echo g
    let path = toseq path[Grid, Point, int](g, s, e)
    echo journey(path, e)
    path.len - 1

# go -----------------------------------------

let data = "./input.txt".readFile.toGrid 
echo data.test # doesnt work

import std/[strutils]
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
        if g[dest] <= g[pin]:
            yield (dest+pin)

proc cost*(grid: Grid, a, b: Point): int =
    grid[a.x, a.y].ord

proc heuristic*(grid: Grid, node, goal: Point): int =
    manhattan[Point, int](node, goal)

# implement ----------------------------------

func toGrid(data: string): Grid =
    let w = data.find('\n') - 1
    result.width = w

    for i, ch in data:
        case ch
        of 'S':
            result.travel.a = pos(i, w)

        of 'E':
            result.travel.b = pos(i, w)

        of 'a'..'z':
            result.data.add ch

        else:
            discard

func test(g: Grid): int =
    discard

# tests --------------------------------------

let
    data = "./test.txt".readFile.toGrid
    s = data.travel.a
    e = data.travel.b
    minPath = path[Grid, Point, int](data, s, e) # Error: internal error: proc has no result symbol

# echo minPath
echo data

# go -----------------------------------------

# let data = "./input.txt".readFile.toGrid
# echo test(data)

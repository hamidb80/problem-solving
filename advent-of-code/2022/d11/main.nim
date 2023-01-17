import std/[strutils, unittest, hashes]
import astar

# def ----------------------------------------

type
    Point = tuple
        x: int
        y: int

    Grid = object
        width: int
        data: seq[char]
        directPath: Slice[Point]


# A sample grid. Each number represents the cost of moving to that space

# let start: Point = (x: 0, y: 3)
# let goal: Point = (x: 4, y: 3)

# # Pass in the start and end points and iterate over the results.
# for point in path[Grid, Point, float](grid, start, goal):
#   echo point


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

proc cost*(grid: Grid, a, b: Point): float =
    grid[a.x, a.y].ord.toFloat

proc heuristic*(grid: Grid, node, goal: Point): float =
    ## Returns the priority of inspecting the given node
    asTheCrowFlies(node, goal)

# utils --------------------------------------


# implement ----------------------------------

func toGrid(data: string): Grid =
    result.width = data.find('\n') - 1
    for ch in data:
        if ch != '\n':
            result.data.add ch

func test(g: Grid): int =
    discard

# tests --------------------------------------

test "":
    let data = "./test.txt".readFile.toGrid

    # Pass in the start and end points and iterate over the results.
    for point in path[seq[char], Point, float](grid, goal):
        echo point


# go -----------------------------------------

let data = "./input.txt".readFile.toGrid
echo test(data)

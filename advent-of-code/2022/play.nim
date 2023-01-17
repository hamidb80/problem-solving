import astar, hashes

type
    Grid = seq[seq[int]]
        ## A matrix of nodes. Each cell is the cost of moving to that node

    Point = tuple[x, y: int]
        ## A point within that grid

template yieldIfExists( grid: Grid, point: Point ) =
    ## Checks if a point exists within a grid, then calls yield it if it does
    let exists =
        point.y >= 0 and point.y < grid.len and
        point.x >= 0 and point.x < grid[point.y].len
    if exists:
        yield point

iterator neighbors*( grid: Grid, point: Point ): Point =
    ## An iterator that yields the neighbors of a given point
    yieldIfExists( grid, (x: point.x - 1, y: point.y) )
    yieldIfExists( grid, (x: point.x + 1, y: point.y) )
    yieldIfExists( grid, (x: point.x, y: point.y - 1) )
    yieldIfExists( grid, (x: point.x, y: point.y + 1) )

proc cost*(grid: Grid, a, b: Point): float =
    ## Returns the cost of moving from point `a` to point `b`
    float(grid[a.y][a.x])

proc heuristic*( grid: Grid, node, goal: Point ): float =
    ## Returns the priority of inspecting the given node
    asTheCrowFlies(node, goal)

# A sample grid. Each number represents the cost of moving to that space
let grid = @[
    @[ 0, 0, 0, 0, 0 ],
    @[ 0, 3, 3, 3, 0 ],
    @[ 0, 3, 5, 3, 0 ],
    @[ 0, 3, 3, 3, 0 ],
    @[ 0, 0, 0, 0, 0 ]
]

let start: Point = (x: 0, y: 3)
let goal: Point = (x: 4, y: 3)

# Pass in the start and end points and iterate over the results.
for point in path[Grid, Point, float](grid, start, goal):
    echo point
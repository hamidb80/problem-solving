import sugar, sequtils, strformat
import print
# data types ----------------------------------------

const
  NotFound = -1 # for `find` function
  X = 0
  Y = 1
  Z = 2
  W = 3

type
  HyperPoint = array[4, int]
  Hyper = array[4, HSlice[int, int]]

func getSpaceSize(points: seq[HyperPoint]): Hyper =
  let
    xs = points.mapIt it[X]
    ys = points.mapIt it[Y]
    zs = points.mapIt it[Z]
    ws = points.mapIt it[W]

  [
    (min xs)..(max xs),
    (min ys)..(max ys),
    (min zs)..(max zs),
    (min ws)..(max ws)
  ]

func `+`(p1, p2: HyperPoint): HyperPoint =
  for i in 0..<4:
    result[i] = p1[i] + p2[i]

# functionalities ----------------------------------------

func expand(rng: HSlice[int, int], by: int): HSlice[int, int] =
  (rng.a - by)..(rng.b + by)

proc printSpace(points: seq[HyperPoint]) =
  ## for debuging purposes only
  let space = getSpaceSize points

  for w in space[W]:
    for z in space[Z]:
      echo fmt"======= z:{z} w:{w} ======="
      for y in space[Y]:
        for x in space[X]:
          stdout.write:
            if points.contains [x, y, z, w]: '#'
            else: '.'

        stdout.write "\n"

template inSpace(pname: untyped, xr, yr, zr, wr: HSlice[int, int],
    body: untyped): untyped =
  for x in xr:
    for y in yr:
      for z in zr:
        for w in wr:
          let pname = [x, y, z, w]
          body

# code ----------------------------------------
var activeCubesPure = block:
  var y = -1

  collect newSeq:
    for row in lines "./sample.txt":
      inc y
      for x, cell in row:
        if cell == '#':
          [x, y, 0, 0]

# func calc(space: Hyper)=
  

block part1:
  var activeCubes = activeCubesPure
  
  for _ in 1..6:
    var activeCubesCopy = activeCubes
    let space = getSpaceSize(activeCubes)

    inSpace p, space[X].expand 1, space[Y].expand 1, space[Z].expand 1, 0..0:
      let
        indexInSpace = activeCubesCopy.find p
        activeNeighbours = block:
          var c = 0
          inSpace v, -1..1, -1..1, -1..1, 0..0:
            if v != [0, 0, 0, 0]:
              let r = activeCubes.contains p + v
              c.inc int r
          c

      if indexInSpace == NotFound:
        if activeNeighbours == 3:
          activeCubesCopy.add p

      elif activeNeighbours notin [2, 3]:
        del activeCubesCopy, indexInSpace

    activeCubes = activeCubesCopy

  echo activeCubes.len

block part2:
  discard  
  
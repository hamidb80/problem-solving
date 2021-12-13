import sequtils, strutils

# prepare ------------------------------------

type
  Axis = enum xs, ys
  Point = tuple[x, y: int]
  Fold = tuple[axis: Axis, value: int]
  Data = tuple[points: seq[Point], folds: seq[Fold]]

func toPoint(a: openArray[int]): Point =
  (a[0], a[1])

template `*`(c: char, times: int): untyped =
  ($c).repeat(times)

# utils --------------------------------------

proc parseInput(content: sink string): Data =
  let sp = content.split("\r\n".repeat(2))

  result.points = sp[0].splitLines.mapIt:
    toPoint it.split(',').map(parseInt)

  result.folds = sp[1].splitLines.mapIt:
    let
      t = it[11..^1].split('=')
      axis =
        if t[0] == "x": xs
        else: ys
      val = t[1].parseInt

    (axis, val)

func `$`(points: seq[Point]): string =
  let
    width = points.mapIt(it.x).max + 1
    height = points.mapIt(it.y).max + 1

  var geo = sequtils.repeat(('.' * width), height)

  for p in points:
    geo[p.y][p.x] = '*'

  geo.join "\n"

# implement ----------------------------------

func mirror(number, line: int): int =
  if number < line: number
  else: line - abs(line - number)

func foldPaper(points: seq[Point], fold: Fold): seq[Point] =
  if fold.axis == ys:
    points.mapIt (it.x, mirror(it.y, fold.value))
  else:
    points.mapIt (mirror(it.x, fold.value), it.y)


func visiblePoints(points: seq[Point], folds: seq[Fold]): seq[Point] =
  var myPoints = points

  for f in folds:
    mypoints = foldPaper(myPoints, f)

  myPoints.deduplicate
# go -----------------------------------------

let content = readFile("./input.txt").parseInput
echo visiblePoints(content.points, @[content.folds[0]]).len # 814
echo $visiblePoints(content.points, content.folds) # PZEHRAER

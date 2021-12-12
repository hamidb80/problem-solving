import sequtils, strscans

# prepare ------------------------------------

type
  Cave = distinct string
  Connection = array[2, Cave]
  Path = seq[Cave]

const
  startCave = "start".Cave
  endCave = "end".Cave
  noCave = "".Cave

proc parseInput(fname: string): seq[Connection] =
  for l in lines fname:
    var v1, v2: string
    discard scanf(l, "$w-$w", v1, v2)
    result.add [v1.Cave, v2.Cave]

# utils --------------------------------------

func `==`(c1, c2: Cave): bool {.borrow.}
func `[]`(c: Cave, index: int): char = c.string[index]
func `$`(c: Cave): string = c.string ## debuggin purposes

func isLarge(c: Cave): bool = (c[0].ord - 'a'.ord) < 0

template concat[T](head: seq[T], tail: T): untyped =
  head.concat(@[tail])

# implement ----------------------------------

func findConnectionsFor(connections: seq[Connection], `for`: Cave): seq[Cave] =
  for conn in connections:
    if `for` in conn:
      result.add conn.filterIt(it != `for`)[0]

func findPathImpl(
  connections: seq[Connection], `from`: Cave,
  currentPath: seq[Cave], paths: var seq[Path],
  escapedCave: Cave
) =
  for cave in findConnectionsFor(connections, `from`):
    if cave == startCave:
      continue

    elif cave == endCave:
      paths.add currentPath.concat(endCave)

    else:
      let visitedBefore = cave in currentPath

      template recall(ec): untyped =
        findPathImpl connections, cave, currentPath.concat(cave), paths, ec

      if (not visitedBefore) or (cave.isLarge and visitedBefore):
        recall escapedCave
      elif escapedCave == noCave:
        recall cave

func findPath(connections: seq[Connection], canVisitTwice: static bool): seq[Path] =
  const escapedCave =
    if canVisitTwice: noCave
    else: startCave

  findPathImpl(connections, startCave, @[startCave], result, escapedCave)

func howManyWays(content: seq[Connection], singleTwice: static bool): int =
  len findPath(content, singleTwice)

# go -----------------------------------------

let content = parseInput("./input.txt")
echo howManyWays(content, false) # 3495
echo howManyWays(content, true) # 94849

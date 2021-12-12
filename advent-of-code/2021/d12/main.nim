import sequtils, strscans, tables, hashes

# prepare ------------------------------------

type
  Cave = distinct string
  Connections = TableRef[Cave, seq[Cave]]
  Path = seq[Cave]

const
  startCave = "start".Cave
  endCave = "end".Cave
  noCave = "".Cave


func `==`(c1, c2: Cave): bool {.borrow.}
func `[]`(c: Cave, index: int): char = c.string[index]
func `$`(c: Cave): string = c.string ## debuggin purposes
func hash(c: Cave): Hash = hash c.string ## debuggin purposes


proc parseInput(fname: string): Connections =
  result = newTable[Cave, seq[Cave]]()

  template addConn(`from`, to: Cave): untyped =
    if `from` in result:
      result[`from`].add to
    else:
      result[`from`] = @[to]

  for l in lines fname:
    var v1, v2: string
    discard scanf(l, "$w-$w", v1, v2)
    addConn v1.Cave, v2.Cave
    addConn v2.Cave, v1.Cave

# utils --------------------------------------

func isLarge(c: Cave): bool = (c[0].ord - 'a'.ord) < 0

template concat[T](head: seq[T], tail: T): untyped =
  head.concat(@[tail])

# implement ----------------------------------

func findPathImpl(
  connections: Connections, `from`: Cave,
  currentPath: seq[Cave], paths: var seq[Path],
  escapedCave: Cave
) =
  for cave in connections[`from`]:
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

func findPath(connections: Connections, canVisitTwice: static bool): seq[Path] =
  const escapedCave =
    if canVisitTwice: noCave
    else: startCave

  findPathImpl(connections, startCave, @[startCave], result, escapedCave)

func howManyWays(content: Connections, singleTwice: static bool): int =
  len findPath(content, singleTwice)

# go -----------------------------------------

let conns = parseInput("./input.txt")
echo howManyWays(conns, false) # 3495
echo howManyWays(conns, true) # 94849

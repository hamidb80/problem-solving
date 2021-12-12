import sequtils, strscans

# prepare ------------------------------------

type
  Cave = distinct string
  Connection = array[2, Cave]
  Path = seq[Cave]

const 
  startCave = "start".Cave
  endCave = "end".Cave

proc parseInput(fname: string): seq[Connection] =
  for l in lines fname:
    var v1, v2: string
    discard scanf(l, "$w-$w", v1, v2)
    result.add [v1.Cave, v2.Cave]

# utils --------------------------------------

proc `[]`(c: Cave, index: int): char = c.string[index]
proc `$`(c: Cave): string = c.string
proc `==`(c1, c2: Cave): bool {.borrow.}

func isLarge(c: Cave): bool = (c[0].ord - 'a'.ord) < 0

# implement ----------------------------------

func findConnectionsFor(connections: seq[Connection], `for`: Cave): seq[Cave] =
  for conn in connections:
    if `for` in conn:
      result.add conn.filterIt(it != `for`)[0]

func findPathImpl(
  connections: seq[Connection], `from`: Cave, 
  currentPath: seq[Cave], paths: var seq[Path]
) =
  for cave in findConnectionsFor(connections, `from`):
    if cave == startCave:
      continue
    
    elif cave == endCave:
      paths.add currentPath.concat(@[endCave])
    
    else:
      let visitedBefore = cave in currentPath
      
      if (cave.isLarge and visitedBefore) or (not visitedBefore):
        findPathImpl connections, cave, currentPath.concat(@[cave]), paths

func findPath(connections: seq[Connection]): seq[Path] =
  findPathImpl(connections, startCave, @[startCave], result)

func howManyWays(content: seq[Connection]): int =
  let tmp = findPath content
  # debugEcho tmp
  len tmp

# go -----------------------------------------

let content = parseInput("./input.txt")
echo howManyWays(content) # 3495
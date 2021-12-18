import sequtils, json, strformat

# def ------------------------------------

type
  Direction = enum
    Left, Right

  SnailNumberKinds = enum
    SnPair, SnLiteral

  SnailNumber = ref object
    parent: SnailNumber

    case kind: SnailNumberKinds
    of SnPair:
      left, right: SnailNumber

    of SnLiteral:
      value: int

# utils --------------------------------------

func isOdd(n: int): bool =
  n mod 2 == 1

func `~`(j: JsonNode, parent: SnailNumber = nil): SnailNumber =
  if j.kind == JInt:
    result = SnailNumber(kind: SnLiteral, value: j.getInt, parent: parent)
  else:
    result = SnailNumber(kind: SnPair, parent: parent)
    result.left = j[0] ~ result
    result.right = j[1] ~ result

func `~`(n: int): SnailNumber =
  SnailNumber(kind: SnLiteral, value: n)

func `^`(dir: Direction): Direction =
  case dir:
  of Left: Right
  of Right: Left

func initSnailNumber(left, right, parent: SnailNumber): SnailNumber =
  result = SnailNumber(kind: SnPair, left: left, right: right, parent: parent)
  result.left.parent = result
  result.right.parent = result

func initSnailNumber(left, right: int, parent: SnailNumber): SnailNumber =
  result = SnailNumber(kind: SnPair, left: ~left, right: ~right, parent: parent)
  result.left.parent = result
  result.right.parent = result

func splitNumber(n: int): SnailNumber =
  initSnailNumber(n div 2, n div 2 + (isOdd n).int, nil)

iterator items(n: SnailNumber): SnailNumber =
  yield n.left
  yield n.right

func isPurePair(n: SnailNumber): bool =
  (n.kind == SnPair) and (n.allIt it.kind == SnLiteral)

func `$`(n: SnailNumber): string =
  case n.kind:
  of SnLiteral: $ n.value
  of SnPair: fmt"[{n.left},{n.right}]"

func `[]=`(n: SnailNumber, dir: Direction, val: SnailNumber) =
  val.parent = n

  case dir:
  of Left: n.left = val
  of Right: n.right = val

func `[]`(n: SnailNumber, dir: Direction): SnailNumber =
  case dir:
  of Left: n.left
  of Right: n.right

func getDir(n: SnailNumber): Direction =
  if n.parent.left == n: Left
  else: Right

func magnitude(n: SnailNumber): int =
  case n.kind:
  of SnLiteral: n.value
  of SnPair: magnitude(n.left) * 3 + magnitude(n.right) * 2

func concat(n1, n2: SnailNumber): SnailNumber =
  initSnailNumber(n1, n2, nil)

proc replace(n, with: SnailNumber) =
  n.parent[n.getdir] = with

proc getMostLiteral(node: SnailNumber, dir: Direction): SnailNumber =
  result = node
  while result.kind != SnLiteral:
    result = result[dir]

proc addTo(node: SnailNumber, val: int, lastDir, destDir: Direction) =
  if lastDir == destDir:
    if node.parent != nil:
      addTo(node.parent, val, node.getDir, destdir)

  else:
    getMostLiteral(node[destDir], ^destDir).value += val

proc explode(npair: SnailNumber) =
  addto(npair.parent, npair.left.value, npair.getDir, Left)
  addto(npair.parent, npair.right.value, npair.getDir, Right)
  npair.replace ~0

proc split(n: SnailNumber) =
  n.replace splitNumber n.value

func getDepth(n: SnailNumber): int =
  var acc = n

  while acc.parent != nil:
    result.inc
    acc = acc.parent

proc reduceExplodes(node: SnailNumber): bool =
  if node.kind == SnPair:
    let d = node.getDepth
    if d == 4:
      # for n in node:
      if isPurePair node:
        explode node
        result = true

    elif d < 4:
      result = result or node.anyIt(reduceExplodes it)

proc reduceSplits(node: SnailNumber): bool =
  case node.kind:
  of SnPair:
    result = result or node.anyIt(reduceSplits it):

  of SnLiteral:
    if node.value >= 10:
      split node
      result = true

proc reduce(root: SnailNumber): SnailNumber =
  while reduceExplodes(root) or reduceSplits(root): discard
  root

func doReduce(a, b: SnailNumber): SnailNumber =
  var ac, bc: SnailNumber
  deepCopy(ac, a)
  deepCopy(bc, b)
  (ac.concat bc).reduce

iterator product[T](s: openArray[T]): array[2, T] =
  for i in s.low .. s.high:
    for j in s.low .. s.high:
      if i != j:
        yield [s[i], s[j]]

# implement ----------------------------------

proc test1(content: seq[SnailNumber]): int =
  magnitude content.foldl doReduce(a, b)

proc test2(content: seq[SnailNumber]): int =
  max content.product.toseq.mapIt do:
    magnitude it.foldl doReduce(a, b)

# go -----------------------------------------

let rows = lines("./input.txt").toseq.mapit( ~ it.parseJson)
echo test1(rows) # 3675
echo test2(rows) # 4650

# NOTE:
# finally, after more than 7 freaking hours ... i made it :D
# now i'm tired, but is was fun
# and a little frustrating

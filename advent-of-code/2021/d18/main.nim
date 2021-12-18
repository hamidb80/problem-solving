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

proc `>>`(n, parent: SnailNumber): SnailNumber =
  n.parent = parent
  n

func `^`(dir: Direction): Direction =
  case dir:
  of Left: Right
  of Right: Left

func initSnailNumber(left, right, parent: SnailNumber): SnailNumber =
  result = SnailNumber(kind: SnPair, parent: parent)
  result.left = left >> result
  result.right = right >> result

func initSnailNumber(left, right: int, parent: SnailNumber): SnailNumber =
  result = SnailNumber(kind: SnPair, parent: parent)
  result.left = ~left >> result
  result.right = ~right >> result

func splitNumber(n: int): SnailNumber =
  initSnailNumber(n div 2, n div 2 + (isOdd n).int, nil)

iterator items(n: SnailNumber): SnailNumber =
  yield n.left
  yield n.right

func isPurePair(n: SnailNumber): bool =
  (n.kind == SnPair) and (n.allIt it.kind == SnLiteral)

func getRoot(n: SnailNumber): SnailNumber =
  result = n
  while result.parent != nil:
    result = result.parent

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
  n.parent[n.getdir] = with >> n.parent

proc addToRecursive(parent: SnailNumber, val: int, dir: Direction) =
  

proc addTo(npair: SnailNumber, val: int, dir: Direction) =
  let relativeDir = npair.getdir

  if dir == relativeDir:
    addToRecursive(npair.parent.parent, npair[dir].value, ^dir)

  else:
    npair.parent[dir].value += val

proc explode(npair: SnailNumber) =
  debugecho "exlpode ..."
  addto(npair, npair.left.value, Left)
  addto(npair, npair.right.value, Right)
  npair.replace ~0
  debugEcho npair.getRoot

proc split(n: SnailNumber) =
  debugecho "split ..."
  n.replace splitNumber n.value
  debugEcho n.getRoot

func getDepth(n: SnailNumber): int =
  var acc = n

  while acc.parent != nil:
    result.inc
    acc = acc.parent

proc reduceImpl(node: SnailNumber): bool =
  case node.kind:
  of SnPair:
    if node.getDepth == 4:
      # for n in node:
      if isPurePair node:
        explode node
        return true

    for n in node:
      if reduceImpl n:
        return true

  of SnLiteral:
    if node.value >= 10:
      split node
      return true

proc reduce(root: SnailNumber): SnailNumber =
  echo root
  while reduceImpl(root): discard
  root

# implement ----------------------------------

proc test1(content: seq[SnailNumber]): int =
  let r = content.foldl (a.concat b).reduce
  echo r
  r.magnitude

# go -----------------------------------------

let rows = lines("./test.txt").toseq.mapit( ~ it.parseJson)
echo test1(rows)

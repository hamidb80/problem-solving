import std/[sequtils, strutils, strformat, math]

# def ----------------------------------------

type
  EntityKind = enum
    file
    directory

  Entity = ref object
    name: string

    case kind: EntityKind
    of file:
      size: int
    of directory:
      children: seq[Entity]

# utils --------------------------------------

template last(a): untyped = a[^1]
template first(a): untyped = a[0]

func newDir(name: string): Entity =
  Entity(kind: directory, name: name)

func newFile(name: string, size: int): Entity =
  Entity(kind: file, name: name, size: size)

iterator items(e: Entity): lent Entity =
  for s in e.children:
    yield s

func updatePath(p: var seq[Entity], direction: string) =
  if direction == "..":
    discard p.pop

  elif p.len == 0:
    p.add newDir direction

  else:
    for e in p.last:
      if e.name == direction:
        assert e.kind == directory
        p.add e
        return

    raise newException(ValueError, fmt"directory not found '{direction}' in '{p.last.name}'")

func parseEntity(s: string): Entity =
  let
    parts = s.split
    property = parts[0]
    name = parts[1]

  if property == "dir":
    newDir name
  else:
    newFile name, parseInt property

func totalSize(e: Entity): int =
  case e.kind
  of file: e.size
  of directory:
    var acc = 0
    for s in e:
      acc.inc s.totalSize
    acc

# implement ----------------------------------

iterator splitCommands(screen: string): seq[string] =
  var acc: seq[string]

  template ret: untyped =
    if acc.len != 0:
      yield acc
      acc.setlen 0

  for l in screen.splitLines:
    if l[0] == '$':
      ret
      acc.add l[2..^1].split

    else:
      acc.add l

  ret

func buildHierachy(data: string): Entity =
  var path: seq[Entity]

  for c in data.splitCommands:
    case c[0]
    of "cd":
      updatePath path, c[1]

    of "ls":
      for entityRaw in c[1..^1]:
        path.last.children.add parseEntity entityRaw

  path.first

func listDirs(root: Entity, result: var seq[int]) =
  for e in root:
    if e.kind == directory:
      listDirs e, result

  result.add root.totalSize

func listDirs(root: Entity): seq[int] =
  listDirs root, result

# main -----------------------------------------

func part1Impl(root: Entity, maxSingleDirSize: int, total: var int) =
  for sub in root:
    if sub.kind == directory:
      part1Impl sub, maxSingleDirSize, total
      let s = sub.totalSize
      if s <= maxSingleDirSize:
        total.inc s

func part1(root: Entity, maxSingleDirSize: int): int =
  part1Impl root, maxSingleDirSize, result

func part2(root: Entity, totalSpace, minRequiredSpace: int): int =
  let
    sizes = root.listDirs
    neededSpace = minRequiredSpace - (totalSpace - sizes.last)

  sizes.filterIt(it - neededSpace > 0).min

# go -----------------------------------------

let root = buildHierachy readFile("./input.txt")
echo part1(root, 100000) # 1513699
echo part2(root, 70000000, 30000000) # 7991939

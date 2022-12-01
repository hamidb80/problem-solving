import std/[sequtils, strutils, math, unittest]

# def ----------------------------------------

type SortedSeq[T] = object
  size: int
  list: seq[T]

# utils --------------------------------------

func initSortedSeq[T](size: int): SortedSeq[T] =
  result.size = size
  result.list = newSeqOfCap[T](size + 1)

func whereToAppend[T](s: seq[T], value: T): int =
  for i in s:
    if value < i:
      result.inc

func update[T](t: var SortedSeq[T], value: T) =
  if t.list.len == 0:
    t.list.add value

  else:
    let indx = whereToAppend(t.list, value)

    if indx != t.size:
      if indx == t.list.len:
        t.list.add value
      else:
        t.list.insert value, indx

        if t.list.len > t.size:
          del t.list, t.size

  # implement ----------------------------------

# implementation -----------------------------

iterator buckets(data: string): int =
  var acc = 0

  for line in data.splitLines:
    if line.isEmptyOrWhitespace:
      yield acc
      acc = 0
    else:
      acc.inc line.parseInt

  yield acc

func top(data: string, num: int): seq[int] =
  var tops = initSortedSeq[int](num)

  for energy in buckets data:
    tops.update energy

  tops.list

# tests --------------------------------------

suite "SortedSeq":
  var acc = initSortedSeq[int](3)

  check acc.list.whereToAppend(0) == 0

  acc.update(1)
  acc.update(5)
  acc.update(8)
  acc.update(4)

  check acc.list == @[8, 5, 4]

# go -----------------------------------------

let data = readFile("./input.txt")
echo data.top(1).sum()
echo data.top(3).sum()

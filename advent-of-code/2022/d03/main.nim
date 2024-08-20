import std/[strutils, setutils]

# utils --------------------------------------

template invalid: untyped =
  raise newException(ValueError, "invalid")

func priority(ch: char): int =
  case ch
  of 'a'..'z': 01 + ch.ord - 'a'.ord
  of 'A'..'Z': 27 + ch.ord - 'A'.ord
  else: invalid

func first[T](s: set[T]): T =
  for i in s:
    return i

func common(packets: seq[string]): char =
  var acc = packets[0].toSet

  for i in 1..packets.high:
    acc = acc * packets[i].toSet

  first acc

# implement ----------------------------------

func part1(data: string): int =
  for rucksack in data.splitLines:
    let i = rucksack.len div 2
    result.inc priority common @[rucksack[0..<i], rucksack[i..rucksack.high]]

iterator rucksacks(s: string): seq[string] =
  var acc: seq[string]

  for line in s.splitLines:
    acc.add line

    if acc.len == 3:
      yield acc
      acc.setlen 0

func part2(data: string): int =
  for r in data.rucksacks:
    result.inc r.common.priority

# go -----------------------------------------

let data = readFile "./input.txt"
echo part1 data # 7872
echo part2 data # 2497

import std/[strutils, strscans]

# utils --------------------------------------

func contains[T](r1, r2: Slice[T]): bool =
  r1.a >= r2.a and r1.b <= r2.b

func fullyOverlap[T](r1, r2: Slice[T]): bool =
  r1 in r2 or r2 in r1

func overlapImpl[T](r1, r2: Slice[T]): bool =
  r1.a <= r2.a and r1.b >= r2.a

func overlap[T](r1, r2: Slice[T]): bool =
  overlapImpl(r1, r2) or overlapImpl(r2, r1)

# implement ----------------------------------

iterator jobs(data: string): tuple[a, b: Slice[int]] =
  for line in splitLines data:
    var a, b, c, d: int
    discard line.scanf("$i-$i,$i-$i", a, b, c, d)
    yield (a..b, c..d)

func part1(data: string): int =
  for j1, j2 in jobs data:
    if fullyOverlap(j1, j2):
      result.inc

func part2(data: string): int =
  for j1, j2 in jobs data:
    if overlap(j1, j2):
      result.inc

  # or just use `iterrr` package :D
  # import iterrr
  # data.jobs |> filter((j1, j2) => overlap(j1, j2)).count()

# go -----------------------------------------

let data = readFile("./input.txt")
echo part1 data # 456
echo part2 data # 808

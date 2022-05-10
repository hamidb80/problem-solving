import std/[sequtils, algorithm, math, strutils]

func `~=`(a,b: float): bool =
  almostEqual(a, b, 10)

func `!`(a: int): int =
  if a <= 1:
    1
  else:
    a * !(a-1)

echo 1.2 ~= 1.1

echo !5
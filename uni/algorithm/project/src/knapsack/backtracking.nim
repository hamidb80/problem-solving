import std/[sequtils, sugar]
import ../common


# utils --------------------------------

func sum[T](s: seq[T], indexes: Slice[int]): T =
  for i in indexes:
    result.inc s[i]

# main --------------------------------

func isPromising(collection: seq[Item], index, maxSoFar: int): bool =
  discard

func solveImpl(collection: seq[Item], index: int, maxSoFar: var int) =
  discard

func solve*(collection: seq[Item], maxWeight: int): seq[Item] =
  discard

import std/[algorithm]
import ../common


func solve*(items: seq[Item], maxWeight: int, criteria: Comparator[Item]): seq[Item] =
  var w = 0
  for item in sorted(items, criteria, Descending):
    if w + item.weight <= maxWeight:
      w += item.weight
      result.add item

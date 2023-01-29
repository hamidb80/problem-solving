import std/[algorithm]
import ../common


func solve*(items: seq[Item], maxWeight: int, criteria: Comparator[Item]): seq[Item] =
  let sortedItems = items.sorted(criteria, Descending)       # O(n.log(n))
  var w = 0

  for item in sortedItems: # O(n)
    if w + item.weight <= maxWeight: # O(1)
      w += item.weight # O(1)
      result.add item # O(1)

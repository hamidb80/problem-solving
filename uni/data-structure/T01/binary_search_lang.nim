proc binarySearch*[T, K](a: openArray[T], key: K,
  cmp: proc (x: T, y: K): int {.closure.}): int {.effectsOf: cmp.} =

  let len = a.len

  if len == 0:
    return -1

  if len == 1:
    if cmp(a[0], key) == 0:
      return 0
    else:
      return -1

  var
    b = len
    cmpRes: int

  while result < b:
    var mid = (result + b) shr 1
    cmpRes = cmp(a[mid], key)

    if cmpRes == 0:
      return mid
    elif cmpRes < 0:
      result = mid + 1
    else:
      b = mid

  if result >= len or cmp(a[result], key) != 0:
    result = -1

proc binarySearch*[T](a: openArray[T], key: T): int =
  binarySearch(a, key, cmp[T])


# --------------------------------------

assert binarySearch([0, 1, 2, 3, 4], 4) == 4
assert binarySearch([0, 1, 2, 3, 4, 5, 6, 7], 7) == 7
assert binarySearch([0, 1, 2, 3, 4, 5, 6, 7], 12) == -1

import std/algorithm except sort
import std/unittest


template `<-`(a, b) = shallowCopy(a, b)

proc mergeAlt[T](a, b: var openArray[T], lo, m, hi: int,
  cmp: proc (x, y: T): int {.closure.}) {.effectsOf: cmp.} =

  if cmp(a[m], a[m+1]) <= 0:
    return

  var
    j = lo
    bb = 0

  while j <= m:
    b[bb] <- a[j]
    inc bb
    inc j

  var
    i = 0
    k = lo

  # copy proper element back:
  while k < j and j <= hi:
    if cmp(b[i], a[j]) <= 0:
      a[k] <- b[i]
      inc i
    else:
      a[k] <- a[j]
      inc j
    inc k

  # copy rest of b:
  while k < j:
    a[k] <- b[i]
    inc k
    inc i

func sortImpl[T](a: var openArray[T],
              cmp: proc (x, y: T): int {.closure.}) {.effectsOf: cmp.} =
  var
    n = a.len
    b = newSeq[T](n div 2)
    s = 1

  while s < n:
    var m = n-1-s
    while m >= 0:
      mergeAlt(a, b, max(m-s+1, 0), m, m+s, cmp)
      m.dec s*2
    s = s*2

proc sort[T](a: var openArray[T]) =
  sortImpl[T](a, system.cmp[T])


# ----------------------------------------

test "t":
  var s = @[4, 5, 7, 3, 1, 6, 3]
  s.sort
  check s == @[1, 3, 3, 4, 5, 6, 7]

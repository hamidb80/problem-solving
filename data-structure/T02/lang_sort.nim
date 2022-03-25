import std/algorithm except sort
import std/unittest

## iterative merge sort:
## uses a temporary sequence of length `a.len div 2`

type CmpFn[T] = proc (x, y: T): int

template `<-`(a, b) = 
  shallowCopy(a, b)

proc mergeAlt[T](a, b: var openArray[T], lo, m, hi: int, cmp: CmpFn[T]) =
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

func sort[T](a: var openArray[T], cmp: CmpFn[T]) =
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

# ----------------------------------------

test "t":
  var s = @[4, 5, 7, 3, 1, 6, 3]
  s.sort system.cmp[int]
  check s == @[1, 3, 3, 4, 5, 6, 7]

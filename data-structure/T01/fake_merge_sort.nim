import sequtils

var
  cms = 0
  m = 0

proc merge[T](a: openArray[T], first, midpoint, last: int) =
  inc m

proc merge_impl[T](a: openArray[T], first, last: int) =
  inc cms

  if last > first:
    let midpoint = (first + last) div 2
    merge_impl(a, first, midpoint)
    merge_impl(a, midpoint + 1, last)
    merge(a, first, midpoint, last)

proc merge_sort[T](a: openArray[T]) =
  merge_impl a, 0, a.high

for i in 0 .. 10:
  cms = 0
  m = 0

  merge_sort newSeqWith(i, 0)
  echo i, ": ", (cms, m)

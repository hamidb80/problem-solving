import std/[strutils, sequtils]

proc getNumberList(): seq[int] =
  stdin.readLine.splitWhitespace.map parseInt

discard stdin.readLine
let
  n1 = getNumberList()
  n2 = getNumberList()
  size = n1.len


var
  i1, i2 = 0
  acc = 0

template check(target): untyped =
  let isum = i1 + i2
  if isum == size-1:
    acc += target

  elif isum == size:
    # echo (acc, target)
    acc += target
    echo acc/2
    break

while true:
  # echo (i1,i2)
  if i1 != size and i2 != size:
    if n1[i1] < n2[i2]:
      check n1[i1]
      inc i1

    else:
      check n2[i2]
      inc i2

  elif i2 == size:
    check n1[i1]
    inc i1

  else: # i1 == size
    check n2[i2]
    inc i2

  # 1 2 3 4 4 5 6 9
import std/[strutils, bitops]

func `[]`(n: int, index: int): bool =
  testBit n, index

func `[]=`(n: var int, index: int, value: static[int]) =
  when value == 1:
    setBit n, index
  elif value == 0:
    clearBit n, index
  else:
    error

# --------------------------------

var a = 15
echo toBin(a, 8), " << Before"
a[2] = 0
a[6] = 3
echo toBin(a, 8), " << After"
echo a[5]

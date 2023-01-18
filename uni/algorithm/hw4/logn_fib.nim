# THANKS TO: https://kukuruku.co/hub/algorithms/the-nth-fibonacci-number-in-olog-n

import std/[math, tables]


type Matrix2x2 = array[4, int]

# utils ---------------------------------

func `*`(a, b: Matrix2x2): Matrix2x2 =
  [
    a[0]*b[0] + a[1]*b[2],
    a[0]*b[1] + a[1]*b[3],
    a[2]*b[0] + a[3]*b[2],
    a[2]*b[1] + a[3]*b[3],
  ]

func square[T](a: T): T = a*a

iterator powersOf2(n: int): int =
  var temp = n
  for i in countdown(64, 0):
    let m = i.nextPowerOfTwo
    if m <= temp:
      temp -= m
      yield m

# implmentation --------------------------

var cache: Table[int, Matrix2x2]
proc fibImpl(n: int): Matrix2x2 =
  if n == 1: [1, 1, 1, 0]
  elif n in cache: cache[n]
  elif n.isPowerOfTwo:
    cache[n] = fibImpl(n div 2).square
    cache[n]
  else:
    var acc = [1, 0, 0, 1] # identity matrix 2x2

    for m in powersOf2(n):
      acc = acc * fibImpl(m)

    acc

proc fibk(n: int): int = fibImpl(n)[1]

# alternative ---------------------------

func fibb(n: int): int =
  var
    a = 0
    b = 1
    t = 0

  for i in 1..n:
    t = b
    b = b+a
    a = t

  a

# main ----------------------------------

when isMainModule:
  for n in 1..100:
    let
      k = fibk(n)
      b = fibb(n)

    echo (n, k, b)
    assert k == b

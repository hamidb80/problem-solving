import std/[sequtils, strutils, math, strformat]
# import terminaltables

type Matrix[T] = seq[seq[T]]


proc draw(s: Matrix[int]) =
  # let t = newUnicodeTable()

  # t.setHeaders(s[0].mapIt $it)

  # for i in 1..s.high:
  #   t.addRow(s[i].mapIt $it)

  # printTable(t)

  for r in s:
    echo r.mapIt( fmt"{it:3}").join " "

func newMatrix[T](w, h: int, default: T): Matrix[T] =
  repeat repeat(default, w), h

func isOdd(n: int): bool =
  n mod 2 == 1

func isMagicSquare[T](m: Matrix[T]): bool =
  let s0 = m[0].sum
  for row in m:
    if row.sum != s0:
      return false
  true

func magicSquare(n: int): Matrix[int] =
  assert n > 0 and n.isOdd
  result = newMatrix(n, n, -1)

  let size = n * n
  var
    x = n div 2
    y = 0
    i = 1

  result[y][x] = 1

  while i != size:
    let
      ny = euclMod(y-1, n)
      nx = euclMod(x-1, n)

    inc i

    (x, y) =
      if result[ny][nx] == -1: (nx, ny)
      else: (x, euclMod(y+1, n))

    result[y][x] = i

  assert isMagicSquare result


when isMainModule:
  stdout.write "enter n: "
  draw magicSquare stdin.readline.parseInt

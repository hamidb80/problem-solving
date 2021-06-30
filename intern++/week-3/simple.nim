# https://quera.ir/problemset/contest/33023/

import sugar, sequtils, strutils

func gt(a,b: int): bool = a > b
func lt(a,b: int): bool = a < b

let size = stdin.readLine.splitWhitespace.map parseInt
let m = collect newseq: # m: matrix
  for y in 0..<size[0]:
    stdin.readLine.splitWhitespace.map parseInt

var counter = 0
for y in 1..<size[0] - 1:
  for x in 0..<size[1] - 1:
    for (fn1, fn2) in [(gt, lt), (lt, gt)]:
      if 
        m[y][x].fn1(m[y-1][x]) and 
        m[y][x].fn1(m[y+1][x]) and
        m[y][x].fn2(m[y][x+1]) and
        m[y][x].fn2(m[y][x-1]):
        inc counter
        break

echo counter

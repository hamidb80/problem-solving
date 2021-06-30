import sequtils, strutils

func toIntSeq(line: string): seq[int]= 
  line.split(' ').mapIt it.parseInt

discard stdin.readLine

let 
  a = stdin.readLine.toIntSeq
  b = stdin.readLine.toIntSeq

var sum = 0
for n in 0..a.high:
  sum += a[n] * b[n]

echo sum
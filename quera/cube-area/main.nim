import sequtils, strutils

func primeFactors(n: int): seq[int]=
  var 
    nc = n
    i = 2

  while i <= nc:
    if nc mod i == 0: 
      result.add i
      nc = nc div i

    else:
      inc i

func cubicEdgesFactors(volume: int): seq[int] =
  result = volume.primeFactors

  let diff = 3 - result.len
  if diff > 0:
    for i in 1..diff:
      result.insert 1, 0

func minArea*(volume: int): int= # scvf: sorted cubic Vertexes Factors
  let e = (cubicEdgesFactors volume).distribute(3).mapIt(it.foldl a * b) # e: edges
  2 * ( e[0] * e[1] + e[0] * e[2] + e[1] * e[2])

if isMainModule:
  let volume = stdin.readLine.parseInt
  echo minArea volume
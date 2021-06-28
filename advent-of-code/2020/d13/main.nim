import strutils, sequtils, math, sugar
import print

let 
  lines = (readFile "./sample.txt").splitLines
  tttbs  = lines[0].parseInt # time to take to bus top


block part1:
  let  
    busList = lines[1].split(',').filterIt(it != "x").mapIt it.parseInt
    waits = busList.mapIt abs(tttbs mod it - it)
    minWaitIndex = minIndex waits

  echo busList[minWaitIndex] * waits[minWaitIndex]

func occur(n1, n2, plus: int): int=
  if n1 * n2 == 0: return n1 + n2

  let 
    mx = max(n1, n2)
    mn = min(n1, n2)
    np = 
      if mx == n1: plus
      else: -plus

  var time = mx

  while (time + np) mod mn != 0:
    time += mx

  time

block part2:
  # print occur(17, 13, +2)
  # print occur(13, 17, -2)

  let 
    busTimingList = lines[1].split(',').mapIt:
      if it == "x": 0
      else: it.parseInt

  print busTimingList

  var ans = busTimingList[0]
  for i in 1..busTimingList.high:
    let id = busTimingList[i]

    if id == 0: 
      continue
    
    echo (ans, id, i)
    ans = occur(ans, id, i)

  echo ans
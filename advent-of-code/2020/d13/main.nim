import strutils, sequtils, math, sugar
import print

let 
  lines = (readFile "./sample.txt").splitLines
  tttbs  = lines[0].parseInt # time to take to bus top

func `[]`(r:HSlice[int, int], index: int): int= 
  r.a + index


block part1:
  let  
    busList = lines[1].split(',').filterIt(it != "x").mapIt it.parseInt
    waits = busList.mapIt abs(tttbs mod it - it)
    minWaitIndex = minIndex waits

  echo busList[minWaitIndex] * waits[minWaitIndex]

func occur(less, mx, plus: int): int=
  # var time = 0
  var time = mx

  while (time + plus) mod less != 0:
    time += mx

  time

block part2:
  let 
    busTimingList = lines[1].split(',').mapIt:
      if it == "x": 0
      else: it.parseInt
  
    stepBusIndex = busTimingList.maxIndex
    step = busTimingList[stepBusIndex]


  # var maxOnIdsTimesToMatch = collect newSeq:
    # for i, id in busTimingList:
      # occur(id, step)


  print busTimingList

  var maxOnIdsTimesToMatch = collect newSeq:
    for i, id in busTimingList:
      if id != 0:
        occur id, step, i - stepBusIndex

  print maxOnIdsTimesToMatch

  echo lcm maxOnIdsTimesToMatch.filterIt it != 0
  # maxOnIdsTimesToMatch.applyIt:
  #   let coeff = kn2Lcm div it.kn2
  #   (it.kn1 * coeff, it.kn2 * coeff)

  # print maxOnIdsTimesToMatch
  # print gcd maxOnIdsTimesToMatch.mapIt it.kn1
  # let l = lcm maxOnIdsTimesToMatch.mapIt it.kn1
  # print gcd(l, maxOnIdsTimesToMatch[0].kn2)

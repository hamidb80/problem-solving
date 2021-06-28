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

func occur(base, divid, plus, step: int): int=
  if divid == 0: return base
  var time = base

  while (time + plus) mod divid != 0:
    time += step

  time

proc drawTimeline(time: int, busIds:seq[int])=
  let 
    off = busIds.mapIt:
      let t = time mod it
      if t == 0: 0
      else: it - t
    max = max off


  for timeCursor in time..time+max:
    let a = collect newseq:
      for it in busIds:
        if timeCursor mod it == 0: '0'
        else: '-'

    echo timeCursor, " | ", a.join



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
    
    let step = ans * (busTimingList[i-1] + 1)

    echo "occur", (ans, id, i, step)
    ans = occur(ans, id, i, step)

  echo ans
  drawTimeline ans, busTimingList.filterIt it != 0
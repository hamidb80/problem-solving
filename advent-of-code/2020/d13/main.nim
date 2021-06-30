import strutils, sequtils, sugar

# functionalities ---------------------------------------

proc drawTimeline(time: int, busIds: seq[int], `for`: int) =
  ## for debuging purposes
  for timeCursor in time..time+`for`:
    let a = collect newseq:
      for it in busIds:
        if timeCursor mod it == 0: '0'
        else: '-'

    echo timeCursor, " | ", a.join

func occur(base, divid, plus, step: int, includeStart: bool): int =
  ## return first match for given conditions
  if divid == 0: return base
  var time = base

  while true:
    if (time + plus) mod divid == 0:
      if time == base:
        if includeStart:
          break
      else:
        break

    time += step

  time

# prepraring data --------------------------------------

let
  lines = (readFile "./input.txt").splitLines
  tttbs = lines[0].parseInt # time to take to bus top

# code  --------------------------------------

block part1:
  let
    busList = lines[1].split(',').filterIt(it != "x").mapIt it.parseInt
    waits = busList.mapIt abs(tttbs mod it - it)
    minWaitIndex = minIndex waits

  echo busList[minWaitIndex] * waits[minWaitIndex]


block part2:
  let
    busTimingList = lines[1].split(',').mapIt:
      if it == "x": 0
      else: it.parseInt

  var
    ans = busTimingList[0]
    step = busTimingList[0]

  for i in 1..busTimingList.high:
    let id = busTimingList[i]

    if id == 0:
      continue

    ans = occur(ans, id, i, step, true)
    step = occur(ans, id, i, step, false) - ans

  echo ans
  # drawTimeline ans, busTimingList.filterIt it != 0, 20

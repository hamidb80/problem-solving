import strutils, sequtils, tables, sugar
# import print

# data structuring --------------------------------------

const NotFound = 0

type 
  ## number: [lastIndexSeen, secondsToLastIndexSeen]
  NumberIndexTable = Table[int, array[2, int]]

# functionalities ----------------------------------------------

proc nth(nimap: NumberIndexTable, until, startWith: int): int=
  var 
    myMap = nimap
    lsatSpokenNumber = startWith

  for i in myMap.len+1..until:
    # print lsatSpokenNumber

    let 
      m = myMap[lsatSpokenNumber] # [3, 0]
      n =
        if m[1] == NotFound: 0
        else: m[0] - m[1]

    # print m
    # print n
    
    myMap[n] =
      if myMap.hasKey n: [i, myMap[n][0]]
      else: [i, NotFound]

    lsatSpokenNumber = n

    # print myMap
    # echo "------------"
    
  lsatSpokenNumber

# print nimap
# echo nth(nimap, 10, lastNum)

# preparing data --------------------------------------------

let 
  nums = readFile("./input.txt").split(",").map parseInt
  lastNum = nums[^1]
  nimap = collect initTable: # number->index map
    for i,n in nums:
      {n: [i+1,NotFound]}


block part1:
  echo nth(nimap, 2020, lastNum)

block part2:
  echo nth(nimap, 30000000, lastNum)
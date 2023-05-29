## originally written for my dear friend Sina Maleki who
## had struggles to find a valid and performant solution.
## 
## Problem:
## 
## Given a binary number with some bits are `?`, 
## meaning we are uncertain about them.
## 
## wirte a function to get the uncertain binary string 
## and returns all of the possible numbers in descending order

import std/[strutils, sequtils]


func combinationsImpl(s: seq[int], index: int, sum: int, result: var seq[int]) =
  if index == s.len:
    result.add sum
  else:
    combinationsImpl(s, index+1, sum+s[index], result)
    combinationsImpl(s, index+1, sum, result)

func combinations(s: seq[int]): seq[int] =
  combinationsImpl s, 0, 0, result


func findIndexes(s: string, ch: char): seq[int] =
  for i, c in s:
    if c == ch:
      result.add i

proc possibleNumbers(uncertainNumber: string): seq[int] =
  let
    minimum = uncertainNumber.replace('?', '0').parseBinInt
    ones =
      findIndexes(uncertainNumber, '?')
      .mapit 1 shl (uncertainNumber.len - it - 1)
  
  for c in combinations ones:
    result.add minimum + c


when isMainModule:
  echo possibleNumbers "10?1?0"
  echo possibleNumbers "???"

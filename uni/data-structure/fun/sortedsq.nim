# https://leetcode.com/problems/squares-of-a-sorted-array/
import std/[sequtils, math]

template reversedMapIt(iter, expr): untyped =
  var temp = newSeqOfCap[typeof iter[0]](iter.len)
  for i in countdown(iter.high, 0):
    let it {.inject.} = iter[i]
    temp.add expr
  temp

func merge(s: seq[int], diffIndex: int): seq[int] =
  var
    i = diffIndex
    j = diffIndex + 1

  template n1: untyped = s[i] * s[i]
  template n2: untyped = s[j] * s[j]

  template do1: untyped =
    result.add n1()
    dec i

  template do2: untyped =
    result.add n2()
    inc j

  while true:
    let
      c1 = i > -1
      c2 = j < s.len

    if c1 and c2:
      case cmp(n1, n2):
      of +1: do2
      of -1: do1
      else: do1; do2

    elif c1: do1
    elif c2: do2
    else: break


func sortedSq(nums: seq[int]): seq[int] =
  assert nums.len > 0
  var foolIndex = -1

  if nums[0] < 0:
    for i in countup(1, nums.high):
      if nums[i] >= 0:
        foolIndex = i-1
        break

  if foolIndex == -1:
    if nums[0] < 0:
      nums.reversedMapIt it ^ 2
    else:
      nums.mapIt it ^ 2
  else:
    merge nums, foolIndex


echo sortedSq @[-7, -3, -1, 2, 3, 11, 14] # @[1, 4, 9, 9, 49, 121, 196]
echo sortedSq @[-7, -3, -1] # @[1, 9, 49]
echo sortedSq @[2, 3, 11, 14] # @[4, 9, 121, 196]
echo sortedSq @[-1] # @[1]
echo sortedSq @[2] # @[4]

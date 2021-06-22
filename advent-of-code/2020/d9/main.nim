import sugar, strutils, math

const chunkSize = 25

var ans1: tuple[index, val: int]
var numbers = collect newSeq:
  for line in "./input.txt".lines:
    line.parseInt

func anyChunkSum(list: seq[int], pos, chunkLen, chunkSum: int): bool =
  for i1 in 1..chunkLen:
    for i2 in (i1+1)..chunkLen:
      if list[pos - i1] + list[pos - i2] == chunkSum:
        return true

block part1:
  for i in chunkSize..numbers.high:
    if not anyChunkSum(numbers, i, chunkSize, numbers[i]):
      ans1 = (i, numbers[i])
      echo ans1.val
      break part1

block part2:
  for i1 in 0..ans1.index:
    for i2 in (i1+1)..ans1.index:
      let chunk = numbers[i1..i2]
      if sum(chunk) == ans1.val:
        echo min(chunk) + max(chunk)

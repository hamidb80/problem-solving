import sequtils, strutils

let nums = readFile("./input.txt").splitLines.mapIt it.parseInt

block part1:
  for i1 in 0..<nums.len:
    for i2 in (i1+1)..<nums.len:
      let (n1, n2) = (nums[i1], nums[i2])
      if n1 + n2 == 2020:
        echo n1 * n2
        break part1

block part2:
  for i1 in 0..<nums.len:
    for i2 in (i1+1)..<nums.len:
      for i3 in (i2+1)..<nums.len:
        let (n1, n2, n3) = (nums[i1], nums[i2], nums[i3])
        if n1 + n2 + n3 == 2020:
          echo n1 * n2 * n3
          break part2

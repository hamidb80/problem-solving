import sugar, algorithm, strutils

var adapters = collect newseq:
  for line in "./input.txt".lines:
    line.parseInt

adapters.sort
adapters.insert 0, 0
adapters.add adapters[^1] + 3

# code ------------------------------------

block part1:
  var diffs: array[1..3, int] = [0, 0, 0]
  
  for i in 0..<adapters.high:
    let diff = adapters[i+1] - adapters[i]
    diffs[diff].inc

  echo diffs[1] * diffs[3]

func waysToSort(nums: seq[int], maxDiff: bool): int=
  if maxDiff:
    result = 1
    var cutFrom = 0
    template add(i: untyped): untyped= 
      result *= nums[cutFrom..i].waysToSort false
      
    for i in 0..<nums.high:
      if nums[i + 1] - nums[i] == 3:
        add i
        cutFrom = i + 1
    add ^1
  
  else:
    result = 
      case nums.len:
      of 1, 2: 1
      else:
        var c = 1 
        for i in 1..2:
          if i >= nums.high or nums[i] - nums[0] > 3: 
            break
          else:
            c += nums[(i)..^1].waysToSort(false)
        c
  
block part2:
  echo waysToSort(adapters, true)
  
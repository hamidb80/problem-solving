import std/[unittest]
import knapsack/[dynamic, greedy, backtracking]
import common

test "correctness":
  let ans = 
    # solve(testItems, testCapacity)
    solve(preDefinedItems, preDefinedBudget)

  echo ans
  echo ans.makeReport

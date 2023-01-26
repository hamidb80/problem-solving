import std/[unittest]
import common
import knapsack/[dynamic, greedy, backtracking]

test "correctness":
  let
    r1 = dynamic.solve(preDefinedItems, preDefinedBudget)
    r2 = backtracking.solve(preDefinedItems, preDefinedBudget)

  check r1.makeReport == r2.makeReport

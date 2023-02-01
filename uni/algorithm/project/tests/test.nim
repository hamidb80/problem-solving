import std/[unittest]
import common
import knapsack/[dynamic, greedy, backtracking]

when defined debug:
  echo "=== Dynamic Programming ==="
  discard dynamic.solve(testItems, testCapacity)

  echo "=== Back Tracking ==="
  discard backtracking.solve(preDefinedItems, preDefinedBudget)

else:
  test "correctness":
    let
      r1 = dynamic.solve(preDefinedItems, preDefinedBudget)
      r2 = backtracking.solve(preDefinedItems, preDefinedBudget)

    check r1.makeReport == r2.makeReport
    check r1.len == r2.len

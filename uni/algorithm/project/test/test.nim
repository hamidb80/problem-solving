import std/[unittest]
import knapsack/[dynamic, greedy, backtracking]
import common

func totalProfit(s: seq[Item]): int = 
  for i in s:
    result.inc i.profit

suite "correctness":
  let 
    budget = 1_000_000_000
    items: seq[Item] = @[
      newItem(50, 5),
      newItem(60, 10),
      newItem(140, 20)]

  let 
    d = dynamic.solve(items, budget).totalProfit
    g = greedy.solve(items, budget).totalProfit
    b = backtracking.solve(items, budget).totalProfit

  check d == g and g == b
  
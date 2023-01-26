import std/[strutils]
import common
from knapsack/greedy import nil
from knapsack/backtracking import nil
from knapsack/dynamic import nil

# defs -------------------------------------

type
  SolveMethod = enum
    smGreedy = "greedy"
    smDynamicProgramming = "dynamic programming"
    smBackTracking = "back tracking"

  GreedyCriterias = enum
    gcProfit = "Profit"
    gcCost = "Cost"
    gcProfitPerCost = "Profit Per Cost"

  # ItemFields = enum
  #   ifName
  #   ifProfit
  #   ifWieght

# func `[]=`(i: var Item, f: ItemFields)

# core -------------------------------------

include karax/prelude

# utils -----------------------------------

func str(c: cstring): string =
  $c

# states -----------------------------------

var
  # --- inputs
  items: seq[Item]
  budget: int
  solveMethod: SolveMethod
  greedyCriteria: GreedyCriterias

  # --- outputs
  selected: seq[Item]
  report: Report

# actions ---------------------------------


proc solve =
  selected =
    case solveMethod
    of smBackTracking:
      backtracking.solve items, budget

    of smDynamicProgramming:
      dynamic.solve items, budget

    of smGreedy:
      greedy.solve items, budget:
        case greedyCriteria
        of gcProfit: byProfit
        of gcCost: byWeight
        of gcProfitPerCost: byProfitPerWeight


# components ------------------------------

proc reportC(budget: int, report: Report): VNode =
  buildHtml tdiv:
    text "profit"
    text $report.totalProfit

    text "cost"
    text $report.totalWeight

    text "remaining"
    text $(budget - report.totalWeight)


proc selectedItemC(n: int, item: Item): VNode =
  buildHtml tdiv:
    text $n
    text item.name
    text $item.weight
    text $item.profit


proc app: VNode =
  buildHtml tdiv:
    h1: text "Stock Market Project"
    h2: text "data"

    tdiv:
      text "budget: "
      input(placeholder = "budget"):
        proc onchange(e: Event, vn: VNode) =
          budget = vn.value.str.parseInt

      for i, item in items:
        tdiv:
          text $(i+1)
          input(placeholder = "name", onchange = _)
          input(placeholder = "cost", onchange = _)
          input(placeholder = "profit", onchange = _)

      button:
        proc onclick = discard
        text "add"

    h2: text "methods"

    select:
      proc onchange(e: Event, vn: VNode) =
        solveMethod = parseEnum[SolveMethod](vn.value.str)

      for o in SolveMethod:
        option:
          text $o

    if solveMethod == smGreedy:
      tdiv:
        select:
          proc onchange(e: Event, vn: VNode) =
            discard

          for o in GreedyCriterias:
            option:
              text $o

    text $solveMethod

    button:
      text "solve"
      proc onclick = solve()

    h2: text "results"
    h3: text "report"
    reportC budget, report

    h3: text "items"

    for i, s in selected:
      selectedItemC i+1, s

    footer:
      text "avaible on guthub"


# init -----------------------------------

when isMainModule:
  setRenderer app

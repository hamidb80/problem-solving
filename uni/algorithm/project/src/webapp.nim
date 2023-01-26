import common

# defs -------------------------------------

type
  SolveMethod = enum
    smGreedy = "greedy"
    smDynamicProgramming = "dynamic programming"
    smBackTracking = "back tracking"

# core -------------------------------------

include karax/prelude

# states -----------------------------------

var
  # --- inputs
  items: seq[Item]
  budget: int
  solveMethod: SolveMethod
  criteria: Comparator[Item]

  # --- outputs 
  selected: seq[Item]
  report: Report


# components -------------------------------

proc app: VNode =
  buildHtml(tdiv):
    h1 "Stock Market Project"

    
    h2 "data"
    row:
      text "budget: "
      input value = $budget, onchange = _

    for i, item in items:
      row:
        text $(i+1)
        input placeholder="name", onchange = ..
        input placeholder="cost", onchange = ..
        input placeholder="profit", onchange = ..
        
        # TODO delete on delete the name


    text $(items.len + 1)
    input placeholder="name", onchange = add new
    input placeholder="cost", onchange = add new
    input placeholder="profit", onchange = add new

    h2 "methods"

    select onchane = ...
    
      for o in options:
        text $o

    h2 "results"
    h3 "report"
      profit report.totalProfit
      cost report.totalWeight
      remaining budget - report.totalWeight


    h3 "items"
    for i, s in selected:
      row:
        text (i+1)
        span s.name
        span s.cost
        span s.profit

    footer:
      avaible on guthub


# init -----------------------------------

when isMainModule:
  setRenderer app

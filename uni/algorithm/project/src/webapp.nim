import std/[strutils, sugar, jsconsole]
import common
from knapsack/greedy import nil
from knapsack/backtracking import nil
from knapsack/dynamic import nil

# defs -------------------------------------

type
  SolveMethod = enum
    smGreedy = "Greedy"
    smDynamicProgramming = "Dynamic Programming"
    smBackTracking = "Back Tracking"

  GreedyCriteria = enum
    gcProfit = "Profit"
    gcCost = "Cost"
    gcProfitPerCost = "Profit per Cost"

# core -------------------------------------

include karax/prelude

# utils -----------------------------------

func str[T](c: T): string =
  $c

func toNumber(i: int): string = 
  i.str.insertSep

# states -----------------------------------

var
  # --- inputs
  items: seq[Item]
  budget: int
  solveMethod: SolveMethod
  greedyCriteria: GreedyCriteria

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

  report = selected.makeReport

proc loadPreDefined =
  budget = 100_000_000
  items = preDefinedItems

proc clearResult =
  selected.reset

template ev(body): untyped =
  let temp = proc(e: Event, vn: VNode) =
    let s {.inject.} = vn.value.str
    body

  temp

func set[T](wrapper: var T, value: T) =
  wrapper = value

# components ------------------------------

proc itemInput(i: int, item: Item): VNode =
  buildHtml tdiv(class = "my-2 d-flex align-items-center"):
    span:
      text "#"
      text $(i+1)

    input(class = "form-control d-inline-block",
      placeholder = "name",
      value = $items[i].name,
      onchange = ev(items[i].name.set s))

    input(class = "form-control d-inline-block",
      placeholder = "profit",
      value = $items[i].profit,
      onchange = ev(items[i].profit.set parseInt s))

    input(class = "form-control d-inline-block",
      placeholder = "cost",
      value = $items[i].weight,
      onchange = ev(items[i].weight.set parseInt s))

    button(class = "btn btn-danger"):
      proc onclick =
        clearResult()
        items.delete i
      text "delete"

proc selectedItemsTable: VNode =
  buildHtml table(class = "table table-hover"):
    thead:
      tr(class = "table-primary"):
        th: text "#"
        th: text "name"
        th: text "profit"
        th: text "cost"
        th: text "profit/cost"

    tbody:
      for i, s in selected:
        tr(class = "table-" & (if i mod 2 == 0: "light" else: "")):
          td: text $(i+1)
          td: text s.name
          td: text s.profit.toNumber
          td: text s.weight.toNumber
          td: text $(s.profit/s.weight)

proc app: VNode =
  buildHtml tdiv(class = "p-4"):
    h1(class = "text-center"): text "Stock Market Project"
    h2(class = "mt-4"): text "Input Data"

    tdiv:
      button(class = "btn btn-warning w-100 my-2"):
        proc onclick = loadPreDefined()
        text "Load Pre Defined Data"

      tdiv(class = "d-flex align-items-center"):
        text "budget: "
        input(class = "form-control", placeholder = "budget", value = $budget):
          proc onchange(e: Event, vn: VNode) =
            clearResult()
            budget = vn.value.str.parseInt

      for i, item in items:
        itemInput(i, item)

      button(class = "btn btn-success w-100 my-2"):
        text "add"
        proc onclick =
          clearResult()
          items.add Item.default

    h2(class = "mt-4"): text "Method"

    select(class = "form-select"):
      proc onchange(e: Event, vn: VNode) =
        solveMethod = parseEnum[SolveMethod](vn.value.str)

      for o in SolveMethod:
        option:
          text $o

    if solveMethod == smGreedy:
      tdiv:
        select(class = "form-select"):
          proc onchange(e: Event, vn: VNode) =
            greedyCriteria = parseEnum[GreedyCriteria](vn.value.str)

          proc onchange(e: Event, vn: VNode) =
            discard

          for o in GreedyCriteria:
            option:
              text $o

    tdiv(class = "my-3"):
      button(class = "btn w-100 btn-info"):
        text "solve"
        proc onclick =
          clearResult()
          solve()

    if budget != 0:
      h2(class = "mt-4"): text "Result"

      if selected.len == 0:
        text "nothing"

      else:
        tdiv:
          h3: text "Selected Items"
          selectedItemsTable()

          h3: text "Report"
          ul:
            li:
              bold: text "Total Profit: "
              text report.totalProfit.toNumber

            li:
              bold: text "Total Cost: "
              text report.totalWeight.toNumber

            li:
              bold: text "Remaining Budget: "
              text (budget - report.totalWeight).toNumber

    footer(class = "mt-4"):
      hr()

      span:
        text "created by "

      a(href = "https://github.com/@hamidb80"):
        text "@hamidb80"


# init -----------------------------------

when isMainModule:
  setRenderer app

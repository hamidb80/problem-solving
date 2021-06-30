import sugar, strutils, sequtils, math, tables, sets
import print

# datastrcuture ----------------------------------

const NotFound = -1

type
  Rule = tuple
    title: string
    ranges: seq[HSlice[int, int]]

  Ticket = seq[int]

# functionalities --------------------------------

func parseTicket(line: string): Ticket =
  line.split(',').map parseInt

func isMatched(number: int, ranges: seq[HSlice[int, int]]): bool =
  ranges.anyIt number in it

func isValid(number: int, rules: seq[Rule]): bool =
  rules.anyIt isMatched(number, it.ranges)

# preparing data -----------------------------------------

let
  document = readFile("./input.txt").split "\c\n\c\n"

  rules: seq[Rule] = collect newseq:
    for line in document[0].splitLines:
      let defineIndex = line.find ':'
      (
        line[0..<defineIndex],
        line[(defineIndex+2)..^1].split(" or ").mapIt(block:
          let values = it.split('-').map parseInt
          values[0]..values[1]
      ))

  yourTicket = document[1].splitLines[1].parseTicket
  nearbyTickets = document[2].splitLines[1..^1].map parseTicket

# code -------------------------------------------

block part1:
  var numbers: seq[int]

  for ticket in nearbyTickets:
    for part in ticket:
      var matched = false
      for rule in rules:
        for rng in rule.ranges:
          if part in rng:
            matched = true
            break

      if not matched:
        numbers.add part

  echo sum numbers


block part2:
  let
    tickets = nearbyTickets.filterIt it.allIt it.isValid rules
    columns = tickets[0].len

  var validRuleColoumns: Table[string, seq[int]]

  for rule in rules: ## find mathed columns for rules
    for col in 0..<columns:

      if tickets.allIt it[col].isMatched(rule.ranges):
        if validRuleColoumns.hasKey rule.title:
          validRuleColoumns[rule.title].add col
        else:
          validRuleColoumns[rule.title] = @[col]

  # print tickets
  # print validRuleColoumns

  var unResolvedRules = validRuleColoumns.keys.toseq.toHashSet
  while unResolvedRules.len > 0: ## find corresponding columns
    for key in unResolvedRules:
      if validRuleColoumns[key].len == 1:
        let uniqueCol = validRuleColoumns[key][0]
        for k, v in validRuleColoumns:
          if k != key:
            let i = v.find uniqueCol
            if i != NotFound:
              del validRuleColoumns[k], i

        unResolvedRules.excl key
        break

  # print validRuleColoumns

  let vals = collect newseq:
    for key, val in validRuleColoumns:
      if "departure" in key:
        yourTicket[val[0]]

  echo vals.foldl a * b

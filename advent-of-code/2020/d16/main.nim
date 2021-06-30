import sugar, strutils, sequtils, math, tables
import print 

type
  Rule = tuple
    title: string
    ranges: seq[HSlice[int, int]]

  Ticket = seq[int]

func line2ticket(line: string): Ticket =
  line.split(',').map parseInt

let 
  document = readFile("./sample.txt").split "\c\n\c\n"
  
  rules: seq[Rule] = collect newseq:
    for line in document[0].splitLines:
      let defineIndex = line.find ':'
      (
        line[0..<defineIndex],
        line[(defineIndex+2)..^1].split(" or ").mapIt(block:
          let values = it.split('-').map parseInt
          values[0]..values[1]
      ))

  yourTicket = document[1].splitLines[1].line2ticket
  nearbyTickets = document[2].splitLines[1..^1].map line2ticket

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


func isMatched(number: int, ranges: seq[HSlice[int, int]]): bool =
  ranges.anyIt number in it

func isValid(number: int, rules: seq[Rule]): bool =
  rules.anyIt isMatched(number, it.ranges)

block part2:
  let
    tickets = nearbyTickets.filterIt it.allIt it.isValid rules
    columns = tickets[0].len

  var validRuleColoumns: Table[string, seq[int]]

  for rule in rules:
    for col in 0..<columns:

      if tickets.allIt it[col].isMatched(rule.ranges):
        if validRuleColoumns.hasKey rule.title:
          validRuleColoumns[rule.title].add col
        else:
          validRuleColoumns[rule.title] = @[col]

  # print tickets
  print validRuleColoumns
  print validRuleColoumns.len

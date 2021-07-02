import sequtils, strutils, sugar, tables, strformat

# data structuring --------------------------------------

type
  RuleKinds = enum
    RKAtcual
    RKRelative

  Rule = ref object
    case kind: RuleKinds
    of RKAtcual:
      pattern: char
    of RKRelative:
      orRulesRef: seq[seq[int]]

# functionalities ---------------------------------

template hasSomething[T](s: openArray[T]): untyped =
  s.len != 0

func flatten[T](s: seq[seq[T]]): seq[T] =
  for item in s:
    result.add item

func matchSeq(s: string, ruleIds: seq[int], rules: var Table[int, Rule], isMaster = true): seq[int] =
  ## match functions return return mathced len if they could otherwise NotFound
  template FAIL: untyped =
    # debugEcho fmt "\"{s}\" failed at {ruleIds} prog:{progessIndex}"
    return

  var progessIndexes = @[0]
  for ruleId in ruleIds:
    let rule = rules[ruleId]

    if rule.kind == RKRelative:
      let temp = collect newseq:
        for pi in progessIndexes:
          let subs = s[pi..^1] # caching

          for ruleIds in rule.orRulesRef:
            let m = subs.matchSeq(ruleIds, rules, false)
            if m.hasSomething:
              m.mapIt it + pi

      progessIndexes = temp.flatten

    else:
      for i, pi in progessIndexes:
        if s.len > pi and s[pi] == rule.pattern:
          inc progessIndexes[i]
        else:
          FAIL

  result =
    if isMaster:
      if progessIndexes.anyIt it == s.len: @[0]
      else: @[]
    else: progessIndexes

func matchRule(s: string, rule: Rule, rules: var Table[int, Rule]): bool =
  doAssert rule.kind == RKRelative

  for subrule in rule.orRulesRef:
    let m = s.matchSeq(subrule, rules)
    if m.hasSomething:
      return true

template matchRule(s: string, ruleId: int, rules: var Table[int, Rule]): untyped =
  matchRule s, rules[ruleId], rules

# preprating data ---------------------------------

let
  document = readFile("./input.txt").split("\c\n\c\n")
  tests = document[1].splitLines

var
  rules = collect initTable:
    for line in document[0].splitLines:
      let
        coloni = line.find(':')
        ruleNumber = line[0..<coloni].parseInt
        rest = line[coloni+2..^1]

      var rule: Rule
      if '"' in rest:
        rule = Rule(kind: RKAtcual, pattern: rest[1])
      else:
        let ruleNums = rest.split(" | ").mapIt it.splitWhitespace.map parseInt
        rule = Rule(kind: RKRelative, orRulesRef: ruleNums)

      {ruleNumber: rule}


# code ---------------------------------------

proc getAns: int =
  tests.countIt it.matchRule(0, rules)

block part1:
  echo getAns()

block part2:
  rules[8].orRulesRef = @[@[42], @[42, 8]]
  rules[11].orRulesRef = @[@[42, 31], @[42, 11, 31]]

  echo getAns()

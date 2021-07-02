import sequtils, strutils, sugar, tables
import print, strformat

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

const NotFound = 0

# functionalities ---------------------------------
## match functions return return mathced len if they could otherwise NotFound
func match(s: string, rule: Rule, rules: var Table[int, Rule], isMaster = true): int

func match(s: string, ruleIds: seq[int], rules: var Table[int, Rule], isMaster = true): int =
  template fail: untyped =
    # debugEcho fmt "\"{s}\" failed at {ruleIds} prog:{progessIndex}"
    return

  var progessIndex = 0
  for ruleId in ruleIds:
    let rule = rules[ruleId]

    if rule.kind == RKRelative:
      # debugEcho "testing ", subrule, " over \"", s, '"'
      # debugEcho ">>testing ", subrule, " over \"", s, '"'
      let mlen = block:
        var c = NotFound
        for subrule in rule.orRulesRef:
          let m = s[progessIndex..^1].match(subrule, rules, false)
          if m != NotFound:
            c = m
            break
        c

      if mlen != NotFound:
        inc progessIndex, mlen
      else:
        fail

    else:
      # debugEcho fmt "\"{s}\"[{progessIndex}] ruleIds={ruleIds} pattern='{rule.pattern}'"
      if s.len > progessIndex and s[progessIndex] == rule.pattern:
        # debugEcho fmt "\"{s}\"[{progessIndex}] == '{rule.pattern}'"
        inc progessIndex
      else:
        fail

  if isMaster and progessIndex != s.len: NotFound
  else: progessIndex

func match(s: string, rule: Rule, rules: var Table[int, Rule], isMaster = true): int =
  doAssert rule.kind == RKRelative

  for subrule in rule.orRulesRef:
    let m = s.match(subrule, rules, isMaster)
    if m != NotFound:
      return m

template match(s: string, ruleId: int, rules: var Table[int, Rule], isMaster = true): untyped =
  match s, rules[ruleId], rules, isMaster

# preprating data ---------------------------------

let
  document = readFile("./test.txt").split("\c\n\c\n")
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
        rule = Rule(
          kind: RKAtcual,
          pattern: rest.strip(chars = {'"'})[0])
      else:
        let ruleNums = rest.split(" | ").mapIt it.splitWhitespace.map parseInt
        rule = Rule(
          kind: RKRelative,
          orRulesRef: ruleNums)

      {ruleNumber: rule}


# code ---------------------------------------

# print rules
# print tests

proc getAns: int =
  when false:
    bbabbbbaabaabba
    babbbbaabbbbbabbbbbbaabaaabaaa
    aaabbbbbbaaaabaababaabababbabaaabbababababaaa
    bbbbbbbaaaabbbbaaabbabaaa
    bbbababbbbaaaaaaaabbababaaababaabab
    ababaaaaaabaaab
    ababaaaaabbbaba
    baabbaaaabbaaaababbaababb
    abbbbabbbbaaaababbbbbbaaaababb
    aaaaabbaabaaaaababaa
    aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
    aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba

    bbabbbbaabaabba
    aaabbbbbbaaaabaababaabababbabaaabbababababaaa
    ababaaaaaabaaab
    ababaaaaabbbaba
    baabbaaaabbaaaababbaababb
    aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
  
  # echo (tests.filterIt it.match(0, rules) != NotFound).join("\n")
  tests.countIt it.match(0, rules) != NotFound


block part1:
  echo getAns()

block part2:
  rules[8].orRulesRef = @[@[42], @[42, 8]]
  rules[11].orRulesRef = @[@[42, 31], @[42, 11, 31]]

  echo getAns()

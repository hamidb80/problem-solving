import sequtils, tables, algorithm

# prepare ------------------------------------

const
  scoreMap1 = {
    ')': 3,
    ']': 57,
    '}': 1197,
    '>': 25137,
  }.toTable

  opens = ['(', '[', '{', '<']
  closes = [')', ']', '}', '>']
  openCloseMap = zip(opens, closes).toTable

# implement ----------------------------------

func syntaxErrorScore(lines: seq[string], incomplete: static bool): int =
  when incomplete:
    var scores: seq[int]

  for l in lines:
    var stack: seq[char]
    block task:
      for c in l:
        if c in opens:
          stack.add openCloseMap[c]
        elif c == stack[^1]:
          stack.del stack.high
        else:
          result.inc scoreMap1[c]
          break task

      when incomplete:
        scores.add 0
        for n in stack.mapIt(closes.find(it) + 1).reversed:
          scores[^1] = scores[^1] * 5 + n

  when incomplete:
    scores.sorted[scores.len div 2]


# go -----------------------------------------

let content = lines("./input.txt").toseq
echo syntaxErrorScore(content, false) # 311949
echo syntaxErrorScore(content, true) # 3042730309

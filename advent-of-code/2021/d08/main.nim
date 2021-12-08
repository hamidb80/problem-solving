import sequtils, strutils, math, tables, algorithm, sets

# prepare ------------------------------------

type
  Pattern = HashSet[char]

  Input = tuple
    signalPatterns: seq[Pattern]
    output: seq[Pattern]

  WireTable = Table[char, char]

const
  wi1 = 0 # wi => wire index
  wi7 = 1
  wi4 = 2
  wi8 = 3

  numberSegments = [
    "abcefg",
    "cf",
    "acdeg",
    "acdfg",
    "bcdf",
    "abdfg",
    "abdefg",
    "acf",
    "abcdefg",
    "abcdfg",
  ].mapIt it.toHashSet

  uniqLens = [1, 4, 7, 8].mapIt(numberSegments[it].len)



# utils --------------------------------------

func parseLine(line: string): Input =
  let s = line.split('|').mapIt it.strip.splitWhitespace
  (s[0].mapit it.toHashSet, s[1].mapIt(it.toHashSet))

func getOne[T](s: HashSet[T]): T=
  for i in s:
    return i

# implement ----------------------------------

func countUniqs(data: seq[Input]): int =
  sum data.mapIt do:
    it.output.countIt(it.len in uniqLens)

func extractSpecials(signalPatterns: seq[Pattern]): seq[Pattern] {.inline.}=
  signalPatterns.filterIt(it.len in uniqLens).sorted do (s1, s2: Pattern) -> int:
    cmp s1.len, s2.len

func detectWireTable(patterns: seq[Pattern]): WireTable =
  # w: wire, ws: wires
  # p: pattern
  let 
    specials = extractSpecials patterns
    ws_cf = specials[wi1]
    ws_bcdf = specials[wi4]
    ws_acf = specials[wi7]
    all = specials[wi8]
    
    w_a = ws_acf - ws_cf

    ps_069 = patterns.filterIt(it.len == 6)
    ps_235 = patterns.filterIt(it.len == 5)
    ws_abfg = ps_069.foldl a * b
    ws_adg = ps_235.foldl a * b
    ws_cde = all - ws_abfg
    w_d = ws_adg - ws_abfg
    w_f = ws_cf - ws_cde
    w_c = ws_cf - w_f
    w_e = ws_cde - (w_c + w_d)
    w_b = (ws_abfg - ws_adg) - w_f
    w_g = ws_adg - (w_a + w_d)

  totable {
    getOne w_a: 'a',
    getOne w_b: 'b',
    getOne w_c: 'c',
    getOne w_d: 'd',
    getOne w_e: 'e',
    getOne w_f: 'f',
    getOne w_g: 'g',
  }

func resolveDigit(digit: Pattern): int=
  for i, segs in numberSegments.pairs:
    if segs == digit:
      return i

  # raise newException(ValueError, "not matched >> " & digit.toseq.sorted.join)

func transformSegs(digit: Pattern, wt: WireTable): Pattern=
  for seg in digit:
    result.incl wt[seg]

func genNumber(digits: seq[Pattern]): int=
  digits.map(resolveDigit).join.parseInt

func sumOutputs(data: seq[Input]): int =
  sum data.mapIt do:
    let wt = it.signalPatterns.detectWireTable
    it.output.mapIt(it.transformSegs wt).genNumber()

# go -----------------------------------------

let content = lines("./input.txt").toseq.map(parseLine)
echo countUniqs(content)
echo sumOutputs(content)

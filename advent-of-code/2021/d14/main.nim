import sequtils, strutils, tables, strscans

# prepare ------------------------------------

type
  Element = char
  Formula = seq[Element]
  ElementPair = array[2, Element] # is always ordered
  PairInsertions = TableRef[ElementPair, Element]

  Data = tuple
    formula: Formula
    pairInsertions: PairInsertions

template `~`(val, castType): untyped =
  cast[castType](val)

# utils --------------------------------------

func toElementPair(a: openArray[Element]): ElementPair =
  [a[0], a[1]]

func parsePairInsertion(s: string): tuple[between: ElementPair, insert: Element] =
  var e: array[3, char] # e: elements
  assert scanf(s, "$c$c -> $c", e[0], e[1], e[2])
  ([e[0], e[1]], e[2])

func parseInput(inp: sink string): Data =
  let s = inp.split("\r\n\r\n")
  result.formula = s[0] ~ seq[Element]
  result.pairInsertions = newTable[ElementPair, Element]()

  for pi in s[1].splitLines:
    let t = pi.parsePairInsertion
    result.pairInsertions[t.between] = t.insert

func genPairCountTable(form: Formula): CountTable[ElementPair] =
  for i in 1..form.high:
    result.inc form[(i-1)..i].toElementPair

# implement ----------------------------------

func polymerize(
  elementPairs: CountTable[ElementPair], pis: PairInsertions
): CountTable[ElementPair] =

  for (ep, c) in elementPairs.pairs:
    let insertation = pis[ep]
    result.inc [ep[0], insertation], c
    result.inc [insertation, ep[1]], c

func minMaxDiffAfter(
  elementPairs: CountTable[ElementPair], pis: PairInsertions, times: int
): int =
  var myElementPairs = elementPairs

  for _ in 1..times:
    myElementPairs = polymerize(myElementPairs, pis)

  var elementCount = initCountTable[Element]()
  for (elemPair, c) in myElementPairs.pairs:
    elementCount.inc elemPair[0], c
    elementCount.inc elemPair[1], c

  let c = elementCount.values.toseq
  (c.max - c.min) div 2 + 1

# go -----------------------------------------

let content = readFile("./input.txt").parseInput
echo minMaxDiffAfter(content.formula.genPairCountTable, content.pairInsertions, 10) # 3411
echo minMaxDiffAfter(content.formula.genPairCountTable, content.pairInsertions, 40) # 7477815755570

import strutils, tables, sets, hashes

# functionalities ------------------------------------------------

type Bag = object
  count: int
  color: string

func hash(b: Bag): Hash = hash b.color
func `==`(a, b: Bag): bool = a.color == b.color

func parseBags(bags: seq[string]): HashSet[Bag] =
  for bag in bags:
    let words = bag.splitWhitespace

    if words[0] != "no":
      result.incl Bag(
        count: words[0].parseInt,
        color: words[1 ..< ^1].join " ")

func parseRule(line: string): tuple[mainBagColor: string, bags: HashSet[Bag]] =
  let
    ls = line.split " bags contain "

  (ls[0], (ls[1].split ',').parseBags)

# preparing data -------------------------------------------------

var rules: Table[string, HashSet[Bag]]
const targetBag = Bag(color: "shiny gold", count: 1)
for line in "./input.txt".lines:
  let rule = line.parseRule
  rules[rule.mainBagColor] = rule.bags

# code -----------------------------------------------------------

func isParentOf(
  table: var Table[string, HashSet[Bag]],
  visited: var HashSet[Bag],
  target: Bag,
  ) =

  for parentColor, subBags in table:
    let cb = Bag(color: parentColor)
    if cb notin visited and target in subBags:
      visited.incl cb
      isParentOf(table, visited, cb)

block part1:
  var visited: HashSet[Bag]
  isParentOf(rules, visited, targetBag)
  echo visited.len

func countSubBags(
  table: var Table[string, HashSet[Bag]],
  target: Bag
  ): int =

  var c = 0
  for subBag in table[target.color]:
    c += countSubBags(table, subBag)

  target.count * (c+1)

block part2:
  echo countSubBags(rules, targetBag) - 1

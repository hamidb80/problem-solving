import sequtils, strutils, tables, sets, hashes
# import print

# functionalities ------------------------------------------------

type Bag = object
  count: int
  color: string

func hash(b: Bag): Hash =
  hash b.color

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
for line in "./input.txt".lines:
  let rule = line.parseRule
  rules[rule.mainBagColor] = rule.bags

# code -----------------------------------------------------------

block part1:
  const myColor = "shiny gold"
  discard

block part2:
  discard

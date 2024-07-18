## advent of code 2023 day 4 - nim

import std/[sequtils, strutils, math]


type
  Card = tuple
    winning, matching: seq[int]


func extractNumbers(s: string): seq[int] =
  for n in s.split:
    try:
      result.add parseInt n
    except:
      discard

func parseInput(s: string): seq[Card] =
  for l in splitLines strip s:
    let temp = l.split('|').map extractNumbers
    result.add (temp[0], temp[1])


func countMatching(a, b: seq): Natural =
  for i in a:
    if i in b:
      inc result

func point(n: Natural): Natural =
  case n
  of 0: 0
  else: 1 shl (n-1)


func part1(inp: seq[Card]): int =
  for (a, b) in inp:
    result.inc point countMatching(a, b)

func part2(inp: seq[Card]): int =
  var cards = newSeqWith(inp.len, 1)
  for i, (a, b) in inp:
    for n in 1 .. countMatching(a, b):
      inc cards[i+n], cards[i]
  sum cards


when isMainModule:

  let data = parseInput:
    readfile"./d04.dat"
    # """
    # Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    # Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    # Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    # Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    # Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    # Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    # """

  stdin.readLine.echo # without this line MS Windows 10 detects the code as virus :-/
  (data.part1, data.part2).echo

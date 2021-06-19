import sequtils, strutils
import npeg, with

# defines ----------------------------------------------------

type Rule = object
  least: int
  most: int
  character: char
  password: string

const ruleParrser = peg("row", d: Rule):
  row <- >+Digit * '-' * >+Digit * ' ' * >Alpha * ": " * >+Alpha:
    with d:
      least = parseInt $1
      most = parseInt $2
      character = ($3)[0]
      password = $4

# functionalities ----------------------------------------------

proc matchRule(s: string): Rule =
  var data: Rule
  doAssert ruleParrser.match(s, data).ok
  data

func checkCharAtStringIndex(s: string, c: char, i: int): bool =
  return i < s.len and s[i] == c

template specialCheck(s: string, c: char, i1, i2: int): bool =
  checkCharAtStringIndex(s, c, i1) xor checkCharAtStringIndex(s, c, i2)

# code --------------------------------------------

let rules = "./input.txt".readFile.splitLines.mapIt it.matchRule

block part1:
  echo rules.countIt(block:
    let c = it.character
    it.password.countIt(it == c) in it.least..it.most)

block part2:
  echo rules.countIt it.password.specialCheck(it.character, it.least - 1,
      it.most - 1)

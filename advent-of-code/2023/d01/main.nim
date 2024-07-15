import std/[strutils, nre, strformat, sequtils]

# def ----------------------------------------

const
  numbers = split "one two three four five six seven eight nine 1 2 3 4 5 6 7 8 9"

# utils --------------------------------------

func makeNumber(digits: openArray[int], base = 10): int =
  for d in digits:
    result = result * base + d

func toDigit(number: string): int =
  case number
  of "1", "one":   1
  of "2", "two":   2
  of "3", "three": 3
  of "4", "four":  4
  of "5", "five":  5
  of "6", "six":   6
  of "7", "seven": 7
  of "8", "eight": 8
  of "9", "nine":  9
  else: raise newException(ValueError, "invalid number: " & number)


# implement ----------------------------------

func resolver1(line: string): auto =
  let temp = findAll(line, re"\d")
  [temp[0], temp[^1]]

func resolver2(line: string): auto =
  let
    rawpat      = numbers.join "|"
    headPattern = re fmt"({rawpat}).*$"
    tailPattern = re fmt"^.*({rawpat})"

    first = find(line, headPattern)
    last  = find(line, tailPattern)
  [first.get.captures[0], last.get.captures[0]]


func flow(s: string, fn: proc(line: string): array[2, string]): int {.effectsOf: fn.} =
  for line in splitLines s:
    inc result, makeNumber map(fn(line), toDigit)

# go -----------------------------------------

let data = readFile "./input.txt"
echo flow(data, resolver1) # 54331
echo flow(data, resolver2) # 54518

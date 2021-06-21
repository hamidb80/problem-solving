import sequtils, strutils, nre, tables

type Passport = Table[string, string]

proc exportData(p: string): Passport =
  for match in (p.findIter re"(\w+):([#\w]+)"):
    result[match.captures[0]] = match.captures[1]

func isNumberic(s: string): bool =
  try:
    discard s.parseInt
    true
  except:
    false

template checkIfDigitInRange(s: string, rng: HSlice[int, int]): untyped =
  s.isNumberic and s.parseInt in rng

template check(pred: untyped): untyped =
  if not pred:
    return false

func hasFields(p: Passport): bool =
  const mustHaveKeys = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
  mustHaveKeys.allIt p.hasKey it

func isValid(p: Passport): bool =
  check p["byr"].checkIfDigitInRange(1920 .. 2002)
  check p["iyr"].checkIfDigitInRange(2010 .. 2020)
  check p["eyr"].checkIfDigitInRange(2020 .. 2030)
  check p["hcl"].match(re"#[a-f0-9]{6}").isSome
  check p["ecl"] in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
  # a nine-digit number, including leading zeroes.
  check p["pid"].len == 9
  check p["pid"].isNumberic
  check p["hgt"].len >= 3

  let
    unit = p["hgt"][^2..^1]
    value = p["hgt"][0..^3]

  check value.isNumberic
  check (case unit:
    of "cm": value.parseInt in 150 .. 193
    of "in": value.parseInt in 59 .. 76
    else: false)

  true

# code ----------------------------------------

var passports =
  ("./2020/d4/input.txt".readFile.split "\c\n\c\n").mapIt it.exportData

block part1:
  passports = passports.filterIt it.hasFields
  echo passports.len

block part2:
  echo passports.countIt it.isValid

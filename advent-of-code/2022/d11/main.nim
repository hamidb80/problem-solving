import std/[sequtils, deques, strutils, tables, algorithm, math, unittest, sugar]

# def ----------------------------------------

type
  NumberKind = enum
    raw
    moduled

  Number = object
    case kind: NumberKind
    of raw:
      value: int
    of moduled:
      modulos: Table[int, int]

  Monkey = object
    id: int
    items: Deque[Number]
    operation: seq[string]
    test: int
    action: array[bool, int]

# utils --------------------------------------

template valErr(msg): untyped =
  raise newException(ValueError, msg)

func toNumber(v: int): Number =
  Number(kind: raw, value: v)

func resolve(current: Number, val: string): Number =
  case val
  of "old": current
  else: toNumber parseInt val

func normalize(n: var Number) =
  for k, v in n.modulos.mpairs:
    v = v mod k
    if v < 0:
      v += k

func toNumber(n: int, modulos: seq[int]): Number =
  result = Number(kind: moduled)

  for m in modulos:
    result.modulos[m] = n

  result.normalize

template termWise(n, action): untyped =
  var acc = n

  for k {.inject.}, v {.inject.} in acc.modulos.mpairs:
    v = action

  acc.normalize
  acc

func `*`(n: Number, m: int): Number =
  termWise(n, v * m)

func `*`(n, m: Number): Number =
  case m.kind
  of raw: n * m.value
  of moduled: termWise(n, v * m.modulos[k])

func `+`(n, m: Number): Number =
  case m.kind
  of raw: termWise(n, v + m.value)
  of moduled: termWise(n, v + m.modulos[k])

func `mod`(n: Number, m: int): int =
  n.modulos[m]

func remOn(n1, n2, r1, r2: int): int =
  ## n: number, r: reminder
  let
    u1 = n2 * r1
    u2 = n1 * r2

    m = n1 * n2

  var
    r = u2 - u1
    a = n1 - n2

  if a < 0:
    a *= -1
    r *= -1

  while r mod a != 0:
    r += m

  r div a

func `div`(n: Number, d: int): Number =
  result = n

  if d != 1:
    for m, r in result.modulos.mpairs:
      if d != m:
        r = remOn(m, d, r, n mod d) div d

    result.modulos[d] = 0 # 90 / 3 = 30    30 mod 3 == 0 ????

func eval(current: Number, operation: seq[string]): Number =
  let
    left = resolve(current, operation[0])
    operator = operation[1]
    right = resolve(current, operation[2])

  case operator
  of "*": left * right
  of "+": left + right
  else: valErr "not supported"

iterator parseMonkeys(s: string): Monkey =
  var monkey: Monkey

  for l in s.splitLines:
    if l.startsWith "Monkey":
      monkey.id = parseInt l[7..^2]

    elif l == "":
      yield monkey

    else:
      let
        parts = l.split(": ")
        property = parts[0]
        value = parts[1]

      case property:
      of "  Starting items":
        monkey.items =
          value
          .split(", ")
          .map(parseInt)
          .map(toNumber)
          .toDeque

      of "  Operation":
        monkey.operation = value[6..^1].split " "

      of "  Test":
        monkey.test = parseInt value["divisible by ".len..^1]

      of "    If true":
        monkey.action[true] = parseInt value["throw to monkey ".len..^1]

      of "    If false":
        monkey.action[false] = parseInt value["throw to monkey ".len..^1]

      else:
        valErr parts[0]

  yield monkey

# implement ----------------------------------

func sumOf2MostInspections(monkeys: seq[Monkey], rounds: int): int =
  var
    mks = monkeys
    inspections = newseq[int](mks.len)

  let tests = mks.mapIt(it.test)

  for m in mks.mitems:
    for i in m.items.mitems:
      i = toNumber(i.value, tests)

  for r in 1..rounds:
    for m in mks.mitems:
      while m.items.len != 0:
        let item = m.items.popFirst
        inspections[m.id].inc

        let
          worry = eval(item, m.operation)
          answer = worry mod m.test == 0

        mks[m.action[answer]].items.addLast worry

    when defined debug:
      if r in [1, 20] or r mod 1000 == 0:
        debugEcho "\n:: ROUND ", r
        debugEcho "inspections: ", inspections

        for m in mks:
          debugEcho "Monkey ", m.id, ": ", m.items.mapIt it.modulos

  inspections.sort
  inspections[^2..^1].foldl a * b

# go -----------------------------------------

suite "number":
  test "*":
    let n = toNumber(20, @[17, 13, 3])
    check n.modulos == toTable {17: 3, 13: 7, 3: 2}
    check (n + 2.toNumber).modulos == toTable {17: 5, 13: 9, 3: 1}

  test "rem on":
    check remOn(17, 3, 4, 1) == 4
    check remOn(3, 17, 1, 4) == 4

  test "div":
    let n = toNumber(55, @[17, 13, 3])
    check (n div 3).modulos == toTable {17: 1, 13: 5, 3: 0}
    check (n div 13).modulos == toTable {17: 4, 13: 0, 3: 1}

# test -----------------------------------------

let data = "./input.txt".readFile.parseMonkeys.toseq
echo data.sumOf2MostInspections(10000) # 19573408701 | part2

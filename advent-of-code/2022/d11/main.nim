import std/[sequtils, deques, strutils, tables, algorithm, math]
import emath
# import bigints

# def ----------------------------------------

type
  Monkey = object
    id: int
    items: Deque[int]
    operation: EMathNode
    test: int
    action: array[bool, int]

# utils --------------------------------------

template parseMath(e): untyped =
  emath.parse e

template valErr(msg): untyped =
  raise newException(ValueError, msg)

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
        monkey.items = value.split(", ").map(parseInt).toDeque

      of "  Operation":
        monkey.operation = parseMath value

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

const noFn = EMathFnLookup()

func vars(old: int): EMathVarLookup =
  toTable {"old": old.toFloat}

func test(monkeys: seq[Monkey], rounds, worryDiv: int): int =
  var
    mks = monkeys
    inspections = newseq[int](mks.len)

  for r in 1..rounds:
    for m in mks.mitems:
      while m.items.len != 0:
        let item = m.items.popFirst
        inspections[m.id].inc

        let
          worry = m.operation.right.eval(vars item, noFn)
          after = worry.toInt div worryDiv
          answer = after mod m.test == 0

        mks[m.action[answer]].items.addLast after

    # if r < 10:# or r mod 1000 == 0:
    # debugEcho "\n:: ROUND ", r
    # debugEcho "inspections: ", inspections
    # for m in mks:
    #   debugecho m.id, " : ", m.items

  inspections.sort
  # debugEcho inspections
  inspections[^2..^1].foldl a * b

# go -----------------------------------------

let data = "./test.txt".readFile.parseMonkeys.toseq
echo test(data, 20, 3)
# echo test(data, 10000, 1)

import std/[sequtils, deques, strutils, tables, algorithm, math]
import bigints

# def ----------------------------------------

type
  Item = BigInt

  Monkey = object
    id: int
    items: Deque[Item]
    operation: seq[string]
    test: int
    action: array[bool, int]


# utils --------------------------------------

template valErr(msg): untyped =
  raise newException(ValueError, msg)

func resolve(current: BigInt, val: string): Bigint = 
  case val
  of "old": current
  else: initBigInt val

func eval(current: BigInt, operation: seq[string]): BigInt =
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
        monkey.items = value.split(", ").mapit(initBigInt it).toDeque

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
          worry = eval(item, m.operation)
          after = worry div worryDiv.initBigInt
          answer = after mod m.test.initBigInt == 0.initBigInt

        mks[m.action[answer]].items.addLast after

    if r in [1, 20] or r mod 1000 == 0:
      debugEcho "\n:: ROUND ", r
      debugEcho "inspections: ", inspections
      for m in mks:
        debugecho m.id, " : ", m.items

  inspections.sort
  # debugEcho inspections
  inspections[^2..^1].foldl a * b

# go -----------------------------------------

let data = "./test.txt".readFile.parseMonkeys.toseq
echo test(data, 20, 3)
echo test(data, 10000, 1) # numbers gets too large to compute ...

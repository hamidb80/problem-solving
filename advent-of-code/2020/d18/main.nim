import sugar, strutils, math, sequtils
import print

# data structure ------------------------------

const NoOperator = ' '

type
  MOKinds = enum # Math Object kind
    MONumber
    MOOpera
    MOPar

  MathObj = ref object
    case kind: MOKinds
    of MOPar:
      children: seq[MathObj]
    of MOOpera:
      operator: char
    of MONumber:
      number: int

# functionalities ---------------------------------------

func extractIfYouCan(m: MathObj): MathObj {.inline.}=
  if m.kind == MOPar and m.children.len == 1:
    m.children[0]
  else:
    m

func parseMath(line: string): MathObj =
  result = MathObj(kind: MOPar)

  var
    parDepth = 0
    lastIndex = -1

  template add(mathobj): untyped =
    result.children.add mathobj

  for i, c in line:
    case c:
    of ' ': continue
    of '(':
      parDepth.inc
      if pardepth == 1:
        lastIndex = i
    of ')':
      parDepth.dec
      if parDepth == 0:
        add parseMath line[lastIndex+1..i-1]

    elif parDepth == 0:
      case c:
      of '+', '*':
        add MathObj(kind: MOOpera, operator: c)
      of '0'..'9':
        add MathObj(kind: MONumber, number: parseInt $c)
      else:
        raise newException(ValueError, "undefined character")
    else: discard

  result = extractIfYouCan result

func calculate(expression: MathObj): int =
  doAssert expression.kind == MOPar

  var op = NoOperator

  template doOperation(someNumber): untyped =
    # debugEcho result, op, someNumber
    case op:
    of '*':
      result *= someNumber
    else: # + and NoOperator
      result += someNumber

  for child in expression.children:
    case child.kind:
    of MOPar:
      doOperation child.calculate
    of MOOpera:
      op = child.operator
    of MONumber:
      doOperation child.number

proc applyPriority(expression: MathObj): MathObj =
  ## puting n1 + n2 + ... together inside a par
  result = MathObj(kind: MOPar)
  doAssert expression.kind == MOPar

  var multipicationIndexs: seq[int]
  for i, child in expression.children:
    if child.kind == MOOpera and child.operator == '*':
      multipicationIndexs.add i

  add multipicationIndexs, expression.children.len

  var
    i = 0
    cache: seq[MathObj]

  for index in multipicationIndexs:
    while i < index:
      let child = expression.children[i]
      case child.kind:
      of MOPar:
        cache.add applyPriority child
      else:
        cache.add child

      inc i
    inc i

    result.children.add extractIfYouCan MathObj(kind: MOPar, children: cache)
    if index != expression.children.len:
      result.children.add expression.children[index]

    cache = @[]

  result = extractIfYouCan result

# preparing data ---------------------------------------

var document = collect newseq:
  for line in "./input.txt".lines:
    parseMath line

# code -------------------------------------------------

func sumResult(document: seq[MathObj]): int {.inline.} =
  sum document.mapIt it.calculate

block part1:
  echo sumResult document

block part2:
  let newDoc = document.mapIt it.applyPriority
  # print newDoc

  echo sumResult newDoc

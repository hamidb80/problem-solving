import sugar, strutils, math, sequtils
import print

# data structure ------------------------------

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

func parseMath(line: string): MathObj=
  result = MathObj(kind: MOPar)

  var 
    parDepth = 0
    lastIndex = -1
  
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
        result.children.add parseMath line[(lastIndex+1)..(i-1)]

    elif parDepth == 0:
      case c:
      of '+', '*':
        result.children.add MathObj(kind: MOOpera, operator: c)
      of '0'..'9':
        result.children.add MathObj(kind: MONumber,  number: parseInt $c)
      else:
        raise newException(ValueError, "undefined character")
    else: discard

  if result.children.len == 1: 
    result = result.children[0]

const NoOperator = ' '

func calculate(expression: MathObj): int=
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

func sumResult(document: seq[MathObj]): int {.inline.}=
  sum document.mapIt it.calculate

proc del*[T](x: var seq[T], rng: HSlice[int, int]) {.noSideEffect.} =
  ## Deletes the item in range `rng`
  for i in 1..rng.len:
    del x, rng.a

# preparing data ---------------------------------------

var document = collect newseq:
  for line in "./test.txt".lines:
    parseMath line


# code -------------------------------------------------

block part1:
  echo sumResult document

proc applyPriority(expression: MathObj): MathObj=
  result = MathObj(kind: MOPar)
  doAssert expression.kind == MOPar

  template addPar(newChildren: untyped): untyped =
    result.children.add MathObj(kind: MOPar, children: newChildren)

  var 
    same= 0..0
    lastOp = '+'
  for i, child in expression.children:
    if child.kind == MOOpera:
      if lastOp == '+':
        if child.operator == '+':
          same.b = i + 1

        elif same.a != same.b: # put it inside par
          addPar expression.children[same]
        else:
          result.children.add child

      elif child.operator == '+':
        same = i+1..i+1

      if child.operator == '*': # WHATS GOING ON??
        result.children.add child

      lastOp = child.operator
    
    else:
      if i == expression.children.high:
        if same.len == 1:
          result.children.add expression.children[same.a - 1] # for operator
          result.children.add expression.children[same.a]
        else:
          addPar expression.children[same]

      elif child.kind == MOPar: 
        result.children.add applyPriority child
      elif child.kind == MONumber and lastOp == '*':
        result.children.add child

block part2:
  let newDoc = document.mapIt it.applyPriority
  print newDoc

  echo sumResult document
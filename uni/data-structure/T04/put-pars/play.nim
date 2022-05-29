import std/[strutils, strformat, algorithm]

type
  MathExprKinds = enum
    mekOp
    mekNumber

  MathOperations = enum
    moAdd, moSub
    moMul, moDiv

  MathExpr = ref object
    case kind: MathExprKinds

    of mekOp:
      op: MathOperations
      left, right: MathExpr

    of mekNumber:
      number: int

  MathToken = object
    case kind: MathExprKinds

    of mekOp:
      op: MathOperations

    of mekNumber:
      number: int


const
  priority: array[MathOperations, int] = [0, 0, 1, 1]
  charRepr: array[MathOperations, char] = ['+', '-', '*', '/']


template invalid(reason: string): untyped =
  raise newException(ValueError, reason)


func toInfix(l, r: MathExpr, o: MathToken): MathExpr =
  MathExpr(kind: mekOp, left: l, right: r, op: o.op)

func toMathNumber(t: MathToken): MathExpr =
  MathExpr(kind: mekNumber, number: t.number)


func toOperator(ch: char): MathOperations =
  case ch:
  of '+': moAdd
  of '-': moSub
  of '*': moMul
  of '/': moDiv
  else: invalid "what?"

iterator lex(line: string): MathToken =
  const notSet = -1
  var lastIndex = notSet

  for i, ch in line:
    case ch:
    of '0' .. '9':
      if lastIndex == notSet:
        lastIndex = i

    of '+', '-', '*', '/':
      if lastIndex != notSet:
        yield MathToken(kind: mekNumber, number: parseInt line[lastIndex ..< i])
        lastIndex = notSet

      yield MathToken(kind: mekOp, op: toOperator ch)

    else:
      invalid "invalid character: " & ch

  if lastIndex != notSet:
    yield MathToken(kind: mekNumber, number: parseInt line[lastIndex .. ^1])

proc toPostfix(line: string): seq[MathToken] =
  var operatorStack: seq[MathToken]

  for t in lex line:
    if result.len < 2:
      result.add t

    else:
      case t.kind:
      of mekNumber:
        result.add [t, result.pop]

      of mekOp:
        if operatorStack.len != 0:
          let l = operatorStack[^1]

          if priority[t.op] <= priority[l.op]:
            result.add operatorStack.reversed
            operatorStack.setlen 0

        var i = result.high
        while i != 0:
          let l = result[i]

          if l.kind == mekOp and priority[l.op] < priority[t.op]:
            operatorStack.add result.pop
            dec i

          else:
            result.add t
            break

  result.add operatorStack.reversed

proc parseMathExpr(line: string): MathExpr =
  var myStack: seq[MathExpr]

  for t in toPostfix line:
    case t.kind:
    of mekNumber: myStack.add toMathNumber t
    of mekOp:
      let
        r = myStack.pop
        l = myStack.pop

      myStack.add toInfix(l, r, t)

  myStack[0]

proc `$`(me: MathExpr): string =
  case me.kind:
  of mekNumber: $me.number
  of mekOp: fmt"({me.left}{charRepr[me.op]}{me.right})"


when isMainModule:
  let expr =
    "6/3+12-16/12*9+25"
    # "1*2+3/4"

  # for m in toPostfix expr:
  #   echo m

  echo parseMathExpr expr

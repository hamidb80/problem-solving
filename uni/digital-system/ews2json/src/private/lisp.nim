import std/[strutils, json]


type
  LispNodeKinds* = enum
    lnkSymbol
    lnkInt
    lnkFloat
    lnkString
    lnkList

  ParserStates = enum
    psInitial
    psSymbol, psNumber, psString

  LispNode* = ref object
    case kind*: LispNodeKinds:
    of lnkSymbol: name*: string
    of lnkInt: vint*: int
    of lnkFloat: vfloat*: float
    of lnkString: vstr*: string
    of lnkList: children*: seq[LispNode]


func parseLisp(s: ptr string, startI: int, acc: var seq[LispNode]): int =
  ## return the last index that was there
  var
    state: ParserStates = psInitial
    i = startI
    temp = 0

  template reset: untyped =
    state = psInitial
  template done: untyped =
    return i
  template checkDone: untyped =
    if c == ')':
      return i

  while i <= s[].len:
    let c =
      if i == s[].len: ' '
      else: s[i]

    case state:
    of psString:
      if c == '"' and s[i-1] != '\\':
        acc.add LispNode(kind: lnkString, vstr: s[temp ..< i])
        reset()

    of psSymbol:
      if c in Whitespace or c == ')':
        acc.add LispNode(kind: lnkSymbol, name: s[temp ..< i])
        reset()
        checkDone()

    of psNumber:
      if c in Whitespace or c == ')':
        let t = s[temp ..< i]

        acc.add:
          if '.' in t:
            LispNode(kind: lnkFloat, vfloat: parseFloat t)
          else:
            LispNode(kind: lnkInt, vint: parseInt t)

        reset()
        checkDone()

    of psInitial:
      case c:
      of '(':
        var node = LispNode(kind: lnkList)
        i = parseLisp(s, i+1, node.children)
        acc.add node

      of ')': done()
      of Whitespace: discard

      of {'0' .. '9', '.', '-'}:
        state = psNumber
        temp = i

      of '"':
        state = psString
        temp = i+1

      else:
        state = psSymbol
        temp = i

    i.inc

func parseLisp*(code: string): seq[LispNode] =
  discard parseLisp(unsafeAddr code, 0, result)


func `$`*(n: LispNode): string =
  case n.kind:
  of lnkInt: $n.vint
  of lnkFloat: $n.vfloat
  of lnkString: '"' & n.vstr & '"'
  of lnkSymbol: n.name
  of lnkList: '(' & n.children.join(" ") & ')'

func pretty*(n: LispNode, indentSize = 2): string =
  case n.kind:
  of lnkList:
    if n.children.len == 0: "()"
    else:
      var acc = "(" & $n.children[0]

      for c in n.children[1..^1]:
        acc &= "\n" & pretty(c, indentSize).indent indentSize

      acc & ")\n"

  else: $n


func ident*(n: LispNode): string =
  assert n.kind == lnkList
  assert n.children.len > 0
  assert n.children[0].kind == lnkSymbol
  n.children[0].name

func args*(n: LispNode): seq[LispNode] =
  assert n.kind == lnkList
  assert n.children.len > 0
  n.children[1..^1]

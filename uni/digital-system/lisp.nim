import std/[strutils, sequtils, json, algorithm]
import macros


template err(msg: string): untyped =
  raise newException(ValueError, msg)


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

  LispNode = ref object
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

func parseLisp*(code: string): LispNode =
  result = LispNode(kind: lnkList)
  discard parseLisp(unsafeAddr code, 0, result.children)


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


func ident(n: LispNode): string =
  assert n.kind == lnkList
  assert n.children.len > 0
  assert n.children[0].kind == lnkSymbol
  n.children[0].name

func `%`(n: LispNode): JsonNode =
  case n.kind:
  of lnkInt: %n.vint
  of lnkFloat: %n.vfloat
  of lnkString: %n.vstr
  of lnkSymbol: %n.name
  else: err "nklList is not serilized that way"


type
  RulePathIR = object
    headMatch: bool
    tailMatch: bool
    path: seq[string]
    fn: NimNode

  RulePath = object
    headMatch: bool
    tailMatch: bool
    path: seq[string]
    fn: proc(parent: JsonNode, args: seq[LispNode])


const
  InfixOp = 0
  InfixLeft = 1
  InfixRight = 2

func extractPathImpl(n: NimNode, result: var seq[NimNode]) =
  expectKind n, nnkInfix
  assert n[InfixOp].strVal == "/"

  result.add n[InfixRight]

  if n[InfixLeft].kind == nnkInfix:
    extractPathImpl n[InfixLeft], result
  else:
    result.add n[InfixLeft]

func extractPath(n: NimNode): seq[NimNode] =
  extractPathImpl n, result
  result.reverse

func extractRule(n: NimNode): RulePathIR =
  let pp = extractPath n

  result.headMatch = true
  result.tailMatch = true

  result.path = pp.mapIt:
    if it.kind == nnkPrefix:
      it[1].strval
    else:
      it.strVal

  if result.path[0] == "...":
    delete result.path, 0
    result.headMatch = false

  if result.path[^1] == "...":
    result.tailMatch = false
    del result.path, result.path.high


  let
    parentIdent = ident "parent"
    argsIdent = ident "args"
    code = n[^1]

  result.fn = quote:
    (proc(`parentIdent`: `JsonNode`, `argsIdent`: seq[`LispNode`]) = `code`)

func toCode(rp: RulePathIR): NimNode =
  let
    hm = rp.headMatch
    tm = rp.tailMatch
    p = rp.path
    fn = rp.fn[0]

  quote:
    RulePath(
      headMatch: `hm` == 1,
      tailMatch: `tm` == 1,
      path: @`p`,
      fn: `fn`)


macro parseRules(body: untyped): untyped =
  var rulesList = newTree(nnkBracket)

  for rule in body:
    expectKind rule, nnkInfix
    assert rule.len == 4
    rulesList.add toCode extractRule rule

  let rulesIdent = ident "rules"
  result = quote:
    let `rulesIdent` = `rulesList`

  # echo repr result

parseRules:
  "ENTITY_FILE" / "ENTITY" / "...":
    discard

  "ENTITY_FILE" / "ENTITY" / "OBID":
    discard

  # "ENTITY_FILE" / "ENTITY" / ^"PROPERTIES" / "PROPERTY":
  #   discard

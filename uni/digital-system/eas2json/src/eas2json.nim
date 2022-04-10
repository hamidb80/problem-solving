import std/[strutils, sequtils, json, algorithm, options, strformat]
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

func `%`*(n: LispNode): JsonNode =
  case n.kind:
  of lnkInt: %n.vint
  of lnkFloat: %n.vfloat
  of lnkString: %n.vstr
  of lnkSymbol: %n.name
  else: err "nklList is not serilized this way"

func ident(n: LispNode): string =
  assert n.kind == lnkList
  assert n.children.len > 0
  assert n.children[0].kind == lnkSymbol
  n.children[0].name

func args(n: LispNode): seq[LispNode] =
  assert n.kind == lnkList
  assert n.children.len > 0
  n.children[1..^1]


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
    fn: proc(parent: JsonNode, args: seq[LispNode], path: seq[string]): JsonNode


const
  InfixOp = 0
  InfixLeft = 1
  InfixRight = 2

func extractPathImpl(n: NimNode, result: var seq[NimNode]) =
  assert n[InfixOp].strVal == "/"
  result.add n[InfixRight]

  if n[InfixLeft].kind == nnkInfix:
    extractPathImpl n[InfixLeft], result
  else:
    result.add n[InfixLeft]

func extractPath(n: NimNode): seq[NimNode] =
  case n.kind:
  of nnkInfix:
    extractPathImpl n, result
    result.reversed
  of nnkCall: @[n[0]]
  else: err "how? " & n.repr & " ::: " & $n.kind

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
    pathIdent = ident "path"
    code = n[^1]

  result.fn = quote:
    (proc(
      `parentIdent`: `JsonNode`,
      `argsIdent`: seq[`LispNode`],
      `pathIdent`: seq[string]): `JsonNode` =
      `code`)

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


macro parseRules*(body: untyped): untyped =
  result = prefix(newTree(nnkBracket), "@")

  for rule in body:
    result[1].add toCode extractRule rule

func matchPath(path: seq[string], rule: RulePath): bool {.inline.} =
  let
    hm = rule.headMatch
    tm = rule.tailMatch

  if hm and tm:
    path == rule.path

  elif tm:
    if path.len < rule.path.len:
      false
    else:
      for i in 1 .. rule.path.len:
        if path[^i] != rule.path[^i]:
          return false
      true

  elif hm:
    rule.path == path
    
  else:
    err "this kind of pattern matching is not implmeneted yet"

func findRule(path: seq[string], rules: seq[RulePath]): Option[RulePath] =
  for r in rules:
    if path.matchPath r:
      return some r

func `$`(r: RulePath): string =
  ## debuging purposes
  fmt"{r.path} {r.headMatch} .. {r.tailMatch}"

proc toJsonImpl(
  lnodes: seq[LispNode],
  rules: seq[RulePath],
  parent: var JsonNode,
  path: seq[string]) =

  for ln in lnodes:
    assert ln.kind == lnkList, $ln & " ::: " & $ln.kind

    let
      newPath = path & ln.ident
      r = findRule(newPath, rules)

    if issome r:
      if not r.get.tailMatch:
        var newParent = r.get.fn(parent, ln.args, newpath)
        # echo "^^^^^^^^^6 ", r.get
        # debugecho ">>> ", path, " --> ", newpath
        # debugecho "||| ", $ln.children, " ///"
        toJsonImpl ln.children[1..^1], rules, newParent, newpath

      else:
        discard r.get.fn(parent, ln.args, newpath)

    else:
      err "cannot match ident '" & ln.ident & "'"


proc toJson*(lnodes: seq[LispNode], rules: seq[RulePath]): JsonNode =
  result = %*{}
  toJsonImpl lnodes, rules, result, @[]

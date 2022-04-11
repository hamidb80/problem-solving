import std/[sequtils, json, algorithm, options, strformat]
import macros
import lisp, helper

# ------------------------------

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

  if result.path[^1] == "$":
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

func genCode(rp: RulePathIR): NimNode =
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


func `$`(r: RulePath): string {.used.} =
  ## debuging purposes
  fmt"{r.path} {r.headMatch} .. {r.tailMatch}"

macro parseRules*(body: untyped): untyped =
  result = prefix(newTree(nnkBracket), "@")

  for rule in body:
    result[1].add genCode extractRule rule

func matchPathStep(step, pattern: string): bool {.inline.} =
  if pattern == "*": true
  else: step == pattern

func matchRule(
  path: seq[string],
  rule: RulePath,
  isCall: bool): bool {.inline.} =

  let r =
    if rule.headMatch:
      if path.len != rule.path.len: false
      else:
        for i in 0..path.high:
          if not matchPathStep(path[i], rule.path[i]):
            return false
        true

    elif path.len < rule.path.len: false

    else:
      for i in 1 .. rule.path.len:
        if not matchPathStep(path[^i], rule.path[^i]):
          return false
      true

  r and (isCall == not rule.tailMatch)

func findRule(path: seq[string], rules: seq[RulePath], isCall: bool): Option[RulePath] =
  for r in rules:
    if matchRule(path, r, isCall):
      return some r


proc toJsonImpl(
  lnodes: seq[LispNode],
  rules: seq[RulePath],
  parent: var JsonNode,
  path: seq[string]) =

  for ln in lnodes:
    assert ln.kind == lnkList, $ln & " ::: " & $ln.kind

    let
      newPath = path & ln.ident
      isCall = ln.args.allIt it.kind == lnkList
      r = findRule(newPath, rules, isCall)

    if issome r:
      # echo "^^^^^^^^ ", r.get

      if not r.get.tailMatch:
        var newParent = r.get.fn(parent, ln.args, newpath)
        # echo ">>> ", path, " --> ", newpath
        # echo "||| ", $ln.children, " ///\n\n"
        if newParent != nil:
          toJsonImpl ln.children[1..^1], rules, newParent, newpath

      else:
        discard r.get.fn(parent, ln.args, newpath)

    else:
      err "cannot match ident '" & ln.ident & "'"

proc toJson*(lnodes: seq[LispNode], rules: seq[RulePath]): JsonNode =
  result = %*{}
  toJsonImpl lnodes, rules, result, @[]

# -------------------------------------

func `%`*(n: LispNode): JsonNode =
  case n.kind:
  of lnkInt: %n.vint
  of lnkFloat: %n.vfloat
  of lnkString: %n.vstr
  of lnkSymbol: %n.name
  else: err "nklList is not serilized this way ::: " & $n

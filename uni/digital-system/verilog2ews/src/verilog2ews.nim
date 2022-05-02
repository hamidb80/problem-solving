import std/[os, strutils, json, tables, options, sequtils, strformat]

import mathexpr
# import ews
import vverilog

type LookUp = Table[string, VNode]


proc allModules(filePaths: seq[string]): tuple[modules: seq[VNode],
    lookup: LookUp] =
  for fp in filePaths:
    let nodes = parseVerilog readfile fp
    for n in nodes:
      case n.kind
      of vnkModule:
        result.modules.add n
      of vnkDefine:
        result.lookup[$n.ident] = n.value
      else:
        discard


proc getVfiles(dir: string): seq[string] =
  for p in walkDirRec dir:
    let (_, name, ext) = splitFile p
    if ext == ".v" and not name.startsWith "config":
      result.add p

proc resolveAliasses(s: string, lkp: LookUp): string =
  # FIXME math thingyyyyy uhhhhhh

  for k, v in lkp:
    let repl = '`' & k
    if repl in s:
      return s.replace(repl, $v)
  s


type Internal = tuple
  module, instance: string
  args: seq[string]

func `%`(gate: Internal): JsonNode= 
  %*{
    "module": gate.module,
    "instance": gate.instance,
    "args": gate.args 
  }

let calc = newEvaluator()

func toVNumber(n: SomeNumber): VNode =
  VNode(kind: vnkNumber, digits: $n)

func rng2str(vn: VNode, lookup: LookUp): VNode=
  {.cast(nosideEffect).}:
    let 
      h = calc.eval(resolveAliasses($vn.head, lookup)).toInt.toVNumber
      t = calc.eval(resolveAliasses($vn.tail, lookup)).toInt.toVNumber

    VNode(kind: vnkRange, head: h, tail: t)
    
func genJson(m: VNode, definedLookups: LookUp): JsonNode =

  var
    lookup = definedLookups

    inputs, outputs, registers: seq[string]
    params: seq[string]
    internals: seq[Internal]

  for p in m.params:
    params.add $p

  for vn in m.children[^1].children:
    case vn.kind:
    of vnkDeclare:
      let bus =
        if issome vn.bus:
          '[' & $vn.bus.get & ']'
        else:
          ""
      for id in vn.idents:
        if id.kind == vnkBracketExpr:
          id.index = rng2str(id.index, lookup)

        let pp = bus & $id

        case vn.dkind:
        of vdkInput:
          inputs.add pp

        of vdkOutput:
          outputs.add pp

        of vdkInOut:
          inputs.add pp
          outputs.add pp

        else:
          registers.add pp

    of vnkDefine:
      lookup[$vn.ident] = vn.value

    of vnkInstanciate:
      internals.add ($vn.module, $vn.instanceIdent, vn.children.mapit($it))

    else:
      discard

  %*{
    "name": $m.name,
    "params": params,
    "inputs": inputs,
    "outputs": outputs,
    "registers": registers,
    "internals": internals
  }


proc genJsonFrom(dir: string): JsonNode =
  result = %*[]
  let (modules, lookup) = allModules getVfiles dir

  for m in modules:
    result.add genJson(m, lookup)


when isMainModule:
  echo pretty genJsonFrom "./temp"

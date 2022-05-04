import std/[os, strutils, tables, options, sequtils, sets]

import mathexpr
# import ews
import vverilog
import print

# ----------------------------------------------

template err(msg): untyped =
  raise newException(ValueError, msg)

# let calc = newEvaluator()

# func rng2str(vn: VNode, lookup: LookUp): VNode =
#   {.cast(nosideEffect).}:
#     let
#       h = calc.eval(resolveAliasses($vn.head, lookup)).toInt.toVNumber
#       t = calc.eval(resolveAliasses($vn.tail, lookup)).toInt.toVNumber

#     VNode(kind: vnkRange, head: h, tail: t)


# proc getVfiles(dir: string): seq[string] =
#   for p in walkDirRec dir:
#     let (_, name, ext) = splitFile p
#     if ext == ".v" and not name.startsWith "config":
#       result.add p


type
  LookUp = Table[string, VNode]
  
  PortDir = enum
    pdInput, pdOutput

  Instantiation = object
    name, module: string
    args: seq[string]

  VModule = object
    name: string
    ports: seq[tuple[kind: PortDir, name: string]]
    inputs, outputs: HashSet[string]
    registers: seq[string]
    internals: seq[Instantiation]
    defines: LookUp

func extractModule(m: VNode): VModule =
  let params = m.params.mapIt $it
  result.name = $m.name

  for vn in m.children[^1].children:
    result.ports.setLen params.len

    case vn.kind:
    of vnkDeclare:
      for id in vn.idents:
        let name = $id

        template addPort(kind, label): untyped =
          result.ports[params.find label] = (kind, label)

        case vn.dkind:
        of vdkInput:
          addPort pdInput, name
          result.inputs.incl name

        of vdkOutput:
          addPort pdOutput, name
          result.outputs.incl name

        of vdkInOut:
          err "'inout' is not supported"

        else:
          result.registers.add name

    of vnkDefine:
      result.defines[$vn.ident] = vn.value

    of vnkInstanciate:
      result.internals.add Instantiation(
        module: $vn.module,
        name: $vn.instanceIdent,
        args: vn.children.mapit $it)

    else:
      discard


proc allModules(filePaths: openArray[string]):
  tuple[modules: seq[VModule], lookup: LookUp] =

  for fp in filePaths:
    let nodes = parseVerilog readfile fp
    for n in nodes:
      case n.kind
      of vnkDefine:
        result.lookup[$n.ident] = n.value
      of vnkModule:
        result.modules.add extractModule n
      else:
        discard


# ------------------------------------------

when isMainModule:
  print allModules ["./temp/sample.v"]

import std/[os, strutils, tables, options, sequtils, sets, options]

# import mathexpr
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

  Lvl = object
    inputsDepth: seq[Option[int]]

  VModule = object
    ports: seq[tuple[kind: PortDir, name: string]]
    # inputs, outputs: HashSet[string]
    registers: HashSet[string]
    internals: seq[Instantiation]
    defines: LookUp

  ModulesMap = Table[string, VModule]


  # Point = tuple[x,y: int]
  # Line = HSlice[Point, Point]
  # Wire = seq[Line]

  BluePrint = object
    map: seq[seq[Instantiation]]
    # connections: seq[Wire]

template searchPort(m: VModule, pd: PortDir): untyped =
  for p in m.ports:
    if p.kind == pd:
      yield p.name

iterator inputs(m: VModule): lent string =
  searchPort m, pdInput

iterator outputs(m: VModule): lent string =
  searchPort m, pdOutput


func extractModule(m: VNode): VModule =
  let params = m.params.mapIt $it

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
          # result.inputs.incl name

        of vdkOutput:
          addPort pdOutput, name
          # result.outputs.incl name

        of vdkInOut:
          err "'inout' is not supported"

        else:
          result.registers.incl name

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
  tuple[modules: ModulesMap, lookup: LookUp] =

  for fp in filePaths:
    let nodes = parseVerilog readfile fp
    for n in nodes:
      case n.kind
      of vnkDefine:
        result.lookup[$n.ident] = n.value
      of vnkModule:
        result.modules[$n.name] = extractModule n
      else:
        discard

func initConnTable(m: VModule, modules: ModulesMap): Table[string, seq[string]] =
  ## input -> instance names
  for component in m.internals:
    for i, arg in component.args:
      if modules[component.module].ports[i].kind == pdInput:
        if arg notin result:
          result[arg] = @[]

        result[arg].add component.name

func genBlueprint(m: VModule, modules: ModulesMap): BluePrint =
  let conns = initConnTable(m, modules)
  # var intrnls = newSeqOfCap[](m.internals.len)

  for inp in m.inputs:
    discard

# ------------------------------------------

when isMainModule:
  let (modules, globalDefines) = allModules ["./temp/sample.v"]
  print modules

  let bp = genBlueprint(modules["TopLevel"], modules)

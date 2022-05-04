import std/[os, strutils, tables, sequtils, sets, options, lenientops]

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

  Instance = object
    module: string
    args: seq[string]

  InputDepth = seq[Option[int]]

  VModule = object
    ports: seq[tuple[kind: PortDir, name: string]]
    registers: HashSet[string]
    internals: Table[string, Instance]
    defines: LookUp

  ModulesTable = Table[string, VModule]


  BluePrint = seq[seq[string]]
    # connections: seq[Wire]


  Point = tuple[x, y: int]
  Line = HSlice[Point, Point]
  Wire = seq[Line]

  # Component = ref object
  #   width, height: int
  #   inputs, outputs: seq[string]


  Schematic = object
    wires: seq[Wire]


template searchPort(m: VModule, pd: PortDir): untyped =
  for p in m.ports:
    if p.kind == pd:
      yield p.name

iterator inputs(m: VModule): lent string =
  searchPort m, pdInput

iterator outputs(m: VModule): lent string =
  searchPort m, pdOutput


template safe(body): untyped {.used.} =
  {.cast(gcsafe).}:
    {.cast(nosideEffect).}:
      body


func toVModule(m: VNode): VModule =
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

        of vdkOutput:
          addPort pdOutput, name

        of vdkInOut:
          err "'inout' is not supported"

        else:
          result.registers.incl name

    of vnkDefine:
      result.defines[$vn.ident] = vn.value

    of vnkInstanciate:
      result.internals[$vn.instanceIdent] =
        Instance(module: $vn.module, args: vn.children.mapit $it)

    else:
      discard

proc extractModulesFrom(filePaths: openArray[string]):
  tuple[modules: ModulesTable, lookup: LookUp] =

  for fp in filePaths:
    let nodes = parseVerilog readfile fp
    for n in nodes:
      case n.kind
      of vnkDefine:
        result.lookup[$n.ident] = n.value
      of vnkModule:
        result.modules[$n.name] = toVModule n
      else:
        discard

func initConnTable(m: VModule, modules: ModulesTable): Table[string, seq[string]] =
  ## input -> instance names
  for o in m.outputs:
    result[o] = @[]

  for name, component in m.internals:
    for i, arg in component.args:
      if modules[component.module].ports[i].kind == pdInput:
        if arg notin result:
          result[arg] = @[]

        result[arg].add name


func initConnDepth(instances: Table[string, Instance],
    modules: ModulesTable): Table[string, InputDepth] =

  for name, ins in instances:
    result[name] = newSeqWith(modules[ins.module].ports.len, none int)


func genBlueprintImpl(
  inp: string, conns: Table[string, seq[string]],
  m: VModule, modules: ModulesTable,
  depth: int, result: var Table[string, InputDepth]) =

  for insName in conns[inp]:
    ## FIXME set max for loop styles
    result[insName][m.internals[insName].args.find inp] = some depth

    for i, o in m.internals[insName].args:
      if modules[m.internals[insName].module].ports[i].kind == pdOutput:
        genBlueprintImpl o, conns, m, modules, depth+1, result



func genBlueprint(m: VModule, modules: ModulesTable): BluePrint =
  let conns = initConnTable(m, modules)
  # safe print conns

  var insInputsDepth = initConnDepth(m.internals, modules)
  for inp in m.inputs:
    genBlueprintImpl inp, conns, m, modules, 0, insInputsDepth

  var insDepth: Table[string, int]
  for insName, inputsDepth in insInputsDepth:
    insDepth[insName] = inputsDepth.filterIt(issome it).mapIt(it.get).max()

  # safe print insDepth

  for insName, depth in insDepth:
    if depth+1 > result.len:
      result.setlen depth+1

    result[depth].add insName
  # safe print result


# func genComponent

func genLines(points: openArray[Point]): Wire =
  var lp = points[0]

  for i in 1 .. points.high:
    let p = points[i]
    result.add lp..p
    lp = p

func genWire(a, b: Point, bias: range[0.0 .. 1.0]): Wire =
  let 
    dx = b.x - a.x
    o = bias.float
    xcenter= toInt( a.x + dx * o)

  genLines [
    a, (xcenter, a.y), (xcenter, b.y), b
  ]


func genSchematic(m: VModule, bp: BluePrint): Schematic =
  discard

# ------------------------------------------

when isMainModule:
  let (modules, globalDefines) = extractModulesFrom ["./temp/sample.v"]
  # print modules

  let bp = genBlueprint(modules["TopLevel"], modules)
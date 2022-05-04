import std/[os, strutils, tables, sequtils, sets, options, lenientops,
    strformat, oids]

# import mathexpr
import ews
import vverilog
import print

# ----------------------------------------------

template err(msg): untyped =
  raise newException(ValueError, msg)

# let calc = newEvaluator()

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
    xcenter = toInt(a.x + dx * o)

  genLines [
    a, (xcenter, a.y), (xcenter, b.y), b
  ]


# func genSchematic(m: VModule, bp: BluePrint): Schematic =
#   discard

# ------------------------------------------

template s(thing): untyped = toLispSymbol thing
template l(thing): untyped = toLispNode thing

template toLines(seqOfSomething): untyped =
  seqOfSomething.join "\n"


const
  sheet_width = 6000
  sheet_height = 4000

proc `project.eas`(designs: seq[tuple[name, libid: string]]): string =
  let 
    id = $ genoid()
    ds = designs.
      mapIt(newLispList(s "DESIGN", l it.name, l it.libid)).
      toLines

  fmt"""
  (DATABASE_VERSION 17)
  (PROJECT_FILE
    (OBID "proj{id}")
      (PROPERTIES
      (PROPERTY "ArchFileFormatSpec" "%e_%a.%x")
      (PROPERTY "BodyFileFormatSpec" "%e_%a.%x")
      (PROPERTY "ConfigFileFormatSpec" "%e_%c.%x")
      (PROPERTY "EASE_HDL_DEFAULT" "1")
      (PROPERTY "EntityFileFormatSpec" "%e.%x")
      (PROPERTY "FILE_ORG." "1")
      (PROPERTY "HdlFileEncoding" "ISO-Latin1")
      (PROPERTY "ModuleFileFormatSpec" "%e.%x")
      (PROPERTY "PORTORDER" "0")
      (PROPERTY "PROPMAP_VERSION" "1")
      (PROPERTY "PackageFileFormatSpec" "%p.%x")
      (PROPERTY "STAMP_PLATFORM" "PC")
      (PROPERTY "STAMP_REVISION" "Revision 4")
      (PROPERTY "STAMP_TIME" "Wed May 04 11:28:49 2022")
      (PROPERTY "STAMP_TOOL" "Ease")
      (PROPERTY "STAMP_VERSION" "8.0")
      (PROPERTY "VERILOG_VERSION" "Verilog 95")
      (PROPERTY "VHDL_KEYWORDS" "0")
      (PROPERTY "VHDL_SIGNAL" "std_logic")
      (PROPERTY "VHDL_VECTOR" "std_logic_vector")
      (PROPERTY "VHDL_VERSION" "VHDL 93")
      (PROPERTY "VerilogExt" "v")
      (PROPERTY "VerilogFileFormatCase" "As is")
      (PROPERTY "VhdlExt" "vhd")
      (PROPERTY "VhdlFileFormatCase" "As is")
    )
    {ds}
    (PACKAGE
      (OBID "pack{id}")
      (LIBRARY "ieee")
      (NAME "std_logic_1164")
    )
  )
  (END_OF_FILE)
  """

const 
  `toolflow.xml` = readFile "./assets/toolflow.xml"
  `workspace.eas` = readfile "./assets/workspace.eas"


func genLibrary(components: seq[tuple[name, id: string]]): string =
  let cps = components.
    mapIt(newLispList(s"ENTITY", l it.name, l it.id))
    toLines

  fmt"""(DATABASE_VERSION 17)
  (DESIGN_FILE
    (OBID "libf7000010414227260c80b4d258651712")
    (PROPERTIES
      (PROPERTY "OUTPUT_DIR" "design.hdl")
      (PROPERTY "OUTPUT_FILE" "design.vhd")
      (PROPERTY "STAMP_PLATFORM" "PC")
      (PROPERTY "STAMP_REVISION" "Revision 4")
      (PROPERTY "STAMP_TIME" "Wed May 04 11:33:23 2022")
      (PROPERTY "STAMP_TOOL" "Ease")
      (PROPERTY "STAMP_VERSION" "8.0")
    )
    (COMPONENT_LIB 0)
    (NAME "design")
    {cps}
  )
  (END_OF_FILE)
  """

proc genComponent(name: string): string =
  let fileId = $genoid()

  fmt"""(DATABASE_VERSION 17)
  (ENTITY_FILE
    (ENTITY
      (OBID "entf7000010835227260c80b4d289651712")
      (PROPERTIES
        (PROPERTY "STAMP_PLATFORM" "PC")
        (PROPERTY "STAMP_REVISION" "Revision 4")
        (PROPERTY "STAMP_TIME" "Wed May 04 11:33:23 2022")
        (PROPERTY "STAMP_TOOL" "Ease")
        (PROPERTY "STAMP_VERSION" "8.0")
      )
      (HDL_IDENT
        (NAME {name})
        (USERNAME 1)
      )
      (SIDE 0)
      (HDL 1)
      (EXTERNAL 0)
      (OBJSTAMP
        (DESIGNER "HamidB80")
        (CREATED 1651647800 "Wed May 04 11:33:20 2022")
        (MODIFIED 1651647800 "Wed May 04 11:33:20 2022")
      )
      (PORT
        (OBID "eprtf700001065a527260c80b4d2fb651712")
        (PROPERTIES
          (PROPERTY "SensitivityList" "Yes")
        )
        (HDL_IDENT
          (NAME "INP1")
          (USERNAME 1)
          (ATTRIBUTES
            (MODE 1)
          )
        )
        (GEOMETRY -40 88 40 168)
        (SIDE 3)
        (LABEL
          (POSITION 64 128)
          (SCALE 96)
          (COLOR_LINE 0)
          (SIDE 3)
          (ALIGNMENT 3)
          (FORMAT 35)
          (TEXT "INP1")
        )
      )
      (ARCH_DECLARATION 1 "arch{fileId}" "structure")
    )
    (ARCH_DEFINITION
      (OBID "arch{fileId}")
      (HDL_IDENT
        (NAME "structure")
        (USERNAME 1)
      )
      (TYPE 1)
      (SCHEMATIC
        (OBID "diag{fileid}")
        (PROPERTIES
          (PROPERTY "SheetInfoFontSize" "8")
        )
        (SHEETSIZE 0 0 {sheet_width} {sheet_height})
        (PORT
          (OBID "aprtf700001065a527260c80b4d22c651712")
          (HDL_IDENT
            (NAME "INP1")
            (USERNAME 1)
            (ATTRIBUTES
              (MODE 1)
            )
          )
          (GEOMETRY 664 792 744 872)
          (SIDE 1)
          (LABEL
            (POSITION 640 832)
            (SCALE 96)
            (COLOR_LINE 0)
            (SIDE 3)
            (ALIGNMENT 5)
            (FORMAT 35)
            (TEXT "INP1")
          )
          (PORT "eprtf700001065a527260c80b4d2fb651712")
          (CONNECTION
            (OBID "nconf700001065a527260c80b4d23c651712")
            (GEOMETRY 768 832 768 832)
            (SIDE 2)
            (LABEL
              (POSITION 768 864)
              (SCALE 96)
              (COLOR_LINE 0)
              (SIDE 1)
              (ALIGNMENT 0)
              (FORMAT 128)
            )
          )
        )
      )
    )

  )
  (END_OF_FILE)
  """

proc genTopLevel(): string =
  let cmpnts = """
    (COMPONENT
      (OBID "compf7000010835227260c80b4d2a9651712")
      (HDL_IDENT
        (NAME "comp")
        (USERNAME 1)
      )
      (GEOMETRY 1344 768 3008 2624)
      (SIDE 0)
      (LABEL
        (POSITION 1344 704)
        (SCALE 128)
        (COLOR_LINE 0)
        (SIDE 3)
        (ALIGNMENT 6)
        (FORMAT 13)
        (TEXT "comp:c1:structure(B)")
      )
      (ENTITY "libf7000010414227260c80b4d258651712" "entf7000010835227260c80b4d289651712")
      (PORT
        (OBID "cprtf700001065a527260c80b4d20c651712")
        (HDL_IDENT
          (NAME "INP1")
          (USERNAME 1)
          (ATTRIBUTES
            (MODE 1)
          )
        )
        (GEOMETRY 1304 856 1384 936)
        (SIDE 3)
        (LABEL
          (POSITION 1408 896)
          (SCALE 96)
          (COLOR_LINE 0)
          (SIDE 3)
          (ALIGNMENT 3)
          (FORMAT 35)
          (TEXT "INP1")
        )
        (PORT "eprtf700001065a527260c80b4d2fb651712")
        (CONNECTION
          (OBID "nconf700001065a527260c80b4d21c651712")
          (GEOMETRY 1280 896 1280 896)
          (SIDE 0)
          (LABEL
            (POSITION 1280 864)
            (SCALE 96)
            (COLOR_LINE 0)
            (SIDE 3)
            (ALIGNMENT 8)
            (FORMAT 128)
          )
        )
      )
    )
  """

  fmt"""(DATABASE_VERSION 17)
  (ENTITY_FILE
    (ENTITY
      (OBID "entf7000010414227260c80b4d278651712")
      (PROPERTIES
        (PROPERTY "STAMP_PLATFORM" "PC")
        (PROPERTY "STAMP_REVISION" "Revision 4")
        (PROPERTY "STAMP_TIME" "Wed May 04 11:33:23 2022")
        (PROPERTY "STAMP_TOOL" "Ease")
        (PROPERTY "STAMP_VERSION" "8.0")
      )
      (HDL_IDENT
        (NAME "Toplevel")
        (USERNAME 1)
      )
      (GEOMETRY 0 0 576 576)
      (SIDE 0)
      (HDL 1)
      (EXTERNAL 0)
      (OBJSTAMP
        (DESIGNER "HamidB80")
        (CREATED 1651647508 "Wed May 04 11:28:28 2022")
        (MODIFIED 1651647800 "Wed May 04 11:33:20 2022")
      )
      (ARCH_DECLARATION 1 "archf7000010414227260c80b4d288651712" "structure")
    )
    (ARCH_DEFINITION
      (OBID "archf7000010414227260c80b4d288651712")
      (HDL_IDENT
        (NAME "structure")
        (USERNAME 1)
      )
      (TYPE 1)
      (SCHEMATIC
        (OBID "diagf7000010414227260c80b4d268651712")
        (PROPERTIES
          (PROPERTY "SheetInfoFontSize" "8")
        )
        (SHEETSIZE 0 0 6400 4266)
        {cmpnts}
      )
    )
  )
  (END_OF_FILE)

  """



proc genProject(path, projectName: string) =
  let 
    dirPath = path / projectName & ".ews"
    dbPath = dirPath / "ease.db"

  createDir dirPath
  writeFile dirPath / "toolflow.xml", `toolflow.xml`
  writeFile dirPath / "workspace.eas", `workspace.eas`
  
  createDir dbPath 
  writeFile dbPath / "project.eas", ""



# ------------------------------------------

when isMainModule:
  let (modules, globalDefines) = extractModulesFrom ["./temp/sample.v"]
  # print modules

  let bp = genBlueprint(modules["TopLevel"], modules)

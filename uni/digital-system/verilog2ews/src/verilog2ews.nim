import std/[os, strutils, tables, sequtils, sets, options, lenientops,
    strformat, oids]

# import mathexpr
import ews
import vverilog
# import print

import ./conventions

# ----------------------------------------------

type
  ModulesTable = Table[string, VModule]

  VModule = object
    ports: seq[tuple[kind: PortDir, name: string]]
    internals: Table[string, Instance]
    defines: LookUp

  PortDir = enum
    pdInput = 1, pdOutput = 2

  Instance = object
    module: string
    args: seq[string]

  LookUp = Table[string, VNode]



  InputDepth = seq[Option[int]]

  BluePrint = seq[seq[string]]

  Point = tuple[x, y: int]
  Line = HSlice[Point, Point]
  Wire = seq[Line]


  Alignment = enum
    BottomRight = 0
    Bottom = 1
    BottomLeft = 2
    Right = 3
    Center = 4
    Left = 5
    TopRight = 6
    Top = 7
    TopLeft = 8
    # 8 7 6
    # 5 4 3
    # 2 1 0

  Side = enum
    TopToBottom
    RightToLeft
    BottomToTop
    LeftToRight
    #   0
    # 3   1
    #   2

  Color = range[0..71]


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
          discard

    of vnkDefine:
      result.defines[$vn.ident] = vn.value

    of vnkInstanciate:
      result.internals[$vn.instanceIdent] =
        Instance(module: $vn.module, args: vn.children.mapit $it)

    else:
      discard

proc extractModulesFromFiles(filePaths: openArray[string]):
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

func toWire(a, b: Point, bias: range[0.0 .. 1.0]): Wire =
  let
    dx = b.x - a.x
    o = bias.float
    xcenter = toInt(a.x + dx * o)

  genLines [
    a, (xcenter, a.y), (xcenter, b.y), b
  ]

# ------------------------------------------

template s(thing): untyped = toLispSymbol thing
template `~`(thing): untyped = toLispNode thing

template toLines(seqOfSomething): untyped =
  seqOfSomething.join "\n"

# ------------------------------------------

const
  `toolflow.xml` = readFile "./assets/toolflow.xml"
  `workspace.eas` = readfile "./assets/workspace.eas"

proc `project.eas`(designs: seq[tuple[name, obid: string]]): string =
  let
    obid = $genoid()
    libraries = designs.
      mapIt(newLispList(s"DESIGN", ~it.name, ~it.obid)).
      toLines

  fmt"""
  (DATABASE_VERSION 17)
  (PROJECT_FILE
    (OBID "proj{obid}")
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
    {libraries}
    (PACKAGE
      (OBID "pack{obid}")
      (LIBRARY "ieee")
      (NAME "std_logic_1164")
    )
  )
  (END_OF_FILE)
  """

func `library.eas`(obid: string,
  entities: seq[tuple[name, obid: string]]): string =

  let es = entities.
    mapIt(newLispList(s"ENTITY", ~it.name, ~it.obid)).
    toLines

  fmt"""(DATABASE_VERSION 17)
  (DESIGN_FILE
    (OBID "{obid}")
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
    {es}
  )
  (END_OF_FILE)
  """

proc genNet(name: string,
  connection: tuple[head, tail: tuple[componentId, portName: string]],
  wire: Wire): string =

  let
    netid = $genOid()
    name = $genOid()
    partId = $genOid()
    segments = wire.
      mapIt(fmt"(WIRE {it.a.x} {it.a.y} {it.b.x} {it.b.y})").
      toLines

  fmt"""
  (NET
    (OBID "{netid}")
    (HDL_IDENT
      (NAME "{name}")
    )

    (PART
      (OBID "{partId}")

      {segments}    

      (PORT
        (OBID "{connection.head.componentId}")
        (NAME "{connection.head.portName}")
      )
      (PORT
        (OBID "{connection.tail.componentId}")
        (NAME "{connection.tail.portName}")
      )
    )
  )
  """

proc genPort(isDef: bool, name, label: string, pd: PortDir, x, y: int,
    portRefId: string, ): string =
  let
    id = $genOid()
    (offx, offy) =
      if isDef: (0, 0)
      else: (x, y)

    refport = 
      if isDef:
        ""
      else:
        fmt"(PORT {portRefId})"

  fmt"""
  (PORT
    (OBID "{id}")
    (HDL_IDENT
      (NAME "{name}")
      (USERNAME 1)
      (ATTRIBUTES
        (MODE {pd.int})
      )
    )
    (GEOMETRY {offx} {offy} {x} {y})
    (SIDE {LeftToRight.int})
    
    (LABEL
      (POSITION {x} {y})
      (SCALE 100)
      (COLOR_LINE 0)
      (SIDE {LeftToRight.int})
      (ALIGNMENT {Left.int})
      (FORMAT 35)
      (TEXT "{label}")
    )
    
    {refport}
  )
  """

proc genComponent(name, lib, entity: string, label: string,
  x, y, width, height: int): string =

  let
    obid = $genOid()
    ports = ""

  fmt"""
  (COMPONENT
    (OBID "{obid}") 
    (ENTITY "{lib}" "{entity}")

    (HDL_IDENT 
      (NAME "{name}")
      (USERNAME 1)
    )

    (GEOMETRY {x} {y} {x + width} {y + height})
    (SIDE 0)
    (LABEL
      (POSITION {x + width div 2} {y})
      (SCALE 100)
      (COLOR_LINE 0)
      (SIDE 3)
      (ALIGNMENT 7)
      (FORMAT 13)
      (TEXT {label})
    )
    
    { ports }
  )
  """

proc genEntity(entryId, name: string, width, height, sheetWidth,
    sheetHeight: int): string =
  let
    archId = $genOid()
    archTag = "structure"
    schemaId = $genOid()

    portsDef = ""
    portsImpl = ""
    components = ""
    nets = ""

  fmt"""
  (DATABASE_VERSION 17)
  (ENTITY_FILE
    (ENTITY
      (OBID "{entryId}")
      (PROPERTIES
        (PROPERTY "STAMP_PLATFORM" "PC")
        (PROPERTY "STAMP_REVISION" "Revision 4")
        (PROPERTY "STAMP_TIME" "Wed May 04 16:34:31 2022")
        (PROPERTY "STAMP_TOOL" "Ease")
        (PROPERTY "STAMP_VERSION" "8.0")
      )
      
      (HDL_IDENT
        (NAME "{name}")
        (USERNAME 1)
      )
      
      (GEOMETRY 0 0 {width} {height})
      (HDL 1)
      (EXTERNAL 0)
      (OBJSTAMP
        (DESIGNER "hamidb80")
        (CREATED 1651677890 "Wed May 04 19:54:50 2022")
        (MODIFIED 1651677907 "Wed May 04 19:55:07 2022")
      )

      { portsDef }

      (ARCH_DECLARATION 1 "{archId}" "{archTag}")
    )
    (ARCH_DEFINITION
      (OBID "{archId}")
      (HDL_IDENT
        (NAME "{archTag}")
        (USERNAME 1)
      )

      (TYPE 1)
      (SCHEMATIC
        (OBID "{schemaId}")
        (PROPERTIES
          (PROPERTY "SheetInfoFontSize" "8")
        )
        (SHEETSIZE 0 0 {sheetWidth} {sheetHeight})
        { portsImpl }
        { components }
        { nets }
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
  writeFile dbPath / "project.eas", `project.eas`(@[])


proc getVfiles(dirPath: string): seq[string] =
  for p in walkDirRec dirPath:
    let (_, name, ext) = splitFile p
    if ext == ".v" and not name.startsWith "config":
      result.add p


# ------------------------------------------

when isMainModule:
  let (modules, globalDefines) = extractModulesFromFiles ["./temp/sample.v"]
  # print modules

  let bp = genBlueprint(modules["TopLevel"], modules)

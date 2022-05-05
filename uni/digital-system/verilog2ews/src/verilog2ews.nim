import std/[os, strutils, tables, sequtils, sets, options, lenientops,
    strformat, oids]

# import mathexpr
import vverilog
# import print

import ./conventions

# ----------------------------------------------

type
  Point = tuple[x, y: int]
  Size = tuple[width, height: int]
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

  PortDir = enum
    pdInput = 1, pdOutput = 2

# ----------------------------------------------

type
  ModulesTable = Table[string, VModule]

  VModule = object
    ports: seq[tuple[kind: PortDir, name: string]]
    internals: Table[string, Instance]
    defines: LookUp

  Instance = object
    module: string
    args: seq[string]

  LookUp = Table[string, VNode]

  InputDepth = seq[Option[int]]

  BluePrint = seq[seq[string]]


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

func toWire(a, b: Point, foldx: range[0.0 .. 1.0]): Wire =
  let
    dx = b.x - a.x
    o = foldx.float
    xcenter = toInt(a.x + dx * o)

  genLines [
    a, (xcenter, a.y), (xcenter, b.y), b
  ]

# ------------------------------------------

type
  Project = object
    libraries: seq[Library]

  Library = ref object
    obid, name: string
    entities: seq[Entity]

  Entity = ref object
    obid, name: string
    library {.cursor.}: Library

    componentSize, schemaSize: Size
    ports: seq[Port]

    internals: seq[Internal]

  Port {.acyclic.} = ref object
    kind: PortDir
    name, obid: string
    position: Point
    reference: Port

  InternalKinds = enum
    ikNet, ikPort, ikComponent

  Internal = object
    case kind: InternalKinds
    of ikNet: net: Net
    of ikPort: port: Port
    of ikComponent: component: Component

  Component = ref object
    obid, name: string
    position: Point
    entity {.cursor.}: Entity

  Net = ref object
    obid: string
    head, tail: LocalPortAddress

  LocalPortAddress = tuple
    componentId, portName: string


const
  `toolflow.xml` = readFile "./assets/toolflow.xml"
  `workspace.eas` = readfile "./assets/workspace.eas"

proc `project.eas`(libraries: seq[tuple[name, id: string]]): string =
  let
    id = $genoid()
    designs = libraries.
      mapIt(fmt "(DESIGN \"{it.name}\" \"{it.id})\"").
      joinLines

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
    
    {designs}

    (PACKAGE
      (OBID "pack{id}")
      (LIBRARY "ieee")
      (NAME "std_logic_1164")
    )
  )
  (END_OF_FILE)
  """

func `library.eas`(name, obid: string,
  entities: seq[tuple[name, obid: string]]): string =

  let es = entities.
    mapIt(fmt "(ENTITY \"{it.name}\" \"{it.obid}\")").
    joinLines

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
    (NAME "{name}")

    {es}
  )
  (END_OF_FILE)
  """

func genLabel(x, y: int, label: string, side: Side,
    alignment: Alignment, scale = 100, color: Color = 0): string =

  fmt"""(LABEL
    (POSITION {x} {y})
    (SCALE {scale})
    (COLOR_LINE {color})
    (SIDE {side.int})
    (ALIGNMENT {alignment.int})
    (FORMAT 35)
    (TEXT "{label}")
  )
  """

func genIdent(name: string,
  attributes: openArray[tuple[key, value: string]] = @[]): string =

  let attrs = attributes.mapIt(fmt"({it.key} {it.value})").join " "

  fmt"""
  (HDL_IDENT
    (NAME "{name}")
    (USERNAME 1)
    (ATTRIBUTES {attrs})
  )"""

proc genNet(wire: Wire,
  connection: tuple[head, tail: LocalPortAddress]): string =

  let
    netid = $genOid()
    name = $genOid()
    partId = $genOid()

    wireSegments = wire.
      mapIt(fmt"(WIRE {it.a.x} {it.a.y} {it.b.x} {it.b.y})").
      joinLines


  fmt"""
  (NET
    (OBID "{netid}")
    {genIdent name}

    (PART
      (OBID "{partId}")

      {wireSegments}    

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

proc genPort(name, label: string, x, y: int,
  pd: PortDir, isDef: bool, portRefId: string = ""): string =

  let
    id = $genOid()
    (offx, offy) =
      if isDef: (0, 0)
      else: (x, y)

    refport =
      if isDef: ""
      else: fmt "(PORT \"{portRefId}\")"

    lbl = genLabel(x, y, label, LeftToRight, Left)
    hld_ident = genIdent(name, [("MODE", $pd.int)])

  fmt"""
  (PORT
    (OBID "{id}")
    {hld_ident}

    (GEOMETRY {offx} {offy} {x} {y})
    (SIDE {LeftToRight.int})
    {lbl}
    
    {refport}
  )
  """

proc genComponent(name, label, lib, entity: string,
  x, y, width, height: int): string =

  let
    obid = $genOid()
    ports = ""
    lbl = genLabel(x + width div 2, y, label, LeftToRight, Top)

  fmt"""
  (COMPONENT
    (OBID "{obid}") 
    (ENTITY "{lib}" "{entity}")

    {genIdent name}

    (GEOMETRY {x} {y} {x + width} {y + height})
    (SIDE 0)
    
    {lbl}
    {ports}
  )
  """

proc genEntity(obid, name: string,
  width, height, sheetWidth, sheetHeight: int): string =

  let
    archId = $genOid()
    archTag = "structure"
    schemaId = $genOid()

    portsDef = ""
    internals = ""

  fmt"""
  (DATABASE_VERSION 17)
  (ENTITY_FILE
    (ENTITY
      (OBID "{obid}")
      (PROPERTIES
        (PROPERTY "STAMP_PLATFORM" "PC")
        (PROPERTY "STAMP_REVISION" "Revision 4")
        (PROPERTY "STAMP_TIME" "Wed May 04 16:34:31 2022")
        (PROPERTY "STAMP_TOOL" "Ease")
        (PROPERTY "STAMP_VERSION" "8.0")
      )
      
      {genIdent name}
      
      (GEOMETRY 0 0 {width} {height})
      (HDL 1)
      (EXTERNAL 0)
      (OBJSTAMP
        (DESIGNER "hamidb80")
        (CREATED 1651677890 "Wed May 04 19:54:50 2022")
        (MODIFIED 1651677907 "Wed May 04 19:55:07 2022")
      )

      {portsDef}

      (ARCH_DECLARATION 1 "{archId}" "{archTag}")
    )
    (ARCH_DEFINITION
      (OBID "{archId}")
      {genIdent archTag}

      (TYPE 1)
      (SCHEMATIC
        (OBID "{schemaId}")
        (PROPERTIES
          (PROPERTY "SheetInfoFontSize" "8")
        )
        (SHEETSIZE 0 0 {sheetWidth} {sheetHeight})
        {internals}
      )
    )
  )
  (END_OF_FILE)
  """


proc buildProject(path, projectName: string) =
  let
    dirPath = path / projectName & ".ews"
    dbPath = dirPath / "ease.db"

  createDir dirPath
  writeFile dirPath / "toolflow.xml", `toolflow.xml`
  writeFile dirPath / "workspace.eas", `workspace.eas`

  createDir dbPath
  writeFile dbPath / "project.eas", `project.eas`(@[])

# ------------------------------------------

proc getVfiles(dirPath: string): seq[string] =
  for p in walkDirRec dirPath:
    let (_, name, ext) = splitFile p
    if ext == ".v" and not name.startsWith "config":
      result.add p


when isMainModule:
  let (modules, globalDefines) = extractModulesFromFiles ["./temp/sample.v"]
  # print modules

  let bp = genBlueprint(modules["TopLevel"], modules)

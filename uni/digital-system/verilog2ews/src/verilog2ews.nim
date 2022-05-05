import std/[os, strutils, tables, sequtils, sets, options, lenientops,
    strformat, oids, sugar]

# import mathexpr
import vverilog
import print

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

func `+`(p1, p2: Point): Point =
  (p1.x + p2.x, p1.y + p2.y)

func `+=`(p1: var Point, p2: Point) =
  p1.x += p2.x
  p1.y += p2.y

# ----------------------------------------------

type
  ModulesTable = Table[string, VModule]

  VModule = object
    ports: seq[tuple[dir: PortDir, name: string]]
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
    if p.dir == pd:
      yield p.name

iterator inputs(m: VModule): lent string =
  searchPort m, pdInput

iterator outputs(m: VModule): lent string =
  searchPort m, pdOutput

func splitPorts(m: VModule): tuple[inputs, outputs: seq[string]] =
  for p in m.ports:
    case p.dir:
    of pdInput: result.inputs.add p.name
    of pdOutput: result.outputs.add p.name


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
      if modules[component.module].ports[i].dir == pdInput:
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
      if modules[m.internals[insName].module].ports[i].dir == pdOutput:
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
  Project = seq[Library]

  Library = ref object
    obid, name: string
    entities: Table[string, Entity]

  Entity = ref object
    obid, name: string
    library {.cursor.}: Library

    componentSize, schemaSize: Size
    ports: seq[Port]

    structure: Structure

  Port {.acyclic.} = ref object
    dir: PortDir
    name, obid: string
    position: Point

    entity {.cursor.}: Entity
    parent: Option[Component]
    reference: Option[Port]

  Structure = object
    objects: Table[string, Object]
    nets: seq[Net]

  ObjectKinds = enum
    okPort, okComponent

  Object = object
    case kind: ObjectKinds:
    of okPort: port: Port
    of okComponent: component: Component

  Component = ref object
    obid, name: string
    position: Point
    entity {.cursor.}: Entity
    ports: seq[Port]

  Net = ref object
    obid: string
    head, tail: LocalPortAddress

  LocalPortAddress = tuple
    componentId, portName: string


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

  let attrs = block:
    if attributes.len == 0:
      let t = attributes.mapIt(fmt"({it.key} {it.value})").join " "
      fmt"(ATTRIBUTES {t})"
    else:
      ""

  fmt"""
  (HDL_IDENT
    (NAME "{name}")
    (USERNAME 1)
    {attrs}
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


const
  `toolflow.xml` = readFile "./assets/toolflow.xml"
  `workspace.eas` = readfile "./assets/workspace.eas"

proc `project.eas`(libraries: seq[Library]): string =
  let
    id = $genoid()
    designs = libraries.
      mapIt(fmt "(DESIGN \"{it.name}\" \"{it.obid}\")").
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

func `library.eas`(lib: Library): string =

  let entities = joinLines collect do:
    for name, e in lib.entities:
      fmt "(ENTITY \"{name}\" \"{e.obid}\")"


  fmt"""(DATABASE_VERSION 17)
  (DESIGN_FILE
    (OBID "{lib.obid}")
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
    (NAME "{lib.name}")

    {entities}
  )
  (END_OF_FILE)
  """


# proc toEas(net: Net): string =
#   let
#     netid = $genOid()
#     name = $genOid()
#     partId = $genOid()

#     wireSegments = wire.
#       mapIt(fmt"(WIRE {it.a.x} {it.a.y} {it.b.x} {it.b.y})").
#       joinLines


#   fmt"""
#   (NET
#     (OBID "{netid}")
#     {genIdent name}

#     (PART
#       (OBID "{partId}")

#       {wireSegments}

#       (PORT
#         (OBID "{connection.head.componentId}")
#         (NAME "{connection.head.portName}")
#       )
#       (PORT
#         (OBID "{connection.tail.componentId}")
#         (NAME "{connection.tail.portName}")
#       )
#     )
#   )
#   """


proc toEas(p: Port): string =
  let
    isDef = isNone p.reference

    refport =
      if isDef: ""
      else: fmt "(PORT \"{p.reference.get.obid}\")"

    lbl =
      if isDef:
        ""
      else:
        genLabel(p.position.x, p.position.y, p.name, LeftToRight, Left)

    side =
      if p.dir == pdInput: LeftToRight
      else: RightToLeft

    (x, y) = p.position

    hld_ident = genIdent(p.name, [("MODE", $p.dir.int)])

  fmt"""
  (PORT
    (OBID "{p.obid}")
    {hld_ident}

    (GEOMETRY {x} {y} {x} {y})
    (SIDE {side.int})
    {lbl}
    
    {refport}
  )
  """

proc toEas(c: Component): string =
  let
    ports = joinLines c.ports.map(toEas)
    (x, y) = c.position
    (w, h) = c.entity.componentSize
    lbl = genLabel(x + w div 2, y, c.name, LeftToRight, Top)

  fmt"""
  (COMPONENT
    (OBID "{c.obid}") 
    (ENTITY "{c.entity.library.obid}" "{c.entity.obid}")

    {genIdent c.name}

    (GEOMETRY {x} {y} {x + w} {y + h})
    (SIDE 0)
    
    {lbl}
    {ports}
  )
  """

proc toEas(o: Object): string =
  case o.kind:
  of okPort: toEas o.port
  of okComponent: toEas o.component



proc toEas(e: Entity): string =
  let
    archId = $genOid()
    archTag = "structure"
    schemaId = $genOid()

    portsDef = e.ports.map(toEas).joinLines
    nets = ""
      # e.structure.nets.map(toEas).joinLines
    objects = joinLines collect do:
      for _, o in e.structure.objects:
        toEas o

  fmt"""
  (DATABASE_VERSION 17)
  (ENTITY_FILE
    (ENTITY
      (OBID "{e.obid}")
      (PROPERTIES
        (PROPERTY "STAMP_PLATFORM" "PC")
        (PROPERTY "STAMP_REVISION" "Revision 4")
        (PROPERTY "STAMP_TIME" "Wed May 04 16:34:31 2022")
        (PROPERTY "STAMP_TOOL" "Ease")
        (PROPERTY "STAMP_VERSION" "8.0")
      )
      
      {genIdent e.name}
      
      (GEOMETRY 0 0 {e.componentSize.width} {e.componentSize.height})
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
        (SHEETSIZE 0 0 {e.schemaSize.width} {e.schemaSize.height})
        
        {objects}
        {nets}
      )
    )
  )
  (END_OF_FILE)
  """


proc buildProject(path, projectName: string, proj: Project) =
  let
    dirPath = path / projectName & ".ews"
    dbPath = dirPath / "ease.db"

  createDir dirPath
  writeFile dirPath / "toolflow.xml", `toolflow.xml`
  writeFile dirPath / "workspace.eas", `workspace.eas`

  createDir dbPath
  writeFile dbPath / "project.eas", `project.eas`(proj)

  for lib in proj:
    let libPath = dbpath / lib.obid
    createDir libPath
    writeFile libPath / "library.eas", `library.eas`(lib)

    for _, entity in lib.entities:
      writeFile libPath / entity.obid & ".eas", toEas(entity)

# ------------------------------------------

proc getVfiles(dirPath: string): seq[string] =
  for p in walkDirRec dirPath:
    let (_, name, ext) = splitFile p
    if ext == ".v" and not name.startsWith "config":
      result.add p

proc instantiate(e: Entity, name: string): Component =
  result = Component(
    obid: "comp" & $genOid(),
    name: name,
    entity: e)

  for p in e.ports:
    var newPort = deepCopy p
    newPort.obid = $genOid()
    newPort.reference = some p
    newPort.parent = some result
    # newPort.position += pos
    result.ports.add newPort


when isMainModule:
  const
    SchemaWidth = 6000
    SchemaHeight = 4000
    ComponentWidth = 400
    ComponentYPadding = 100
    PortYOffset = 200
    Xmargin = 100

  let (allModules, globalDefines) = extractModulesFromFiles ["./temp/sample.v"]
  print allModules

  var lib = Library(obid: "lib" & $genOid(), name: "design")

  # entities declaration [name, ports, ...]
  for name, module in allModules:
    let (inputs, outputs) = splitPorts module

    var entr = Entity(
      obid: "entr" & $genOid(),
      name: name,
      library: lib,
      schemaSize: (SchemaWidth, SchemaHeight),
      componentSize: (ComponentWidth, ComponentYPadding*2 +
         PortYOffset*max(inputs.len, outputs.len)))

    for i, p in module.ports:
      let
        y = ComponentYPadding + i*PortYOffset
        x =
          if p.dir == pdInput: 0
          else: ComponentWidth

      entr.ports.add Port(
        dir: p.dir,
        name: p.name,
        entity: entr,
        obid: $genOid(),
        position: (x, y))

      # entr.ports.add po
      # entr.sctructure[p.name] = Internal(kind: ikPort, port: po)

    lib.entities[name] = entr

  # generate internal structure
  for modName in ["TopLevel"]:
    let
      module = allModules[modName]
      bp = genBlueprint(module, allModules)

    print bp

    # ----------------------------------

    var parentEntry = lib.entities[modName]

    # fill structure.components
    # var i = 0
    for iname, intr in module.internals:
      let
        entry = lib.entities[intr.module]
        c = instantiate(entry, iname)
        # pos = (0, i)

      parentEntry.structure.objects[iname] =
        Object(kind: okComponent, component: c)

    # fill strcuture.ports
    let width = bp.len
    for p in parentEntry.ports:
      var newPort = deepCopy p
      newPort.reference = some p

      if p.dir == pdOutput:
        newPort.position.x = width * (ComponentWidth + Xmargin)

      parentEntry.structure.objects[p.name] =
        Object(kind: okPort, port: newPort)

    # fill strcuture.nets
    # TODO


  # print lib
  buildProject "./output/", "hope", @[lib]


import std/[os, strutils, tables, sequtils, sets, options, lenientops,
    strformat, oids, sugar]

# import mathexpr
import vverilog
import print

import std/[strutils]

template err*(msg): untyped =
  raise newException(ValueError, msg)

template safe*(body): untyped {.used.} =
  {.cast(gcsafe).}:
    {.cast(nosideEffect).}:
      body


template joinLines*(s: seq): untyped =
  s.join "\n"


# ----------------------------------------------

type
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

  Point = tuple
    x, y: int
  
  Size = tuple
    width, height: int

  Line = HSlice[Point, Point]
  
  Wire = seq[Line]

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
    outputIndexes: seq[int]
    internals: Table[string, Instance]
    defines: LookUp

  Instance = object
    module: string
    name: string
    args: seq[string]

  LookUp = Table[string, VNode]

  InputDepth = seq[Option[int]]

  ConnectionTable = Table[string, seq[PortAddress]]

  PortAddress = tuple[instanceName: string, portIndex: int]

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

func onlyIdent(vn: VNode): string =
  if vn.kind == vnkBracketExpr:
    $vn.lookup
  else:
    $vn

func toVModule(m: VNode): VModule =
  let params = m.params.mapIt onlyIdent it

  for vn in m.children[^1].children:
    result.ports.setLen params.len

    case vn.kind:
    of vnkDeclare:
      for id in vn.idents:
        let name = onlyIdent id


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
      let n = $vn.instanceIdent
      result.internals[n] =
        Instance(module: $vn.module, name: n,
            args: vn.children.mapit onlyIdent it)

    else:
      discard

  for i, p in result.ports:
    if p.dir == pdOutput:
      result.outputIndexes.add i

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

func initConnTable(m: VModule, modules: ModulesTable): ConnectionTable =
  ## input -> instance names
  for o in m.outputs:
    result[o] = @[]

  for name, component in m.internals:
    for i, arg in component.args:
      if modules[component.module].ports[i].dir == pdInput:
        if arg notin result:
          result[arg] = @[]

        result[arg].add (name, i)

func initConnDepth(instances: Table[string, Instance],
    modules: ModulesTable): Table[string, InputDepth] =

  for name, ins in instances:
    result[name] = newSeqWith(modules[ins.module].ports.len, none int)


func genBlueprintImpl(
  inp: string, conns: ConnectionTable,
  m: VModule, modules: ModulesTable,
  depth: int, result: var Table[string, InputDepth], seen:var HashSet[string]) =

  seen.incl inp

  try:
    for portAddr in conns[inp]:
      let 
        ins = portAddr.instanceName
        intr = m.internals[ins]

      result[ins][intr.args.find inp] = some depth

      for i, o in intr.args:
        if modules[intr.module].ports[i].dir == pdOutput:
          if o notin seen:
            genBlueprintImpl o, conns, m, modules, depth+1, result, seen

  except:
    discard

func genBlueprint(m: VModule, modules: ModulesTable,
    conns: ConnectionTable): BluePrint =

  var 
    insInputsDepth = initConnDepth(m.internals, modules)
    seen: HashSet[string]

  for inp in m.inputs:
    genBlueprintImpl inp, conns, m, modules, 0, insInputsDepth, seen

  var insDepth: Table[string, int]
  for insName, inputsDepth in insInputsDepth:
    let n = inputsDepth.filterIt(issome it).mapIt(it.get)
    if n.len != 0:
      insDepth[insName] = n.max


  for insName, depth in insDepth:
    if depth+1 > result.len:
      result.setlen depth+1

    result[depth].add insName


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
    name, label, obid: string
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
    case kind: ObjectKinds
    of okPort: port: Port
    of okComponent: component: Component

  Component = ref object
    obid, name: string
    position: Point
    entity {.cursor.}: Entity
    ports: seq[Port]

  Net = ref object
    obid, name: string
    wire: Wire
    connection: HSlice[Port, Port]

  LinkKinds = enum
    lkDirect, lkIndirect

  Link = object
    kind: LinkKinds
    portAddr: PortAddress


func genLabel(x, y: int, label: string, side: Side,
    alignment: Alignment, scale = 90, color: Color = 0): string =

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


proc move(p: var Port, by: Point) =
  p.position += by

proc move(c: var Component, by: Point) =
  c.position += by

  for p in c.ports.mitems:
    p.move by

proc move(o: var Object, by: Point) =
  case o.kind:
  of okComponent:
    o.component.move by
  of okPort:
    o.port.move by

func getPort(link: Link, e: Entity): Port =
  let (n, i) = link.portAddr

  case link.kind:
  of lkDirect:
    e.structure.objects[n].port
  of lkIndirect:
    e.structure.objects[n].component.ports[i]

proc initNet(p1, p2: Port): Net =
  Net(
    obid: $genOid(),
    # name: "net:" & ($genOid())[^6..^1],
    wire: toWire(p1.position, p2.position, 0.9),
    connection: p1..p2)


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

proc toEas(n: Net): string =
  let
    partId = $genOid()
    whatId = $genOid()
    wireSegments = n.wire.
      mapIt(fmt"(WIRE {it.a.x} {it.a.y} {it.b.x} {it.b.y})").
      joinLines


  fmt"""
  (NET
    (OBID "{n.obid}")
    {genIdent n.name}

    (PART
      (OBID "{whatId}")
      (CBN 1)
    )
    (PART
      (OBID "{partId}")

      {wireSegments}

      (PORT
        (OBID "{n.connection.a.obid}")
        (NAME "{n.connection.a.reference.get.name}")
      )
      (PORT
        (OBID "{n.connection.b.obid}")
        (NAME "{n.connection.b.reference.get.name}")
      )
    )
  )
  """

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
        genLabel(p.position.x - 50, p.position.y, p.label, LeftToRight, TopLeft)

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

  let
    nets = e.structure.nets.map(toEas).joinLines
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
    name: fmt"{e.name}:{name}",
    entity: e)

  for p in e.ports:
    # var newPort = deepCopy p
    # newPort.obid = $genOid()
    # newPort.label = fmt"{name}:{p.name}"
    # newPort.reference = some p
    # newPort.parent = some result

    var newPort = Port(
      dir: p.dir,
      name: p.name,
      obid: $genOid(),
      label: fmt"{name}:{p.name}",
      reference: some p,
      parent: some result,
      position: p.position,
      entity: p.entity,
      )


    result.ports.add newPort


when isMainModule:
  const
    SchemaWidth = 10000
    SchemaHeight = 12000
    ComponentWidth = 400
    ComponentYPadding = 400
    PortYOffset = 200
    Ymargin = 200
    Xmargin = 1000


  let params = commandLineParams()
  
  if params.len == 0:
    quit("""
USAGE:
app <verilogFilesDir> <savePath> <projectName> ...<moduleNamesYouWannaBuildStructure>

EXAMPEL:
app ./temp ./output hope top
    """)

  let 
    verilogDir = params[0]
    savePath = params[1]
    projectName = params[2]
    whatModules = params[3 .. ^1]

  # verilog dir path - where to save ews - modules you wanna genenarate
  

  let (allModules, globalDefines) = extractModulesFromFiles getVfiles verilogDir
  # print allModules


  var lib = Library(obid: "lib" & $genOid(), name: "design")

  # entities declaration [name, ports, ...]
  for mname, module in allModules:
    let (inputs, outputs) = splitPorts module

    var entr = Entity(
      obid: "entr" & $genOid(),
      name: mname,
      library: lib,
      schemaSize: (SchemaWidth, SchemaHeight),
      componentSize: (ComponentWidth, ComponentYPadding*2 +
         PortYOffset*(inputs.len + outputs.len)))

    for i, p in module.ports:
      let
        y = ComponentYPadding + i*PortYOffset
        x =
          if p.dir == pdInput: 0
          else: ComponentWidth

      entr.ports.add Port(
        dir: p.dir,
        name: p.name,
        label: p.name,
        entity: entr,
        obid: $genOid(),
        position: (x, y))

    lib.entities[mname] = entr



  # generate internal structure
  for mname in whatModules:
    let
      module = allModules[mname]
      conns = initConnTable(module, allModules)
      (inps, outs) = splitPorts module
      bp = (@[inps] & genBlueprint(module, allModules, conns) & @[outs]).filterIt it.len != 0


    # print conns, bp
    # ----------------------------------

    var portAddrs: Table[string, Link]
    var parentEntry = lib.entities[mname]

    for i, p in parentEntry.ports:
      var newPort = deepCopy p
      newPort.reference = some p

      parentEntry.structure.objects[p.name] =
        Object(kind: okPort, port: newPort)

      portAddrs[newPort.name] = Link(kind: lkDirect, portAddr: (newPort.name, -1))

    block primaryIteration:
      for iname, intr in module.internals:
        let 
          entry = lib.entities[intr.module]
          c = instantiate(entry, iname)

        parentEntry.structure.objects[iname] =
          Object(kind: okComponent, component: c)

        for i in allModules[intr.module].outputIndexes:
          portAddrs[intr.args[i]] = Link(kind: lkIndirect, portAddr: (intr.name, i))

    # print portAddrs

    block placeObjects:
      var xacc = Xmargin
      for layer in bp:

        var yacc = Ymargin
        for objectName in layer:
          var obj = parentEntry.structure.objects[objectName]
          obj.move (xacc, yacc)

          yacc.inc case obj.kind:
            of okPort: Ymargin
            of okComponent:
              obj.component.entity.componentSize.height + Ymargin

        xacc.inc ComponentWidth + Xmargin

    block drawWires:
      for head, tails in conns:
        let p1 = getPort(portAddrs[head], parentEntry)

        for conn in tails:
          let p2 =
            parentEntry.structure.
            objects[conn.instanceName].
            component.ports[conn.portIndex]

          parentEntry.structure.nets.add initNet(p1, p2)

      # connect output ports
      for i in module.outputIndexes:
        let
          poutName = parentEntry.ports[i].name
          pout = parentEntry.structure.objects[poutName].port
          pin = portAddrs[pout.name].getPort(parentEntry)

        parentEntry.structure.nets.add initNet(pout, pin)


        # print lib


  buildProject savePath, projectName, @[lib]

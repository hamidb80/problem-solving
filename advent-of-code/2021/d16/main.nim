import sequtils, strutils, strformat

# prepare ------------------------------------

const notAvailable = -1

type
  RawPacket = ref string

  PacketKind = enum
    PkLiteral, PkOperator

  DataPacket = ref object
    version, typeId: int

    case kind: PacketKind
    of PkLiteral: value: int 
    of PkOperator: nodes: seq[DataPacket]

  ParseStates = enum
    PsEnd,
    PsVersion, PsTypeId,
    PsLiteralData, PsLengthTypeId,
    PsSubPackets

template isAvailable(v: int): untyped =
  v != notAvailable

# utils --------------------------------------

func parseInput(s: sink string): RawPacket =
  result = new RawPacket
  result[] = newStringOfCap(s.len * 4)

  for n in countup(4, s.len, 4):
    result[] &= s[n-4 ..< n].parseHexInt.toBin(4)

func parseLiteralBin(s: string): int=
  var acc:string
  
  for i in countup(5, s.len, 5):
    acc.add s[(i-4) ..< i]

  acc.parseBinInt

# implement ----------------------------------

func parseRawPacketImpl(rp: RawPacket, rng: HSlice[int, int], acc: var DataPacket): int =
  var
    i = rng.a
    numberOfSubPackets = notAvailable
    totalLengthOfSubPackets = notAvailable
    state = PsVersion
    myversion = notAvailable

  template at(n: int): untyped= rp[][n]
  template resolve(`from`, size: int): untyped =
    if acc != nil:
      debugEcho fmt"{acc.typeId = }"
      debugEcho fmt"{acc.version = }"

    debugEcho `from` ..< (`from` + size), " of ", rp[].len, " >> ", state
    debugEcho rp[][`from` ..< (`from` + size)]
    debugEcho "-----------"

    rp[][`from` ..< (`from` + size)].parseBinInt

  while (i <= rng.b) and (state != PsEnd):
    case state:
    of PsVersion:
      myversion = resolve(i, 3)
      state = PsTypeId
      i.inc 3

    of PsTypeId:
      let mytypeid = resolve(i, 3)
      i.inc 3

      if mytypeid == 4:
        acc = DataPacket(kind: PkLiteral)
        state = PsLiteralData
      else:
        acc = DataPacket(kind: PkOperator)
        state = PsLengthTypeId

      acc.version = myversion
      acc.typeId = mytypeid

    of PsLiteralData:
      var shouldContinue = true
      let start = i

      while shouldContinue:
        shouldContinue = at(i) != '0'
        i.inc 5

      acc.value = rp[][start ..< i].parseLiteralBin
      state = PsEnd

    of PsLengthTypeId:
      let lenTid = at(i)
      i.inc 1

      if lenTid == '0':
        numberOfSubPackets = resolve(i, 15) 
        i.inc 15
      else:
        totalLengthOfSubPackets = resolve(i, 11)
        i.inc 11

      state = PsSubPackets

    of PsSubPackets:
      if isAvailable numberOfSubPackets:
        var c = 0
        while (c < numberOfSubPackets) and (i <= rng.b):
          var myPacket: DataPacket
          i = parseRawPacketImpl(rp, i .. rng.b, myPacket)
          acc.nodes.add myPacket
          c.inc
      
      else:
        let limit = i + totalLengthOfSubPackets - 1

        while i <= limit:
          var myPacket: DataPacket
          i = parseRawPacketImpl(rp, i .. limit, myPacket)
          acc.nodes.add myPacket

      state = PsEnd

    of PsEnd: break
  
  i

func parseRawPacket(rp: RawPacket): DataPacket=
  discard parseRawPacketImpl(rp, 0 .. rp[].high, result)

func sumVersionsImpl(packetTree: DataPacket, acc: var int)=
  acc.inc packetTree.version

  if packetTree.kind == PkOperator:
    for node in packetTree.nodes:
      sumVersionsImpl(node, acc)

func sumVersions(packetTree: DataPacket): int =
  sumVersionsImpl(packetTree, result)

# go -----------------------------------------

let data = readFile("./test1.txt").parseInput
echo sumVersions data.parseRawPacket

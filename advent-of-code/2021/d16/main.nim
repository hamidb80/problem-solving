import sequtils, strutils

# prepare ------------------------------------

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

const notAvailable = -1
template isAvailable(v: int): untyped =
  v != notAvailable

# utils --------------------------------------

func parseInput(s: sink string): RawPacket =
  result = new RawPacket
  result[] = newStringOfCap(s.len * 4)

  for c in s:
    result[] &= ($c).parseHexInt.toBin(4)

func parseLiteralBin(s: string): int =
  var acc: string

  for i in countup(5, s.len, 5):
    acc.add s[(i-4) ..< i]

  acc.parseBinInt

# implement ----------------------------------

func parseRawPacketImpl(rp: RawPacket, rng: HSlice[int, int],
    acc: var DataPacket): int =

  var
    i = rng.a
    numberOfSubPackets = notAvailable
    totalLengthOfSubPackets = notAvailable
    state = PsVersion
    myversion = notAvailable

  template at(n: int): untyped = rp[][n]
  template resolve(`from`, size: int): untyped =
    rp[][`from` ..< (`from` + size)].parseBinInt

  while i <= rng.b:
    case state:
    of PsEnd: break
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
        totalLengthOfSubPackets = resolve(i, 15)
        i.inc 15
      else:
        numberOfSubPackets = resolve(i, 11)
        i.inc 11

      state = PsSubPackets

    of PsSubPackets:
      if isAvailable numberOfSubPackets:
        var c = 0
        while (c != numberOfSubPackets) and (i <= rng.b):
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

  i

func parseRawPacket(rp: RawPacket): DataPacket =
  discard parseRawPacketImpl(rp, 0 .. rp[].high, result)

func sumVersionsImpl(packetTree: DataPacket, acc: var int) =
  acc.inc packetTree.version

  if packetTree.kind == PkOperator:
    for node in packetTree.nodes:
      sumVersionsImpl(node, acc)

func sumVersions(packetTree: DataPacket): int =
  sumVersionsImpl(packetTree, result)

func calc(packetTree: DataPacket): int =
  if packetTree.kind == PkOperator:
    let values = packetTree.nodes.map(calc)

    values.foldl:
      case packetTree.typeid:
      of 0: a + b
      of 1: a * b
      of 2: min(a, b)
      of 3: max(a, b)
      of 5: (a > b).int
      of 6: (a < b).int
      of 7: (a == b).int
      else:
        raise newException(ValueError, "invalid 'typeid' for Packet")

  else:
    packetTree.value

# go -----------------------------------------

let data = readFile("./input.txt").parseInput.parseRawPacket
echo sumVersions data # 984
echo calc data # 1015320896946

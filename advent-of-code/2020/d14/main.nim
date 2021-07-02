import sugar, strutils, tables
# import print

# data structuring ------------------------------

type
  Memory = Table[int, int]
  Collection = object
    mask: string
    memsets: seq[tuple[loc: int, val: string]]

const bitSize = 36

# functionalities -------------------------------

func applyMaskV1(mask, sbit: string): string =
  result = newstring bitSize

  for i in countdown(bitSize - 1, 0):
    result[i] =
      if mask[i] == 'X': sbit[i]
      else: mask[i]

func applyMaskV2(mask, sbit: string): seq[string] =
  var temp = newString mask.len

  for i in 0..mask.high:
    case mask[i]:
    of '0': temp[i] = sbit[i]
    of '1': temp[i] = '1'
    else: # 'X'
      let rng = i+1..^1
      return collect newseq:
        for c in ["0", "1"]:
          for branch in applyMaskV2(mask[rng], sbit[rng]):
            temp[0..<i] & c & branch

  @[temp]
# preparing data --------------------------------

let collections = collect newseq:
  for doc in "./input.txt".readFile.split"mask = ":
    once: continue
    let lines = doc.strip.splitLines()

    template memlines: untyped =
      collect newseq:
        for line in lines[1..^1]:
          let assigment = line.split " = "
          (
            loc: assigment[0]["mem[".len..^2].parseInt,
            val: assigment[1].parseInt.toBin bitSize
          )

    Collection(mask: lines[0], memsets: memlines)

# print collections

# code ----------------------------------------

func sumMemory(mem: var Memory): int =
  for _, v in mem:
    result += v

block part1:
  var memory: Memory

  for coll in collections:
    for mset in coll.memsets:
      memory[mset.loc] = fromBin[int]applyMaskV1(coll.mask, mset.val)

  echo sumMemory memory

block part2:
  var memory: Memory

  for coll in collections:
    for mset in coll.memsets:
      let addrs = applyMaskV2(coll.mask, mset.loc.toBin bitSize)
      for adr in addrs:
        memory[fromBin[int](adr)] = fromBin[int](mset.val)

  echo sumMemory memory

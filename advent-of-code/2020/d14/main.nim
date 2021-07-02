import sugar, strutils, tables
import print

# data structuring ------------------------------

type
  Collection = object
    mask: string
    memsets: seq[tuple[loc: int, val: string]]

const bitSize = 36

# functionalities -------------------------------

func applyMask(mask, sbit: string): string =
  assert (mask.len, sbit.len) == (bitSize, bitSize)
  result = newstring bitSize

  for i in countdown(bitSize - 1, 0):
    result[i] =
      if mask[i] == 'X': sbit[i]
      else: mask[i]

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

block part1:
  var memory: Table[int, int]

  for coll in collections:
    for mset in coll.memsets:
      memory[mset.loc] = fromBin[int]applyMask(coll.mask, mset.val)

  var sum = 0
  for _, v in memory: sum += v
  echo sum

block part2:
  discard

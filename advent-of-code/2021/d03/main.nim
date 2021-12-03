import strutils, sequtils, sugar

# utils -------------------------------

func toStr(s: seq[char]): string =
  cast[string](s)

func toBit(cond: bool): char =
  if cond: '1'
  else: '0'
  
func reverseBit(b: char): char =
  toBit b == '0'

func reverseBin(s: string): string =
  s.map(reverseBit).toStr()

func wordLen(ls: seq[string]): int =
  ls[0].len

# main ----------------------------------

func test1(list: seq[string]): int =
  let gammaRate = toStr collect(
    for i in 0 ..< list.wordLen:
      toBit list.countIt(it[i] == '1') * 2 >= list.len
  )

  gammaRate.parseBinInt * reverseBin(gammaRate).parseBinInt

func test2Impl(list: seq[string], bit: char, index = 0): int =
  let
    condBit = block:
      let c = list.countIt(it[index] == bit)

      if (bit == '1' and c * 2 >= list.len) or (bit == '0' and c * 2 <= list.len):
        bit
      else:
        reverseBit bit

    newlist = list.filterIt(it[index] == condBit)

  # debugecho '[', index, "] = ", condBit
  # debugEcho list
  # debugEcho newlist
  # debugEcho "----------------"

  if newlist.len == 1:
    parseBinInt newlist[0]
  else:
    test2Impl(newlist, bit, index + 1)


proc test2(list: seq[string]): int =
  test2Impl(list, '1') * test2Impl(list, '0')

# go -------------------------------

let binList = readFile("./input.txt").splitLines()
echo test1(binList)
echo test2(binList)

import sequtils, strutils, math

# utils --------------------------

type Board = seq[int] # with cap of 25
const
  pin = -1
  notFound = -1
  rowOffsets = countup(0, 25 - 1, 5).toseq

func extractInfo(body: sink string): tuple[header: seq[int], boards: seq[Board]] =
  let s = body.split("\n", 1)
  result.header = s[0].strip.split(',').map parseInt

  let numbers = s[1].splitwhitespace().map parseInt
  for board_offset in countup(0, numbers.high, 25):
    result.boards.add numbers[board_offset..(board_offset + 25 - 1)]

func spaced(n, desiredLen: int): string =
  let s = $n
  repeat(' ', desiredLen - s.len) & s

func `$`(b: Board): string = ## for debugging purposes
  rowOffsets
  .mapit(b[it..(it+4)].mapIt(it.spaced 2).join" ")
  .join "\n"

# implement --------------------------

func pinNumber(boards: var seq[Board], num: int) =
  for b in boards.mitems:
    let i = b.find num

    if i != notfound:
      b[i] = pin

func checkWin(board: Board): bool =
  # rows check
  for rowOffset in rowOffsets:
    if board[rowOffset..(rowOffset + 5 - 1)].allIt it == pin:
      return true

  # columns check
  for col_i in 0..<5:
    if rowOffsets.allIt(board[it + col_i] == pin):
      return true

func winnerIndex(boards: seq[Board]): int =
  result = notfound

  for i, b in boards.pairs:
    if b.checkWin:
      return i

func winnerSum(board: Board): int =
  board.filterIt(it != pin).sum

# go --------------------------

func test1(header: seq[int], boards: seq[Board]): int =
  var myboards = boards

  for (i, n) in header.pairs:
    pinnumber myboards, n
    if i < 5: continue

    let bi = winnerIndex myboards # board index
    if bi != notfound:
      return n * myboards[bi].winnerSum

func test2(header: seq[int], boards: seq[Board]): int =
  var myboards = boards

  for (i, n) in header.pairs:
    pinnumber myboards, n
    if i < 5: continue

    if myboards.len == 1: # special care for last one
      if myboards[0].checkwin:
        # debugecho myboards[0]
        return myboards[0].winnerSum * n

    else:
      myboards.keepitif not it.checkwin

# run -------------------------

let content = readfile("./input.txt").extractInfo

echo test1(content.header, content.boards)
echo test2(content.header, content.boards)

import sequtils, strutils, tables
import print

const 
  inpfPath = "./input.txt"
  rows = 0..<128
  cols = 0..<8

type SeatPlace = tuple[y, x: int]

func findPos(codeLine: string): SeatPlace=
  var
    rowRng = rows
    colRng = cols

  for c in codeLine:
    template halfRows: untyped = rowRng.len div 2
    template halfCols: untyped = colrng.len div 2

    case c:
    of 'F': rowRng = rowRng.a .. (rowRng.b  - halfRows)
    of 'B': rowRng = (rowRng.a + halfRows) .. rowRng.b
    of 'L': colRng = colRng.a .. (colRng.b - halfCols)
    of 'R': colRng = (colRng.a + halfCols) .. colRng.b
    else:
      raise newException(ValueError, "the code character is not defied")
  
  (rowRng.a, colRng.a)

func seatId(sp: SeatPlace): int = 
  sp.y * 8 + sp.x

block part1:
  var maxSeatID = 0
  
  for codeLine in inpfPath.lines:
    maxSeatID = max(maxSeatID, codeLine.findPos.seatId)

  echo maxSeatID

block part2: # to be hosent i dont know what to do
  var seats: Table[int, seq[int]]
  for i in rows: seats[i] = @[]

  for pos in inpfPath.readFile.splitLines.mapIt it.findPos:
    seats[pos.y].add pos.x

  for k in seats.keys:
    if seats[k].len != 0 and seats[k].len < cols.len:
      for x in cols:
        if x notin seats[k]:
          echo (k,x), (k,x).seatId # echos candidates
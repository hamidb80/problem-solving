type
  ChessBoard = array[8, array[8, bool]]
  Location = tuple[x, y: int]

const moves = [
  (+2, -1), # LLD
  (+2, +1), # LLU
  (-2, -1), # RRD
  (-2, -1), # RRU
  (+1, +2), # UUL
  (-1, +2), # UUR
  (+1, -2), # DDL
  (-1, -2), # DDR
]

func `+`(l1, l2: Location): Location =
  (l1.x + l2.x, l1.y + l2.y)

func `-`(loc: Location): Location =
  (-loc.x, -loc.y)

func isInBoard(loc: Location): bool =
  (loc.x in 0 ..< 8) and (loc.y in 0 ..< 8)

func isFullyVisited(cb: ChessBoard): bool =
  for row in cb:
    for v in row:
      if not v:
        return false

  return true


func isItPossible(loc: Location): bool =
  var
    currentLocation = loc 
    visited = ChessBoard.default 
    steps: seq[Location]

  visited[loc.y][loc.x] = true

  for m in moves:
    

  false

# --------------------

when isMainModule:
  for loc in [(1, 1), (4, 2), (3, 9)]:
    echo isItPossible loc

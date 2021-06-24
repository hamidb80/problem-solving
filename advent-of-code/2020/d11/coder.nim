import sugar, sequtils, macros
# import print, strutils

# prepare & model data --------------------------------------------

const
  Occupied = '#'
  Floor = '.'
  Empty = 'L'

let map = collect newseq:
  for row in "./input.txt".lines:
    row.mapIt:
      if it == Floor: it
      else: Occupied

let size = (x: map[0].len, y: map.len)

# functionalities -------------------------------------

# proc PrintMap(map: seq[seq[char]]) =
#   print map.mapIt it.join

func countOccupieds(map: seq[seq[char]]): int =
  (map.mapIt it.countIt it == Occupied).foldl(a + b)

# problems ---------------------------------------------------

block part1:
  var
    m = map
    changed = true

  while changed:
    changed = false
    var newm = m

    for y in 0..<size.y:
      for x in 0..<size.x:
        template currentSeat: untyped = m[y][x]
        if currentSeat == Floor: continue

        var onc = 0 # occupied Neighbours count
        for ny in -1..1:
          for nx in -1..1:
            if
              [nx, ny] == [0, 0] or
              nx + x notin 0..m[x].high or
              ny + y notin 0..<size.y
              : continue

            if m[ny + y][nx + x] == Occupied:
              inc onc

        newm[y][x] =
          if currentSeat == Empty and onc == 0:
            changed = true
            Occupied
          elif currentSeat == Occupied and onc >= 4:
            changed = true
            Empty
          else:
            currentSeat

    m = newm

  echo m.countOccupieds

block part2:
  var
    m = map
    changed = true

  while changed:
    changed = false
    var newm = m

    for y in 0..<size.y:
      for x in 0..<size.x:
        let currentSeat = m[y][x]
        if currentSeat == Floor: continue
        var onc = 0 # occupied Neighbours count

        template checkCell(x, y: untyped): untyped =
          if m[y][x] != Floor:
            if m[y][x] == Occupied:
              inc onc
            break
        
        # vertical & horizontal
        for vx in 1..x: checkCell(x-vx, y)
        for vx in x+1..<size.x: checkCell(vx, y)
        for vy in 1..y: checkCell(x, y-vy)
        for vy in y+1..<size.y: checkCell(x, vy)
        # diameters
        for r in 1..min(x, y): checkCell(x-r, y-r)
        for r in 1..min(size.x-x-1, size.y-y-1): checkCell(x+r, y+r)
        for r in 1..min(x, size.y-y-1): checkCell(x-r, y+r)
        for r in 1..min(size.x-x-1, y): checkCell(x+r, y-r)

        template change(val: untyped): untyped =
          changed = true
          val

        newm[y][x] =
          if currentSeat == Empty and onc == 0:
            change Occupied
          elif currentSeat == Occupied and onc >= 5:
            change Empty
          else:
            currentSeat

    m = newm
    # PrintMap(m)

  echo m.countOccupieds

import sugar, strutils
import print

const
  North = 'N'
  West = 'W'
  East = 'E'
  South = 'S'
  Left = 'L'
  Right = 'R'
  Forward = 'F'

let instructions = collect newseq:
  for line in "./input.txt".lines:
    (action: line[0], value: line[1..^1].parseInt)


func toValidDeg(deg: int): int =
  result = deg mod 360
  if result < 0: result += 360

# import print, sequtils
# print instructions.filterIt it.action in [Left, Right]

block part1:
  var
    pos = (x: 0, y: 0)
    deg = 0

  for ins in instructions:
    let val = ins.value
    case ins.action:
    of North: pos.y += val
    of South: pos.y -= val
    of East: pos.x += val
    of West: pos.x -= val
    of Right: deg = toValidDeg deg + val
    of Left: deg = toValidDeg deg - val
    else: # Forward
      if deg == 0: pos.x += val # EAST
      elif deg == 90: pos.y -= val # SOUTH
      elif deg == 180: pos.x -= val # WEST
      else: pos.y += val # deg == 270 NORTH

  echo abs(pos.x) + abs(pos.y)

block part2:
  var
    ship = (x: 0, y: 0)
    wayport = (x: 10, y: 1)

  for ins in instructions:
    let val = ins.value
    case ins.action:
    of North: wayport.y += val
    of South: wayport.y -= val
    of East: wayport.x += val
    of West: wayport.x -= val
    of Forward:
      ship.x += wayport.x * val
      ship.y += wayport.y * val
    else: # Left, Right
      let deg = toValidDeg:
        if ins.action == Left: -val
        else: val

      print "before ", deg, wayport
      let newp =
        case deg:
        of 90: (x: wayport.y, y: - wayport.x)
        of 180: (x: - wayport.x, y: - wayport.y)
        of 270: (x: - wayport.y, y: wayport.x)
        else: wayport
      print "af ", deg, newp
      wayport = newp

    print wayport, ship
  echo abs(ship.x) + abs(ship.y)

import std/[math, unittest]

template shoot(a): untyped =
  del a, a.high

func fight(players: seq[int]): seq[int] =
  var
    team = 0
    i = 0
    bench: seq[int]

  while i != players.len:
    let
      p = players[i]
      newTeam = sgn p

    if bench.len == 0:
      bench.add p
      team = sgn p
      inc i

    elif team == newTeam:
      bench.add p
      inc i

    else: # team != newTeam
      let
        oldPower = abs bench[^1]
        newPower = abs p

      if oldPower == newPower:
        bench.shoot
        inc i

      elif oldPower > newPower:
        inc i

      else: # oldPower < newPower
        bench.shoot

  bench


test "big enemy at the end":
  check fight(@[1, 2, 3, -5, 4]) == @[-5]

test "equal powers":
  check fight(@[1, 2, 5, -5, 4]) == @[1, 2, 4]

test "bench has more power":
  check fight(@[1, 2, 6, -5, 4]) == @[1, 2, 6, 4]

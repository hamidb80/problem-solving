import std/[
  strutils,
  nre,
  sequtils,
  sugar,
  math]

import prettyvec


type
  Vec2 = Vec2Obj

  Area = object
    xs, ys: Slice[float]

  Star = object
    pos, vel: Vec2


template `~>`(sq, fn): untyped = map(sq, fn)
template `~~>`(sq, expr): untyped = mapit(sq, expr)
template `~=`(s, pat): untyped = findAll(s, pat)


func parseStar(line: string): Star =
  let n = line ~= re"-?\d+" ~> parseFloat
  Star(
    pos: vec2(n[0], n[1]),
    vel: vec2(n[2], n[3]))

func solveLinearEq(p1, p2, m1, m2: float): float =
  (p1 - p2) / (m2 - m1)

func collide(a, b: Star): float =
  let
    t1 = solveLinearEq(a.pos.x, b.pos.x, a.vel.x, b.vel.x)
    t2 = solveLinearEq(a.pos.y, b.pos.y, a.vel.y, b.vel.y)

  if t1 == t2: t1
  else: Inf

func specialTime(stars: seq[Star]): int =
  for i, a in stars:
    for j, b in stars:
      let c = collide(a, b)
      if classify(c) == fcNormal:
        return toInt c
  assert false

func area(vs: seq[Vec2]): Area =
  var
    minx = vs[0].x
    maxx = minx
    miny = vs[0].y
    maxy = miny

  for v in vs:
    minx = min(v.x, minx)
    maxx = max(v.x, maxx)
    miny = min(v.y, miny)
    maxy = max(v.y, maxy)

  Area(
    xs: minx..maxx,
    ys: miny..maxy)


proc draw(points: seq[Vec2]) =
  let a = area points

  for y in a.ys.a.toInt .. a.ys.b.toInt:
    for x in a.xs.a.toInt .. a.xs.b.toInt:
      write stdout:
        if vec2(toFloat x, toFloat y) in points: '#'
        else: '.'

    write stdout, '\n'
  write stdout, "\n\n"

proc drawProbableMoments(stars: seq[Star]) =
  let t = specialTime stars
  for t in t-2 .. t+2:
    echo "at = ", t
    draw stars ~~> it.pos + it.vel * toFloat t


when isMainModule:
  drawProbableMoments collect do:
    for line in lines "input.txt":
      parseStar line

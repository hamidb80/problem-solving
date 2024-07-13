import std/[strscans, math, strutils, sequtils, sets]

# --- types --------------------------------

type
  Rotation = enum
    L = -1
    R = +1

  Instruction = tuple
    rotation: Rotation
    step:     Natural

  Vec2 = tuple
    x, y: int

# --- consts -------------------------------

const 
  moves: array[4, Vec2] = [
    (0, +1), # N
    (+1, 0), # E
    (0, -1), # S
    (-1, 0), # W
  ]

# --- utils --------------------------------

func parse(inp: string): Instruction = 
  let (_, c, n)   = inp.scanTuple"$c$i"
  result.step     = n
  result.rotation = 
    case c
    of 'R': R
    of 'L': L
    else: raise newException(ValueError, "undefined rotation: " & c)

func `*`(v:Vec2, n: int): Vec2 = 
  (v.x*n, v.y*n)

func `+`(a, b: Vec2): Vec2 = 
  (a.x+b.x, a.y+b.y)

func manhattanDistance(v: Vec2): Natural = 
  v.x.abs + v.y.abs

# --- impl ---------------------------------

func howFar1(ins: seq[Instruction]): Natural = 
  var 
    loc: Vec2 = (0, 0)
    dir       = 0 # NESW

  for (rot, n) in ins:
    inc dir, rot.int
    loc = loc + moves[dir.euclMod 4] * n

  manhattanDistance loc

func howFar2(ins: seq[Instruction]): Natural = 
  var 
    visits    = initHashSet[Vec2]()
    loc: Vec2 = (0, 0)
    dir       = 0 # NESW

  for (rot, n) in ins:
    inc dir, rot.int
    let m = moves[dir.euclMod 4]

    for i in 1..n:
      loc = loc + m
      
      if loc in visits:
        return manhattanDistance loc
      else:
        visits.incl loc

# --- go -----------------------------------

when isMainModule:
  let 
    content = 
      "./d1.dat".readFile
      # "R5, L5, R5, R3"
      # "R8, R4, R4, R8"
    ins     = content.split", ".map(parse)
  
  echo howFar1 ins # 273
  echo howFar2 ins # 115

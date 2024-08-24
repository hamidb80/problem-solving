import std/[strutils, sequtils, unittest]
# import pretty


type Program = seq[int]

func exec(p: Program): Program =
  result = p
  var i = 0

  while i < len result:
    case result[i]
    of 1: result[result[i+3]] = result[result[i+1]]+result[result[i+2]]
    of 2: result[result[i+3]] = result[result[i+1]]*result[result[i+2]]
    # of 99: break
    else: break
    inc i, 4

func prepare(p: sink Program): Program = 
  p[1] = 12
  p[2] =  2
  p

func part1(p: sink Program): int = 
  p.prepare.exec[0]

func parseIntsCsv(s: string): seq[int] =
  s.split",".map parseInt


test "examples":
  check parseIntsCsv"2,0,0,0,99"          == exec parseIntsCsv"1,0,0,0,99"
  check parseIntsCsv"2,3,0,6,99"          == exec parseIntsCsv"2,3,0,3,99"
  check parseIntsCsv"2,4,4,5,99,9801"     == exec parseIntsCsv"2,4,4,5,99,0"
  check parseIntsCsv"30,1,1,4,2,5,6,0,99" == exec parseIntsCsv"1,1,1,4,99,5,6,0,99"


when isMainModule:
  # echo part1 parseIntsCsv "1,9,10,3,2,3,11,0,99,30,40,50"
  echo part1 parseIntsCsv readFile "./d02.dat"

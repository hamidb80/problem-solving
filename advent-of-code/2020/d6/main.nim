import strutils, sets, sugar

let groups = collect newSeq:
  for lines in "./input.txt".readFile.split "\c\n\c\n":
    collect newSeq:
      lines.splitLines

block part1:
  var c = 0

  for g in groups:
    var ansSet = initHashSet[char]()
    for p in g:
      ansSet = ansSet.union p.toHashSet

    c.inc ansSet.len
  
  echo c


block part2:
  var c = 0

  for g in groups:
    var ansSet = g[0].toHashSet
    
    for p in g[1..^1]:
      ansSet = ansSet.intersection  p.toHashSet

    c.inc ansSet.len
  
  echo c
import std/[random, algorithm, sequtils]


func spot(s: Slice[int], pos: Natural): char = 
  if   pos == s.a: 'x'
  elif pos == s.b: 'o'
  elif pos in s  : '-'
  else           : ' '  

func draw(activities: seq[Slice[int]], width: Natural): string = 
  for a in activities:
    for i in 0..width:
      add result, a.spot i
    add result, '\n'

func draw(activities: seq[Slice[int]]): string = 
  draw activities, activities.mapIt(it.b).minmax()[1]



func asOptimal(activities: seq[Slice[int]]): seq[Slice[int]] = 
  let acts = activities.sortedByIt it.b  
  var i  = 0

  add result, acts[i]

  for j in 1 .. acts.high:
    if acts[i].b <= acts[j].a:
      i = j
      add result, acts[i]

func hasConflict(s, r: Slice[int]): bool =
  let super = min(s.a, r.a) .. max(s.b, r.b)
  # debugecho (super, s,r)
  not (super.len >= s.len + r.len - 1)


func leastConflictFirst(activities: seq[Slice[int]]): seq[Slice[int]] = 
  # https://www.cs.usfca.edu/~galles/cs673/lecture/lecture10.pdf
  var acts = activities

  while true:
    var conflicts: seq[seq[int]]
    conflicts.setlen acts.len
    for i in 0 .. acts.high:
      for j in 0 .. acts.high:
        if i != j:
          if hasConflict(acts[i], acts[j]):
            add conflicts[i], j

    let init = toseq(conflicts.pairs).filterit(it[1].len != 0)
    if init.len == 0:
      result = acts
      break

    var mi = init[0].key
    for i, c in conflicts:
      if conflicts[i].len != 0 and conflicts[i].len < conflicts[mi].len:
        mi = i
    
    for j in reversed conflicts[mi]:
      del acts, j
    #   delete acts, j
    # debugEcho acts
    # debugEcho draw acts


proc randomActivities(len: Natural, rng: Slice[int]): seq[Slice[int]] = 
  for i in 1..len:
    let 
      a = rand rng.a    .. pred rng.b
      b = rand (succ a) .. rng.b   
    add result, a..b


when isMainModule:
  randomize()

  while true:  
    let 
      acts = randomActivities(5, 0..50)
      # acts = @[13 .. 46, 50 .. 66, 15 .. 31, 57 .. 73, 28 .. 42, 67 .. 84, 42 .. 53, 81 .. 99, 75 .. 96]
      op   = asOptimal          acts
      la   = leastConflictFirst acts

    if op.len != la.len:
      echo "============================"
      echo (acts.len, op.len, la.len)
      echo acts
      echo (op, la)
      echo draw acts
      quit 0

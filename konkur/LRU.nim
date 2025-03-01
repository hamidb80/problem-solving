import std/algorithm

var 
  cache = [[-1,-1], [-1,-1]]
  hit   = 0 
  miss  = 0

for a in [21,51,8, 76,30,10,08,77,79,78,23,20,18,76,8,30,31,11,9,22]:
  let 
    loc = a   div 4
    i   = loc mod 2
    ci  = cache[i].find loc

  echo "---------------"
  echo cache
  echo (loc, i, ci)

  case ci
  of   -1: 
    # let   t = cache[i][0]
    # cache[i][0] = loc
    # cache[i][1] = t 
    cache[i] = [loc, cache[i][0]] 
    inc miss
  of   +1: 
    reverse cache[i]
    inc hit
    echo "hit"
  of    0: 
    inc hit
    echo "hit"
  
  else: quit "cannot happen"

echo "+++++++++++++++++++"
echo hit

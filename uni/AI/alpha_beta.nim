# generated  by Phind AI
# prettified by me

# ----- domain

type
  Node = object
    value: int
    children: seq[Node]

proc initNode(val: int): Node = 
  Node(value: val)

proc add(
  parent  : var    Node; 
  children: varargs[int]
) =
  for val in children:
    parent.children.add initNode val


# ----- impl

proc minimax(
  node            :     Node,
  depth           :     int,
  maximizingPlayer:     bool,
  alpha           : var int,
  beta            : var int,
): int =
  
  if depth             == 0 or 
     node.children.len == 0
  :
    node.value
  
  elif maximizingPlayer:
    var value = low int
    
    for child in node.children:
      value    = max(value, minimax(child, depth-1, false, alpha, beta))
      alpha    = max(alpha, value)
      if alpha >= beta: break
    
    value
  
  else:
    var value = high int
    
    for child in node.children:
      value    = min(value, minimax(child, depth-1, true,  alpha, beta))
      beta     = min(beta, value)
      if alpha >= beta: break
    
    value

proc alphaBetaPruning(
  root : Node; 
  depth: int
): tuple[bestMove, bestScore: int] =

  var bestMove  = -1
  var bestScore = low  int
  var alpha     = low  int
  var beta      = high int

  for i, child in root.children:
    let   score = minimax(child, depth-1, false, alpha, beta)
    if    score > bestScore:
      bestScore = score
      bestMove  = i
  
  (bestMove, bestScore)


# ----- test

when isMainModule:
  var root = initNode 0
  add root            ,   10,  -20, 30
  add root.children[0],  100,   50    
  add root.children[1], -500, -300   
  add root.children[2],  200,  150

  echo root.alphaBetaPruning 2

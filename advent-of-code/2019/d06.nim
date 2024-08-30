import std/[strutils, nre, tables]

type DirectedGraph[T] = Table[T, seq[T]]

template extractRe(s, pat): untyped =
  s.findAll re(pat)

func acc[T](g: var DirectedGraph[T], k, v: T) = 
  if k notin g:
    g[k] = @[]
  add g[k], v

func dgrph[T](s: seq[T]): DirectedGraph[T]  = 
  for i in countup(0, s.high, 2):
    acc result, s[i], s[i+1]

func rev[T](g: DirectedGraph[T]): DirectedGraph[T] = 
  for src, dests in g:
    for d in dests:
      acc result, d, src


func dfslenImpl[T](g: DirectedGraph[T], root: T, depth: int, result: var int) = 
  inc result, depth
  if root in g:
    for n in g[root]:
      dfslenImpl g, n, succ depth, result

func dfslen[T](g: DirectedGraph[T], root: T): int = 
  dfslenImpl g, root, 0, result

func depthTable ...


const testInput = """COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L"""

let part1 = readfile"./d06.dat".extractRe"\w+".dgrph.dfslen"COM"
let part2 = readfile"./d06.dat".extractRe"\w+".dgrph.minPath "YOU".."SAN"
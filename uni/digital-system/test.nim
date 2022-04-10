import std/[json]
import lisp


let nodes = parseLisp readFile "./sample.eas"

# writeFile "out.rkt", pretty nodes
echo pretty toJson nodes.children

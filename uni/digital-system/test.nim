import std/[json]
import lisp


let rules = parseRules:
  "ENTITY_FILE" / "ENTITY" / "...":
    discard

  "ENTITY_FILE" / "ENTITY" / "OBID":
    discard


let nodes = parseLisp readFile "./sample.eas"
# writeFile "out.rkt", pretty nodes
writefile "out.json", pretty toJson(nodes, rules)

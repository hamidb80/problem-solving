import std/[json]
import eas2json


template newjObjRet(wrapper): untyped =
  let r = %*{}
  wrapper = r
  r

# -----------------------------

let rules = parseRules:
  "DATABASE_VERSION":
    parent["DATABASE_VERSION"] = %args[0]

  "ENTITY_FILE" / "$":
    newjObjRet parent["ENTITY_FILE"]

  "ENTITY_FILE" / "ENTITY" / "$":
    newjObjRet parent["ENTITY"]

  "ENTITY_FILE" / "ENTITY" / "OBID":
    parent["OBID"] = %args[0]

  "..." / "PROPERTIES" / "$":
    newjObjRet parent["PROPERTIES"]

  "..." / "PROPERTIES" / "PROPERTY":
    parent[args[0].vstr] = %args[1]


# -----------------------------

let nodes = parseLisp readFile "./examples/simple.cl"
# writeFile "out.rkt", pretty nodes
writefile "./temp/out.json", pretty toJson(nodes, rules)
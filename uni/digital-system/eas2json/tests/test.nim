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

  "..." / "PORT" / "$":
    if args[0].kind == lnkList:
      newjObjRet parent["PORT"]
    else:
      parent["PORT"] = %args[0]
      nil

  "..." / "GEOMETRY":
    parent["GEOMETRY"] = %args

  "..." / "LABEL" / "POSITION":
    parent["POSITION"] = %*{"x": args[0], "y": args[1]}

  "..." / "PROPERTIES" / "$":
    newjObjRet parent["PROPERTIES"]

  "..." / "PROPERTIES" / "PROPERTY":
    parent[args[0].vstr] = %args[1]

  "..." / "*" / "$":
    if args.len == 0:
      nil
    else:
      newjObjRet parent[path[^1]]

  "..." / "*":
    parent[path[^1]] = %args[0]

# -----------------------------

let nodes = parseLisp readFile "./examples/sample.cl"
# writeFile "out.rkt", pretty nodes
writefile "./temp/out.json", pretty toJson(nodes, rules)

import std/[json, sequtils]
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

  "..." / "OBID":
    parent["OBID"] = %args[0]

  "..." / "PORT" / "$":
    if args[0].kind == lnkList:
      newjObjRet parent["PORT"]
    else:
      parent["PORT"] = %args[0]
      nil

  "..." / "GEOMETRY":
    parent["GEOMETRY"] = %args

  "..." / "SIDE":
    parent["SIDE"] = %args[0]

  "..." / "LABEL" / "$":
    newjObjRet parent["LABEL"]

  "..." / "LABEL" / "POSITION":
    parent["POSITION"] = %*{"x": args[0], "y": args[1]}

  "..." / "LABEL" / "$":
    newjObjRet parent["LABEL"]

  "..." / "HDL_IDENT" / "$":
    newjObjRet parent["HDL_IDENT"]

  "..." / "HDL_IDENT" / "ATTRIBUTES" / "$":
    newjObjRet parent["ATTRIBUTES"]

  "..." / "PROPERTIES" / "$":
    newjObjRet parent["PROPERTIES"]

  "..." / "PROPERTIES" / "PROPERTY":
    parent[args[0].vstr] = %args[1]

  "..." / "*":
    # if 
    # else:

    parent[path[^1]] = %args[0]

# -----------------------------

let nodes = parseLisp readFile "./examples/simple.cl"
# writeFile "out.rkt", pretty nodes
writefile "./temp/out.json", pretty toJson(nodes, rules)

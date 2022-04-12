import json, lisp, serializer

# helpers ----------------------------------

template newjObjRet(wrapper): untyped =
  let r = %*{}
  wrapper = r
  r

func genTimeObj(args: seq[LispNode]): JsonNode =
  %*{"unix": args[0], "readable": args[1]}

# defs -------------------------------------

let easRules* = parseRules:
  "..." / "POSITION":
    parent["POSITION"] = %*{"x": args[0], "y": args[1]}

  "..." / "GEOMETRY":
    parent["GEOMETRY"] = %*{
      "x": args[0], "y": args[1],
      "width": args[2], "height": args[3],
    }

  "..." / "*" / "PROPERTY":
    parent[args[0].vstr] = %args[1]

  "..." / "OBJSTAMP" / "MODIFIED":
    parent[path[^1]] = genTimeObj args

  "..." / "OBJSTAMP" / "CREATED":
    parent[path[^1]] = genTimeObj args

  "..." / "*" / "$":
    if args.len == 0: nil
    else: newjObjRet parent[path[^1]]

  "..." / "*":
    parent[path[^1]] =
      if args.len == 1: %args[0]
      else: %args

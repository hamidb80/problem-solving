import std/[os, json]
import private/[lisp, serializer]

export lisp, serializer

# --------------------------
## project structure:
##
## | ease.db
## | - project.eas
## | - ...
## |
## | toolflow.xml
## | project.xml
## | workspace.eas

template newjObjRet(wrapper): untyped =
  let r = %*{}
  wrapper = r
  r

func genTimeObj(args: seq[LispNode]): JsonNode =
  %*{"unix": args[0], "formated": args[1]}

let rules* = parseRules:
  "..." / "LABEL" / "POSITION":
    parent["POSITION"] = %*{"x": args[0], "y": args[1]}

  "..." / "ENTITY":
    parent[args[0].vstr] = %args[1]

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

proc eas2json*(content: string): string {.inline.} =
  pretty toJson(parseLisp content, rules)

proc convertProbe(projectDir, dest: string) =
  for rpath in walkDirRec(projectDir, {pcFile, pcDir}, relative = true):
    if dirExists projectDir / rpath:
      createDir dest / rpath

    else:
      let (rdir, fname, ext) = splitfile rpath

      case ext:
      of ".eas":
        writeFile dest / rdir / fname & ".json", eas2json readfile rpath
      else:
        copyFileToDir projectDir / rpath, dest

proc ews2json*(projectDir, dest: string) =
  ## make sure the path exists
  convertProbe projectDir, dest

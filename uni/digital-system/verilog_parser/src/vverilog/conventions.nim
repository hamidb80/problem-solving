import std/[sequtils, macros]


template err*(msg): untyped =
  raise newException(ValueError, msg)

macro def*(id, body): untyped =
  let returnType = @[ident"untyped"]

  case id.kind:
  of nnkIdent:
    newProc(id, returnType, body, nnkTemplateDef)
  of nnkCall:
    newProc(id[0],
      returnType & id[1..^1].mapIt newIdentDefs(it, newEmptyNode()),
      body, nnkTemplateDef)
  else:
    err "unexpected kind: " & $id.kind

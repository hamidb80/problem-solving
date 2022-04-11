import std/[os, json]
import private/[lisp, serializer, eas]

export lisp, serializer

# --------------------------

proc eas2json*(content: string): string {.inline.} =
  pretty toJson(parseLisp content, easRules)

proc convertProbe(projectDir, dest: string) =
  for rpath in walkDirRec(projectDir, {pcFile, pcDir}, relative = true):
    if dirExists projectDir / rpath:
      createDir dest / rpath

    else:
      let (rdir, fname, ext) = splitfile rpath

      case ext:
      of ".eas":
        writeFile dest / rdir / fname & ".json", eas2json readfile projectDir / rpath
      else:
        copyFileToDir projectDir / rpath, dest

proc ews2json*(projectDir, dest: string) =
  # TODO: make sure the path exists
  convertProbe projectDir, dest


when isMainModule:
  # TODO: command line app
  discard

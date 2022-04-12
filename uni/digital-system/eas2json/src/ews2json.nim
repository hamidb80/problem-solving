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



template check(cond, msg): untyped =
  if not cond:
    echo msg

proc ews2json*(projectDir, dest: string) =
  check dirExists projectDir, "failed access to project folder"
  check dirExists dest, "failed access to destination folder"
  convertProbe projectDir, dest

when isMainModule:
  let cmnds = commandLineParams()
  if cmnds.len == 2:
    ews2json cmnds[0], cmnds[1]
  else:
    echo "the app accepts 2 args, given ", cmnds.len
    echo "USAGE: app.exe PROJECT_DIR DEST_DIR"

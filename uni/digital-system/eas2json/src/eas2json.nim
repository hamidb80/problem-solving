import std/[os]
import private/[lisp, serializer, helper]

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

proc convertProbe*(projectDir, outputDir: string) =
  withDir projectDir:
    discard

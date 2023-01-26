# Package

version       = "0.0.1"
author        = "hamidb80"
description   = "final algorithm project - Shahed University fall 1401-1402"
license       = "MIT"
srcDir        = "src"
bin           = @["project"]


# Dependencies

requires "nim >= 1.6.10"
requires "https://github.com/xmonader/nim-terminaltables"

task build, "":
  exec "nim -o:build/script.js js src/webapp.nim"
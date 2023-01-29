# Package

version       = "0.0.1"
author        = "hamidb80"
description   = "final algorithm project - Shahed University fall 1401-1402"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.10"
requires "karax >= 1.2.2"
requires "https://github.com/xmonader/nim-terminaltables"

task web, "builds web app in ./build directory":
  exec "nim -o:build/script.js -d:release js src/webapp.nim"

task debug, "builds web app in ./build directory":
  exec "nim -d:debug r tests/test.nim"

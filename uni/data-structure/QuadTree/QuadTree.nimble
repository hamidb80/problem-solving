# Package

version       = "0.1.0"
author        = "hamidb80"
description   = "Interactive QuadTree experience"
license       = "MIT"
srcDir        = "src"
bin           = @["QuadTree"]


# Dependencies

requires "nim >= 1.7.1"

task make, "builds the app":
  exec "nim -d:release -o:dist/main.js js src/main.nim" 
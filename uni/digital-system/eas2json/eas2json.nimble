# Package

version       = "0.1.0"
author        = "hamidb80"
description   = "eas to json"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["ews2json"]


# Dependencies

requires "nim >= 1.6.4"

task make, "make exectuable file":
  exec "nim -o:ews2json.exe c --mm:arc -d:release ./src/ews2json.nim"
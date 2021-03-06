# Package

version       = "0.0.1"
author        = "hamidb80"
description   = "Verilog to .ews"
license       = "MIT"
srcDir        = "src"
bin           = @["verilog2json"]


# Dependencies

requires "nim >= 1.6.4"
requires "mathexpr == 1.3.2"
requires "https://github.com/hamidb80/ews == 0.0.2"
requires "https://github.com/hamidb80/vverilog == 0.0.1"

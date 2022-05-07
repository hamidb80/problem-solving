# Package

version       = "0.0.1"
author        = "hamidb80"
description   = "Verilog to .ews"
license       = "MIT"
srcDir        = "src"
bin           = @["verilog2ews"]


# Dependencies

requires "nim >= 1.6.4"
requires "print"
requires "https://github.com/hamidb80/vverilog == 0.0.2"

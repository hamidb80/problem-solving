import std/strformat

## FIXME: compile with -d:debugFmtDsl

let myName = "Hamid"

# echo fmt"hello {myName}, How Are You?

var fmtRes_436207627 = newStringOfCap(38)
add(fmtRes_436207627, "hello ")
formatValue(fmtRes_436207627, myName, "")
add(fmtRes_436207627, ", How Are You?")  
fmtRes_436207627

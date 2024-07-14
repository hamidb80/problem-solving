Moves ← map "UDRL" [[1 0] [¯1 0] [0 1] [0 ¯1]]

⇅ ← ↥⊙↧ # min max or clamp

GridLimiter ← ⇅ ¯1 1

GridPoints ← (
  -1⇡3
  .
  ⊞⊂
  ↯ [∞ 2]
)

ParseData ← (
  ♭ regex "\\w+"
  ⍚∵(get : Moves)
)

# ------------------------------------------

"ULL\nRRDDD\nLURDL\nUUUUD"
# &fras "./d2.dat"
ParseData
## ╭─
##            ╓─       ╓─        ╓─
##   ╓─       ╟  0 1   ╟  0 ¯1   ╟  1 0
##   ╟ 1  0      0 1      1  0      1 0
##     0 ¯1     ¯1 0      0  1      1 0
##     0 ¯1     ¯1 0     ¯1  0      1 0
##          ╜   ¯1 0      0 ¯1     ¯1 0
##                   ╜         ╜        ╜
##                                        ╯

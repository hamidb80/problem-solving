# AoC 2015 day 3

Moves ← map "^v<>" [[0 1] [0 ¯1] [¯1 0] [1 0]]
Steps ← &fras "./d3.dat" # real data
# Steps ← "^v^v^v^v^v" # test data

GetMove ← get : Moves

# part 1 ------------------

∵GetMove Steps
⊂ [0 0]
\+
◴
⧻

# part 2 ------------------

Steps
⍉ ↯ [∞ 2]
∵GetMove
≡\+
↯ [∞ 2]
⊂ [0 0]
◴
⧻

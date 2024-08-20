# Advent of Code year 2022 day 02 in Uiua

Rule ← map [0 1 ¯2 ¯1 2] [1 2 2 0 0]

ParseInput ← (+1 ≡(- "AX" ⊏ [0 2]) ↯ ∞_4)
PartOne ← (/+ ≡/+ ≡(⊂⊃(⊏ 1|×3get /- : Rule)))
PartTwo ← 1 # ??
Solve ← ⊃PartOne PartTwo

# ---------------------------

$ A Y
$ B X
$ C Z
$ .
# &fras "./input.txt"
Solve ParseInput

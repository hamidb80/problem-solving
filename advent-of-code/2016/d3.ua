# Advent of Code 2016 day 3 -- Uiua

# input is array of edge lenghs i.e. [a b c]
CanBeTriangle ← (
  ⊂ ⊢ ⇌ . .
  ◫ 2
  ≡/+
  ⊙¤
  ≡<
  ♭
  /↧
)

PartOne ← /+≡CanBeTriangle
PartTwo ← /+≡CanBeTriangle ↯ [∞ 3] ⍉

# ---------------------------------

# "1 2 3   \n 5  10 15 \n 3   4  5 \n 13 11 14 \n 12  9  1 \n  1  1  2"
# "11 21 31\n 12 22 32 \n 13 23 33 \n 41 51 61 \n 42 52 62 \n 43 53 63"
&fras "./d3.dat"
⋕ ♭ regex "\\d+"
↯ [∞ 3]

⊃PartOne PartTwo # 1050 1921

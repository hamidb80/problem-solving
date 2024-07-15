# Advent of Code 2016 day 3 -- Uiua

CanBeTriangle ← (
  ⊂ ⊢ ⇌ . .
  ◫ 2
  ≡/+
  ⊙¤
  ≡<
  ♭
  /↧
)

PartOne ← /+≡CanBeTriangle ↯ [∞ 3]
PartTwo ← /+≡CanBeTriangle ↯ [∞ 3] ⍉↯ [∞ 3]

# ---------------------------------

&fras "./d3.dat"
# "1 2 3\n5 10 15\n3 4 5\n13 11 14\n12 9 1\n1 1 2"
# "11 21 31\n12 22 32\n13 23 33\n41 51 61\n42 52 62\n43 53 63"
⋕ ♭ regex "\\d+"

⊃PartOne PartTwo # 1050 1921

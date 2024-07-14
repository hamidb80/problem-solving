Content ← &fras "./d1.dat"
# Content ← "R5, L5, R5, R3"
Rotations ← map ["L" "R"] [¯1 1]
Dirs ← [[1 0] [0 1] [¯1 0] [0 ¯1]] # NESW

⊬ ← ⊏ 1 # Second

Manhattan ← /+ ⌵

ParseDataImpl ← (
  °□ ⊢ .
  get : Rotations

  ⋕ ⊬ :
  ⊟ :
)
ParseData ← (
  regex "[A-Z]|\\d+"
  ↯ [∞ 2]
  ≡ParseDataImpl
)

Moves ← (
  ◿4 \+ ≡⊢ .
  ⊏ : Dirs
  ≡⊬ :
  ×
)

PartOne ← Manhattan /+
PartTwo ← (1)

# ---------------------

ParseData Content
Moves
⊃PartOne PartTwo

# Advent of Code 2017 day 1 -- Uiua

IsEqualPair ← ≍ ⇌ .

PartOne ← (
  ⊂ ⟜⊢
  .
  ◫ 2
  ≡IsEqualPair
  ⊚
  ⊏
  /+
)

PartTwo ← (
  ↯ [2 ∞]
  ⍉
  .
  ≡IsEqualPair
  ⊚
  ⊏
  /+
  /+
)

# --------------------

# &fras "./d1.dat"
# "1122" # 3
# "1111" # 4
# "1234" # 0
# "91212129" # 9
# "12131415" # 4
# "123425" # 4
# "123123" # 12
∵⋕

PartOne .
## "34:1: Stack was empty when evaluating argument 1" 
PartTwo :
##

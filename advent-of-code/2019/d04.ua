# make range from a .. b ? start end
∹ ← (
  ⊃(+1-|∘)
  +⇡
)
∹ 1 5
∹ 5 1

# get second
⊧ ← ⊏ 1
⊧ [0 1 2]

# check is sorted pair
↠ ← ≤⊃⊧⊢
↠ [1 2]
↠ [1 1]
↠ [2 1]

# check is symmetric
⋈ ← ≍ ⇌ .
⋈ [1 1]
⋈ [1 2]

Digits ← ∵⋕
Digits "3120"

SplitInt ← Digits °⋕
SplitInt 123

HasRepeativeAdjacent ← /↥(≡⋈)◫ 2
HasRepeativeAdjacent [1 3 4 5 5 6 7]
HasRepeativeAdjacent [1 2 3 4]

IsIncreasing ← /×≡↠(◫ 2)
IsIncreasing [1 2 2]
IsIncreasing [1 2 3]
IsIncreasing [1 3 2]
IsIncreasing [2 2 2 2 2 2]

HasOnePair ← (
  ⊛.
  ⊕⧻
  =2
  /↥
)
HasOnePair SplitInt 112233
HasOnePair SplitInt 111122
HasOnePair SplitInt 123444

Prepare ← ⊏ ⊚ ≡IsIncreasing . ∵SplitInt ∹
PartOne ← /+ ≡HasRepeativeAdjacent
PartTwo ← /+ ≡HasOnePair
Solve ← ⊃PartOne PartTwo Prepare

Solve 193651 649729

# Advent of Code Day 02 in BQN by @hamidb80

newline ← @+10 # \n
Partition ← { 𝕨 ⊔˜ ¯1 + 𝕩 ∧ +` »⊸<𝕩 }
Split ← { 𝕩 ⊔˜ ¯1 + (¬i) ∧ 1+ +` i ← 𝕨=𝕩 }
Remove1 ← { (</⟜𝕩) ˘ (n⥊1) ∾ n‿n ⥊ 0 ∾ 1 ⥊˜ n ← ≠𝕩 }
Parse ← { {•ParseFloat ⌜ ⊢ Partition ∊⟜"0123456789"} ⌜ newline Split 𝕩 }
LimitCond ← ∧´ 1‿2‿3  ∊˜ (|∘-´˘    2↕⊢) # the level satisfies (1 ≤ level ≤ 3)
SortCond  ← ((∧´ >´˘) ∨  (∧´ <´˘)) 2↕⊢  # all decreasing or all increasing
Part1 ← { +´     LimitCond⊸∧⟜SortCond ⌜              𝕩 }
Part2 ← { +´ {∨´ LimitCond⊸∧⟜SortCond ⌜ Remove1 𝕩} ⌜ 𝕩 }
Day02 ← (Part1 ∾ Part2) ○ Parse

Day02 "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"
all         ← ⥊ ≍⌜˜1+↕3      # all possible combinations
possible    ← (≠´¨all) / all # possbile states: Monty does not open the prize door
door        ← 1              # selected door
isNot ← door≠(0⊸⊑)¨possible  # the prize is at different door
•Show isNot ≍ possible       # show temporary results
⟨+´isNot, ≠isNot⟩           # shoud change , all states
# ┌ 0       0       1       1       1       1        
#   ⟨ 1 2 ⟩ ⟨ 1 3 ⟩ ⟨ 2 1 ⟩ ⟨ 2 3 ⟩ ⟨ 3 1 ⟩ ⟨ 3 2 ⟩  ┘
# ⟨ 4 6 ⟩

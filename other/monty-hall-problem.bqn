all             ← ⥊ ≍⌜˜1+↕3      # all possible combinations
door            ← 1              # selected door
isSelectedDoor  ← door=1⊸⊑ ¨all  # Monty does not open selected door
isPrizeDoor     ← =´       ¨all  # Monty does not open prize    door
possible        ← (¬ (isSelectedDoor ∨ isPrizeDoor)) / all # possbile states 
shouldSwitch    ← door≠(0⊸⊑)¨possible # the prize is at different door
•Show shouldSwitch ≍ possible # show temporary results
⟨+´shouldSwitch, ≠shouldSwitch⟩ # shoud change , all states
   
# ╵ 0       0       1       1        
#   ⟨ 1 2 ⟩ ⟨ 1 3 ⟩ ⟨ 2 3 ⟩ ⟨ 3 2 ⟩  
# ⟨ 2 4 ⟩

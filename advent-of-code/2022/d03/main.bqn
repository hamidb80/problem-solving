inp ← ⟨
  "vJrwpWtwJgWrhcsFMMfFFhFp",
  "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL",
  "PmmdzqPrVvPwwTWBwg",
  "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn",
  "ttgJtRGJQctTZtZT",
  "CrZsJsPPZsGzwwsLwLmpwMDw",
⟩

L     ← {𝕩+↕26}        # Letter Set Generator
p     ← ∾ L¨ "aA"      # priorities
H2    ← {1 ⊏ 2‿↑ ⥊ 𝕩} # second half
Pri   ← {1+ p ⊒ 𝕩}     # Priority
Intersect ← {𝕩 (∊/⊣) 𝕨}

Part1 ← {
  Cchr ← {(⌊´ H2 ⊐˜𝕩) ⊑ 𝕩} # common character
  ⊑ +´ Pri○Cchr ¨ 𝕩        # final result
}

Part2 ← { 
  +´ (Pri·⊏Intersect´) ˘ ↑‿3 ⥊ 𝕩
}

Solve ← {⟨Part1 𝕩, Part2 𝕩⟩}

# -----------------------------------------------

Solve inp

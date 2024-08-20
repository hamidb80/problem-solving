# Advent of Code year 2022 day 03 in BQN

L         ← {𝕩+↕26}        # Letter Set Generator
p         ← ∾ L¨ "aA"      # priorities
Pri       ← {1+ p ⊒ 𝕩}     # Priority
Intersect ← {𝕩 (∊/⊣) 𝕨}    # stolen from https://mlochbaum.github.io/bqncrate/

PartCommon ← {+´ (Pri·⊏Intersect´) ˘𝕩}
Part1      ← {PartCommon ∾˘ {<˘ 2‿∘ ⥊ 𝕩} ¨𝕩}
Part2      ← {PartCommon ↑‿3  ⥊  𝕩}
Solve      ← {⟨Part1 𝕩, Part2 𝕩⟩}

Solve ⟨
  "vJrwpWtwJgWrhcsFMMfFFhFp"
  "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL"
  "PmmdzqPrVvPwwTWBwg"
  "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn"
  "ttgJtRGJQctTZtZT"
  "CrZsJsPPZsGzwwsLwLmpwMDw"
⟩
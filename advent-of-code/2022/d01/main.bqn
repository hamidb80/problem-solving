# BQN solution for advent of code year 2022 day 1 -- without parser

inp ← ⟨
  1000‿2000‿3000, 
  4000‿5000‿6000,
  7000‿8000‿9000,
  ⟨10000⟩
⟩

# Part1 ← {⌈´ +´¨ 𝕩}
# Part2 ← {+´ 3 ↑ ∨ +´¨ 𝕩}
TopSum ← {+´ 𝕨 ↑ ∨ +´¨ 𝕩}
Part1 ← {1 TopSum 𝕩}
Part2 ← {3 TopSum 𝕩}

Part1 inp
Part2 inp
# Advent of Code 2023 day 3 in BQN
# ideas from https://www.youtube.com/watch?v=77uUu4vcZ-8

nl ← '
'
Stencil3  ← {
  map ←  𝕩
  r‿c ← ≢𝕩
  Impl ← {
    a ← 0 ⌈ (𝕨-1)
    c ← 0 ⌈ (𝕩-1)
    b ← 3 - (𝕨=0) ∨ (𝕨=r-1)
    d ← 3 - (𝕩=0) ∨ (𝕩=c-1)
    {d↑ c↓ 𝕩} ˘ b↑ a↓ map
  }
  (↕r) Impl⌜ ↕c
}
Solve ← {
  raw     ← 𝕩 ∾ nl
  ids     ← ¯1 + ((+` »<⊢) ∧ ⊢) raw ∊ "0123456789"
  numbers ← •ParseFloat ¨ ids ⊔ raw
  adj   ← ⥊ (¯1⊸≠ ⊸/·⍷⥊) ¨ Stencil3 (⊑ 𝕩 ⊐ nl)‿↑ ⥊ ids
  part1 ← +´       numbers ⊏˜ ∾            (¬ raw ∊ nl ∾ ".0123456789") / adj
  part2 ← +´ ×´ ˘ (numbers ⊏˜ > {2=≠∘>˘𝕩} ⊸/ (raw ∊ "*")                / adj)
  part1 ⋈ part2
}

# ⟨ 527144 81463996 ⟩
Solve 1↓"
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."

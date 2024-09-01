# Advent of Code 2023 day 3 in BQN
# ideas from https://www.youtube.com/watch?v=77uUu4vcZ-8
# XXX works on the test input but not actual input :(

inp ← "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."


nl ← @+10
Stencil3  ← {
  map  ← 𝕩
  r‿c ← ≢ map
  Fn ← {
    a ← 0 ⌈ (r-1) ⌊ (𝕨-1)
    b ← 3 - (𝕨=0) ∨ (𝕨=r-1)
    
    c ← 0 ⌈ (c-1) ⌊ (𝕩-1)
    d ← 3 - (𝕩=0) ∨ (𝕩=c-1)
    
    indexes ← ¯1⊸≠ ⊸/ ⍷ ⥊ {d↑ c↓ 𝕩} ˘ b↑ a↓ map
  }
  (↕r) Fn⌜ ↕c
}
SplitGrid ← ((¯1+ (1+`⊢) ∧ ¬) nl⊸=) ⊔ ⊢
Solve ← {
  grid      ← > SplitGrid 𝕩
  relaxed   ← ⥊ grid
  digitsi   ← ∊⟜"0123456789" ˘ relaxed
  first     ← <´˘ 2↕ 0 ∾ digitsi
  uniq      ← ¯1 + (+` first) ∧ digitsi
  numbers   ← •ParseFloat ¨ uniq ⊔ relaxed
  map       ← uniq ⥊˜ ≢grid
  adjacencyMapR ← ⥊ Stencil3 map
  part1  ← +´       numbers ⊏˜ ∾            (¬ relaxed ∊ ".0123456789") / adjacencyMapR  
  part2  ← +´ ×´ ˘ (numbers ⊏˜ > {2=≠∘>˘𝕩} ⊸/ (relaxed ∊ "*")           / adjacencyMapR)
  part1 ⋈ part2
}

Solve inp

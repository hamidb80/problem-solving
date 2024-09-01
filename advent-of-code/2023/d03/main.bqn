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
SplitGrid ← ((¯1+ (1+`⊢) ∧ ¬) nl⊸=) ⊔ ⊢
Solve ← {
  grid      ← > SplitGrid 𝕩
  relaxed   ← ⥊ grid
  digitsi   ← ∊⟜"0123456789" ˘ relaxed
  first     ← <´˘ 2↕ 0 ∾ digitsi
  uniq      ← ¯1 + (+` first) ∧ digitsi
  numbers   ← •ParseFloat ¨ uniq ⊔ relaxed
  map       ← uniq ⥊˜ ≢grid
  r‿c      ← ≢ grid # rows‿cols
  Stencil  ← {
    a ← 0 ⌈ (r-1) ⌊ (𝕨-1)
    b ← 3 - (𝕨=0) ∨ (𝕨=r-1)
    
    c ← 0 ⌈ (c-1) ⌊ (𝕩-1)
    d ← 3 - (𝕩=0) ∨ (𝕩=c-1)
    
    indexes ← ¯1⊸≠ ⊸/ ⍷ ⥊ {d↑ c↓ 𝕩} ˘ b↑ a↓ map
  }
  adjacencyMap ← (↕r) Stencil⌜ ↕c
  adjacencyMapR ← ⥊adjacencyMap
  filterP1  ← ¬ relaxed ∊ ".0123456789"
  filterP2  ←   relaxed ∊ "*"          
  temp1  ← filterP1 / adjacencyMapR 
  temp2  ← filterP2 / adjacencyMapR 
  ii2    ← 2⊸=≠∘> ˘ temp2
  sel1   ← numbers ⊏˜ ∾       temp1
  sel2   ← numbers ⊏˜ > ii2 / temp2
  part1  ← +´      sel1
  part2  ← +´ ×´ ˘ sel2
  part1 ⋈ part2
}

Solve inp

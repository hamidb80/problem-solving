nl ← @+10
dirs ← ⊣⊸∾⟜- =⌜˜↕2
Digits ← {
  s ← 𝕩 - '0'
  ⊑ s ⊔˜ ¯1 + 0= ⌊ s ÷ 10 
}
Width ← {⊑ / nl = 𝕩}
I2P ← {[⌊𝕩÷𝕨, 𝕨|𝕩]} # index to position
P2I ← {
  r‿c ← 𝕩
  c + 𝕨×r  
} # position to index
Mates ← {
  p ← 𝕨 I2P 𝕩
  c ← 𝕨 P2I ˘ p +⎉1 dirs
  < (0⊸≤ ∧ <⟜(𝕨×𝕨)) ⊸/ c
}
Walk ← {
  s ← 𝕨 Mates ˘ 
  1 = ⊏⟜𝕩 ¨ s
}
Solve1 ← {
   𝕩 Walk /0=𝕩
}

# ------------

inp ← "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"


w‿p ← Width⊸⋈⟜Digits inp
w Solve1 p

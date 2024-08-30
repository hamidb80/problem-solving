# TODO incomplete Advent of Code 2019 day 06 in BQN

inp ← "COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L"

SplitBy ← {
  j ← 0‿1⊸≡ ˘ 2↕ 0∾𝕨
  k ←  1 +` j
  l ← ¯1 +  k ∧ ¬𝕨
  l ⊔ 𝕩
}
Exclude ← {𝕨/˜¬𝕨∊𝕩}

data        ← (¬ 'A' < inp) SplitBy inp
planets     ← ⍷ data
PlanetIndex ← ⊑ planets⊸⊐
rels        ← ↑‿2 ⥊ PlanetIndex ˘ data
[src,dest]  ← ⍉rels 
leaves ←  dest Exclude  src
root   ← ⊑dest Exclude˜ src
leaves

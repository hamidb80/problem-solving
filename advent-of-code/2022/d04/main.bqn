# Advent of Code 2022 day 4 in BQN

Parse  ← (∘‿2‿2 ⥊ {(>⟜«0≤𝕩)/0(0⊸≤××⟜10⊸+)`𝕩}∘-⟜'0') # stolen from https://mlochbaum.github.io/bqncrate
MinMax ← (⌊´ ∾ ⌈´)
HaveFullyIntersect ← {(MinMax 𝕨 ∾ 𝕩) ∊ [𝕩,𝕨]}
AreDistinct        ← {
  x ← 𝕩 + ¯1‿1 # to exclude edge overlap 
  a ← x ∾ 𝕨
  b ← 𝕨 ∾ x
  c ← ∧a
  (c≡a) ∨ (c≡b)
}
HaveIntersect      ← (¬AreDistinct)
Part1 ← {+´ HaveFullyIntersect˝ ˘𝕩}
Part2 ← {+´ HaveIntersect     ˝ ˘𝕩}
Solve ← (Part1 ∾ Part2)

Solve Parse "
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
"

Partition ← { 𝕨 ⊔˜ ¯1 + 𝕩 ∧ +` »⊸<𝕩 }
Parse ← { ↑‿2 ⥊ •ParseFloat⌜ 𝕩 Partition 𝕩∊"0123456789" }
Part1 ← { +´ | -˝ ∧˘ ⍉ Parse 𝕩 }
Part2 ← { 
  t ← ⍉ Parse 𝕩
  a ← 0⊏t
  b ← 1⊏t
  +´ ×˝ a ≍ +˝ b =⌜ a
}

Day01 ← Part1 ∾ Part2

input ← "3   4
4   3
2   5
1   3
3   9
3   3"

Day01 input
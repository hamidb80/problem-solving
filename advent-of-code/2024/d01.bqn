Partition ← { 𝕨 ⊔˜ ¯1 + 𝕩 ∧ +` »⊸<𝕩 }
Parse ← { ↑‿2 ⥊ •ParseFloat⌜ 𝕩 Partition 𝕩∊"0123456789" }
Part1 ← { +´ | -˝ ∧˘ ⍉ 𝕩 }
Part2 ← {
  a‿b ← <˘ ⍉ 𝕩
  +´ a × +˝ b =⌜ a
}

Day01 ← (Part1 ∾ Part2) ○ Parse

input ← "3   4
4   3
2   5
1   3
3   9
3   3"

Day01 input
# https://leetcode.com/problems/backspace-string-compare/description/

TerminalType ← {
  i ← 𝕩='#'
  j ← (¬∨-)i
  k ← ¯1 {¯1 ⌈ 𝕨+𝕩}`j # not less than ¯1
  s ← (- ∨ k∧¬)i
  l ← ⊑∘⌽ ¨ s⊔𝕩
  l ↑˜ 1+⊑⌽k # trim last
}
BackSpaceStrCmp ← ≡○TerminalType

# ---------------------------------

•Show TerminalType "###salam##ad"
•Show TerminalType "12###3"

•Show "ab#c" BackSpaceStrCmp "ad#c"
•Show "ab##" BackSpaceStrCmp "c#d#"
•Show "a#c"  BackSpaceStrCmp "b"
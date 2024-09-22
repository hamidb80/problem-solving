# https://leetcode.com/problems/backspace-string-compare/description/

TerminalType ← {
  i ← 𝕩='#'
  j ← (¬∨-)i
  k ← ¯1 {¯1 ⌈ 𝕨+𝕩}`j # not less than ¯1
  s ← ¯1+(k+1)∧¬i
  #•Show s‿k‿i‿j  # for debugging
  l ← ⊑∘⌽ ¨ s⊔𝕩
  l ↑˜ 1+⊑⌽k # trim last
}
BackSpaceStrCmp ← ≡○TerminalType

# ---------------------------------

•Show TerminalType "###salam##ad"

•Show "ab#c" BackSpaceStrCmp "ad#c"
•Show "ab##" BackSpaceStrCmp "c#d#"
•Show "a#c"  BackSpaceStrCmp "b"
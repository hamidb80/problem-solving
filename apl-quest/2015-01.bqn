upperCase ← 'A' + ↕26
lowerCase ← 'a' + ↕26
allCase   ← upperCase ∾ lowerCase

ToLower   ← ⊢ + (32 ⊸×∘ ¬ 'a' ≤ ⊢)
Normalize ← toLower ˘ ∊ ⟜ allCase ⊸/
I         ← ∧Normalize
Fn        ← ⊣I⊸≡⟜I⊢

•Show "anagram" Fn "Nag A Ram" # 1
•Show "Dyalog APL" Fn "Dog Pay All" # 1
•Show "" Fn "  !#!" # 1
•Show "abcde" Fn "zyxwvu"# 0

-------------

alpha ← ('a'⊸+ ∾ 'A'⊸+)↕26
Normalize ← ∊⟜alpha/⊢
IsPalindrome ← (⌽≡⊢)∘Normalize

•Show IsPalindrome "a man, a plan, a canal, panama!" # 1
•Show IsPalindrome "" # 1
•Show IsPalindrome "a" # 1
•Show IsPalindrome "APL" # 0
'.'
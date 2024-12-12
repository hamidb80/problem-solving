Fn ← {
  n ← (≠𝕨) ⌊ (≠𝕩)
  (⥊ ⍉ (n↑𝕨) ≍ (n↑𝕩)) ∾ (n↓𝕩) ∾ (n↓𝕨)
}

•Show "MENS" Fn "EKES" # "MEEKNESS"
•Show "Dyalog" Fn "APL" # "DAyPaLlog"
•Show "APL" Fn "Dyalog" # "ADPyLalog"
•Show 1‿3‿5‿7 Fn 2‿4‿6‿8  # should work with numeric vectors # 1 2 3 4 5 6 7 8
•Show "" Fn "Hello" # either or both arguments could be empty # "Hello"
-------------
Dice       ← ⥊ ·+⌜´ 1+ ·↕¨⊢
CountTab   ← ⍉ ⍷ ≍  (/⁼⊐)
DiceSumTab ← CountTab∘Dice

•Show DiceSumTab 6‿6
•Show DiceSumTab 6‿4
•Show DiceSumTab ⟨3⟩
•Show DiceSumTab ⟨⟩
'.'

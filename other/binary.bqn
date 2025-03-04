DecTo ← { # stolen from BQNcrate
  𝕩=0? ↕0 ;
  (𝕨 𝕊 ⌊𝕩÷𝕨) ∾ (𝕨|𝕩)
}
CalcPoly ← { +´ 𝕩 × ⌽ 𝕨 ⋆ ↕≠𝕩 }
Bin ← 2⊸DecTo
BinToDec ← 2⊸CalcPoly

# ------------------------

BinToDec Bin 11
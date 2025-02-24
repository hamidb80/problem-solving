# Stolen from lab section in https://jsoftware.github.io/j-playground/ 
# and help of DeepSeek AI ( explained wierd J syntax )

Huffman ← {
  (1=≠𝕩) ? 𝕨 ;
  y ← ⍋𝕩
  j ← 2↑y
  i ← (¬∘∊⟜j) ⊸/ ↕≠𝕩
  newFreq ← (i⊏𝕩) ∾ +´ j⊏𝕩
  newSym  ← (i⊏𝕨) ∾ <  j⊏𝕨
  newSym Huffman newFreq
}

ToCodeImpl ← { 
   2= •Type 𝕩 ? 𝕨 ;
   l ← (𝕨∾0) ToCodeImpl 0⊑𝕩
   r ← (𝕨∾1) ToCodeImpl 1⊑𝕩
   l ⋈ r
}

Repr ← {
  (1=≠𝕩) ? <𝕨 ;
  l ← (0⊑𝕨) Repr (0⊑𝕩)
  r ← (1⊑𝕨) Repr (1⊑𝕩)
  codes ← l ∾ r
}

ToCode ← {
  t ← ⟨⟩ ToCodeImpl ⊑𝕩
  codes  ← t Repr ⊑𝕩
  string ← ({(∾𝕊¨)⍟(1<≡)⥊𝕩} 𝕩) # stolen from BQNcrate
  ⍉ string ≍ codes
}

# Define symbols and frequencies
sym ←  ⟨'a','b','c', 'd', 'e', 'f'⟩
freq ← ⟨5,   9,  12, 13,   16, 45⟩

huffmanTree ← sym Huffman freq

•Show huffmanTree
•Show ToCode huffmanTree
-----------------------

# ┌─                               
# · ┌─                             
#   · 'f' ⟨ "cd" ⟨ "ab" 'e' ⟩ ⟩    
#                               ┘  
#                                 ┘
# ┌─                 
# ╵ 'f' ⟨ 0 ⟩        
#   'c' ⟨ 1 0 0 ⟩    
#   'd' ⟨ 1 0 1 ⟩    
#   'a' ⟨ 1 1 0 0 ⟩  
#   'b' ⟨ 1 1 0 1 ⟩  
#   'e' ⟨ 1 1 1 ⟩    
#                   ┘
# -----------------------
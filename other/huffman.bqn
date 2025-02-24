# Stolen from lab section in https://jsoftware.github.io/j-playground/ 
# and help of DeepSeek AI

Huffman ← {
  (1=≠𝕩) ? 𝕨 ;
  y ← ⍋𝕩
  j ← 2↑y
  i ← (¬ j ∊˜)⊸/ ↕≠𝕩
  newFreq ← (i⊏∘𝕩) ∾ +´ j⊏𝕩
  newSym  ← (i⊏𝕨) ∾ <  j⊏𝕨
  newSym Huffman newFreq
}

# Define symbols and frequencies
sym ←  ⟨'a','b','c', 'd', 'e', 'f'⟩
freq ← ⟨5,   9,  12, 13,   16, 45⟩

•Show sym Huffman freq
-----------------------
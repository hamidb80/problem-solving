grade_tab ← ∾⟨
  65 ⥊ 'F',
  5  ⥊ 'D',
  10 ⥊ 'C',
  10 ⥊ 'B', 
  11 ⥊ 'A',
⟩
Fn ← { ⊏⟜grade_tab ˘ 𝕩 }

•Show Fn 0‿64‿65‿69‿70‿79‿80‿89‿90‿100 # FFDDCCBBAA
•Show Fn 2‿3 ⥊ 71‿82‿81‿82‿84‿59       # CBB BBF
•Show Fn ⟨⟩                            # ⟨⟩

-------------
# Game of Life implementation in BQN
# thanks to [Game of Life in APL] https://www.youtube.com/watch?v=pMslgySQ8nc

InitRandomGrid ← {𝕩 ⥊ Rand⟜𝕨⌜ ↕×´𝕩}
Rand      ← {𝕩 <˜ •rand.Range 0}
XoY       ← {v‿h ← 𝕩 ⋄ h⌽ v⌽ ˘𝕨}
Iter      ← {(=⟜3 (⊣ ∨ 𝕩⊸∧) 4⊸=) +´+˝ 𝕩⊸XoY ¨ ⋈⌜˜ ¯1+↕3}
Run       ← {> (<𝕨) (Iter·>⊣)` ↕𝕩}
Repr      ← ⊑⟜"·•" ¨

Repr ˘ (0.2 InitRandomGrid 10‿70) Run 100
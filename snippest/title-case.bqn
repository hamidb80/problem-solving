TitleCase ← {
  b ← (⊢ > ») ('a'⊸≤ ∧ ≤⟜'z') 𝕩
  @+((𝕩-@) ∧ ¬b) ∨ (b ∧ ((𝕩-'a'-'A')-@))
}

TitleCase "big questions notation"
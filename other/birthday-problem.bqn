BirthdayProblem ← {
  y ← 365
  none ← (×´y-↕𝕩)÷(y⋆𝕩)
  1-none
}

k ← 1+↕100
⍉ k ≍ BirthdayProblem ¨ k

Indexes ← { 0⊸≠⊸/ (𝕨=𝕩) ∧ (1+↕≠𝕩) }
Fn ← { 
  b ←   'B' Indexes 𝕩
  r ← ∧ 'R' Indexes 𝕩
  k ← ⊑ 'K' Indexes 𝕩
  # length check - K is between the two Rs - Bs occupy one odd and one even position
  (2⊸= ≠r) ∧ (2⊸= ≠b) ∧ (0‿1 ≡ ∧ 2|b) ∧ (0‿1‿1‿0 ≡ k (<∾>) r)
}


•Show Fn "RNBQKBNR" # standard chess layout :: 1
•Show Fn "BBNRKNRQ" # layout in diagram above :: 1
•Show Fn "RBBNQNRK" # K not between Rs :: 0
•Show Fn "BRBKRNQN" # Bs both in odd positions  :: 
---------------
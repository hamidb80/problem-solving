RmExtraSpaces ← {
  i ← ' '=𝕩
  j ← ¬i ∧ »i          # mid spaces
  k ← (∨`⌾⌽ ∧ ∨`) ¬i # start and end spaces
  𝕩 /˜ k ∧ j
}

•Show RmExtraSpaces "  this  is a     test  "
•Show RmExtraSpaces "hello world!"
•Show RmExtraSpaces "  " # vector of only spaces should return empty vector
•Show RmExtraSpaces "" # should return an empty vector
'.'

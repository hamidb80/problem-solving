letters ← ('a'⊸+ ∾ 'A'⊸+) ↕26
Fn ← {
  𝕩 + 𝕨 × 𝕩 ∊ letters
}

•Show 4 Fn "HELLO WORLDS" # LIPPSD SVPHW
•Show ¯4 Fn "HELLO WORLDS" # negative shifts are okay # DAHHKWSKNH O 
•Show 0 Fn "HELLO WORLDS" # no shift is okay # HELLO WORLDS
•Show 27 Fn "HELLO WORLDS" # HELLO WORLDS
•Show ¯10 Fn "" # returns an empty vector
----------------------
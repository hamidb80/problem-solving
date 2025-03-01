# implementing partition in BQN, similar to what is in APL or Uiua
# I frequently find myself re-implemment this
# very useful function and I don't know why BQN does not have this built-in.

Partition ← {
  i ← »⊸<𝕩 
  # stolen from BQNcrate: https://mlochbaum.github.io/bqncrate/
  # it called "Boolean first ones in each group of ones"
  𝕨 ⊔˜ ¯1 + 𝕩 ∧ +`i
}

# example usage

Parse ← {
  i ← 𝕩∊"0123456789"
  •ParseFloat ⌜ 𝕩 Partition i
}

Parse "11 3
7  44112
"
# https://leetcode.com/problems/remove-outermost-parentheses/

Rm1Pars ← { # assumed input is valid
  o ← '('=𝕩 # open
  c ← ')'=𝕩 # close
  d ← +` o + »-c # depth
  m ← (o∨c) ∧ (1=d) # mask
  •Show [𝕩,o,c,d,m] # to show what's going on 
  𝕩 /˜ ¬m
}

•Show Rm1Pars "(12)+((12))"
'.'
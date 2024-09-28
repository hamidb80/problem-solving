# https://leetcode.com/problems/remove-outermost-parentheses/

Rm1Pars ← { # assumed input is valid
  o ← '('=𝕩
  c ← ')'=𝕩
  g ← +` o + »-c
  f ← (o∨c) ∧ (1=g)
  •Show ["input ","open (","close)","depth ","filter"] ⋈ [𝕩,o,c,g,f]  # to show what's going on 
  𝕩 /˜ ¬f
}

•Show Rm1Pars "(12)+((12))"
'.'